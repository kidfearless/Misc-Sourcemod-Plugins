#include <sourcemod>
#include <shavit>
#include <sdktools>
#include <sdkhooks>
#undef REQUIRE_PLUGIN
#include <precache_manager>

#define REPLAY_FORMAT_V2 "{SHAVITREPLAYFORMAT}{V2}"
#define REPLAY_FORMAT_FINAL "{SHAVITREPLAYFORMAT}{FINAL}"
#define REPLAY_FORMAT_SUBVERSION 0x04
#define CELLS_PER_FRAME 3 // origin[3]
#define JUMP_BOX_SIZE 16.0
#define MOD_STEP 15
#define MOD_SIZE 360.0
//ReplayData
#define origin_x 0
#define origin_y 1
#define origin_z 2

#define JUMP_COLOR {255, 0, 0, 255}
#define WHITE {255, 255, 255, 255}
#define RED {255, 0, 0, 255}
#define GREEN {0, 255, 0, 255}
#define BLUE {0, 0, 255, 255}
// 12 + 12 = 24; 255 - 24 = 231; 231 - one safety buffer 230
#define MAX_BEAMS 230

enum struct ReplayData
{
	float x;
	float y;
	float z;
	bool walking;
	bool jumped;
}

enum struct PathVec
{
	float x;
	float y;
	float z;

	void FromArray(float input[3])
	{
		this.x = input[0];
		this.y = input[1];
		this.z = input[2];
	}

	void FromPoints(float X, float Y, float Z)
	{
		this.x = X;
		this.y = Y;
		this.z = Z;
	}

	void ToArray(float output[3])
	{
		output[0] = this.x;
		output[1] = this.y;
		output[2] = this.z;
	}
}

enum ColorState
{
	rty,
	ytg,
	gtc,
	ctb,
	btm,
	mtr
};

ArrayList gA_Frames[STYLE_LIMIT][TRACKS_SIZE];
ArrayList gA_ClientFrames[MAXPLAYERS];

bool gB_Enabled[MAXPLAYERS];
bool gB_Ghost[MAXPLAYERS];
bool gB_Jumps[MAXPLAYERS];
bool gB_Static[MAXPLAYERS];
bool gB_Late;

int gI_BeamSprite = -1;
// int gI_HaloSprite = -1;
int gI_LastJumpMark[MAXPLAYERS];
int gI_ParticleReference[MAXPLAYERS];
int gI_CycleColor[MAXPLAYERS][4];
float gF_Modulus[MAXPLAYERS];

ConVar gC_ParticlePath;
ConVar gC_TimerDelay;
ConVar gC_TimerLife;

Handle gT_Clients[MAXPLAYERS];

ArrayList gA_Jumps[STYLE_LIMIT][TRACKS_SIZE];
ArrayList gA_ClientJumps[MAXPLAYERS];

Menu gM_BotPath;

ColorState gCS_Clients[MAXPLAYERS] = {rty, ...};

methodmap BotPathClient __nullable__
{
	public BotPathClient(int client)
	{
		return view_as<BotPathClient>(client);
	}

	property int Index
	{
		public get()
		{
			return view_as<int>(this);
		}
	}

	public bool IsValid()
	{
		return IsValidClient(this.Index);
	}

	property int FrameCount
	{
		public get()
		{
			return Shavit_GetClientFrameCount(this.Index);
		}
	}

	property ArrayList Frames
	{
		public get()
		{
			return gA_ClientFrames[this.Index];
		}
		public set(ArrayList newval)
		{
			gA_ClientFrames[this.Index] = newval;
		}
	}

	property ArrayList Jumps
	{
		public get()
		{
			return gA_ClientJumps[this.Index];
		}
		public set(ArrayList newval)
		{
			gA_ClientJumps[this.Index] = newval;
		}
	}

	property int LastJump
	{
		public get()
		{
			return gI_LastJumpMark[this.Index];
		}
		public set(int newval)
		{
			gI_LastJumpMark[this.Index] = newval;
		}
	}

	property bool Enabled
	{
		public get()
		{
			return gB_Enabled[this.Index];
		}
		public set(bool newval)
		{
			gB_Enabled[this.Index] = newval;
		}
	}

	property bool Static
	{
		public get()
		{
			return gB_Static[this.Index];
		}
		public set(bool newval)
		{
			gB_Static[this.Index] = newval;
		}
	}

	property bool JumpPath
	{
		public get()
		{
			return gB_Jumps[this.Index];
		}
		public set(bool newval)
		{
			gB_Jumps[this.Index] = newval;
		}
	}

	property bool Ghost
	{
		public get()
		{
			return gB_Ghost[this.Index];
		}
		public set(bool newval)
		{
			gB_Ghost[this.Index] = newval;
		}
	}
	
	property ColorState color
	{
		public get()
		{
			return gCS_Clients[this.Index];
		}
		public set(ColorState newval)
		{
			gCS_Clients[this.Index] = newval;
		}
	}

	property int Particle
	{
		public get()
		{
			return EntRefToEntIndex(gI_ParticleReference[this.Index]);
		}
		public set(int newval)
		{
			gI_ParticleReference[this.Index] = EntIndexToEntRef(newval);
		}
	}

	property int Serial
	{
		public get()
		{
			if(this.IsValid())
			{
				return GetClientSerial(this.Index);
			}
			else
			{
				return 0;
			}
		}
	}

	property int Style
	{
		public get()
		{
			return Shavit_GetBhopStyle(this.Index);
		}
	}

	property int Track
	{
		public get()
		{
			return Shavit_GetClientTrack(this.Index);
		}
	}

	property float Mod
	{
		public get()
		{
			return gF_Modulus[this.Index];
		}
		public set(float newval)
		{
			gF_Modulus[this.Index] += newval;
			if(gF_Modulus[this.Index] > MOD_SIZE)
			{
				gF_Modulus[this.Index] -= MOD_SIZE;
			}
		}
	}

	property Handle timer
	{
		public get()
		{
			return gT_Clients[this.Index];
		}
		public set(Handle newval)
		{
			gT_Clients[this.Index] = newval;
		}
	}

	public void StartTimer()
	{
		this.timer = CreateTimer(gC_TimerDelay.FloatValue, Timer_DrawJumps, this.Index, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
	}

	public bool GetFrames()
	{
		if(!this.IsValid())
		{
			return false;
		}

		if(gA_Frames[this.Style][this.Track] != null)
		{
			this.Frames = gA_Frames[this.Style][this.Track];
			this.Jumps = gA_Jumps[this.Style][this.Track]
			return true;
		}

		return false;
	}

	public void CreateParticle()
	{	
		int index = CreateEntityByName("info_particle_system");
		if (IsValidEntity(index))
		{
			DispatchKeyValue(index, "start_active", "1");
			// for now let's hard code this
			DispatchKeyValue(index, "effect_name", "s_akskskenergy_trail");
			DispatchSpawn(index);

			ActivateEntity(index);

			this.Particle = index;

			SetEdictFlags(index, GetEdictFlags(index) & (~FL_EDICT_ALWAYS)); //to allow settransmit hooks
			SDKHookEx(index, SDKHook_SetTransmit, Hook_SetTransmit);
		}
	}

	public void UpdateParticle()
	{
		if(IsValidEntity(this.Particle))
		{
			float origin[3];
			GetClientAbsOrigin(this.Index, origin);
			TeleportEntity(this.Particle, origin, NULL_VECTOR, NULL_VECTOR);
		}
	}
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	gB_Late = late;

	return APLRes_Success;
}

public void OnPluginStart()
{
	gC_ParticlePath = CreateConVar("sm_bot_path", "particles/hell_energy.pcf", "Path to the particle used for ghost replays");
	gC_TimerDelay = CreateConVar("sm_bot_time", "0.1", "How often to redraw botpath beams");
	gC_TimerDelay.AddChangeHook(OnTimerChanged);
	gC_TimerLife = CreateConVar("sm_bot_life", "0.1", "How long do beams last");

	AutoExecConfig();

	RegConsoleCmd("sm_botpath", Command_BotPath);

	gM_BotPath = new Menu(BotPathMenuCallback);
	Menu m = gM_BotPath;
	m.SetTitle("Bot Path");
	m.AddItem("Bot", "Toggle Botpath");
	m.AddItem("Ghost", "Toggle Ghost");
	m.AddItem("Static", "Toggle Static Path");
	m.AddItem("Jumps", "Toggle Jumps");

	m = null;

	if(gB_Late)
	{
		LoadAllReplays(Shavit_GetStyleCount());

		for(int i = 1; i <= MaxClients; ++i)
		{
			BotPathClient c = new BotPathClient(i);
			c.GetFrames();
		}
	}
}

public void OnPluginEnd()
{
	for(int i = 1; i <= MaxClients; ++i)
	{
		RemoveCustomParticle(i);
	}
}

public Action Command_BotPath(int client, int args)
{
	gM_BotPath.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int BotPathMenuCallback(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select)
	{
		BotPathClient c = new BotPathClient(param1);
		if(c.IsValid())
		{
			char info[32];
			menu.GetItem(param2, info, 32);

			if(StrEqual(info, "Bot"))
			{
				c.Enabled = !c.Enabled;
				PrintToChat(c.Index, "You have toggled bot path %s", c.Enabled? "ON":"OFF");
			}
			else if(StrEqual(info, "Ghost"))
			{
				c.Ghost = !c.Ghost;
				PrintToChat(c.Index, "You have toggled ghost path %s", c.Ghost? "ON":"OFF");
			}
			else if(StrEqual(info, "Static"))
			{
				c.Static = !c.Static;
				PrintToChat(c.Index, "You have toggled static path %s", c.Static? "ON":"OFF");
			}
			else if(StrEqual(info, "Jumps"))
			{
				c.JumpPath = !c.JumpPath;
				PrintToChat(c.Index, "You have toggled jumps %s", c.JumpPath? "ON":"OFF");
			}
			gM_BotPath.Display(c.Index, MENU_TIME_FOREVER);
		}
	}
}

public void OnTimerChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	for(int i = 1; i <= MaxClients; ++i)
	{
		BotPathClient c = new BotPathClient(i);
		if(c.timer != INVALID_HANDLE)
		{
			KillTimer(c.timer);
			c.StartTimer();
		}
	}
}

public void OnConfigsExecuted()
{
	gI_BeamSprite = GetPrecachedIndex("materials/trails/beam_01.vmt");
	//gI_HaloSprite = GetPrecachedIndex("materials/sprites/glow02.vmt");

	for(int i = 1; i <= MaxClients; ++i)
	{
		BotPathClient c = new BotPathClient(i);
		c.StartTimer();
		c.CreateParticle();
	}
}

public void OnMapEnd()
{
	for(int i = 1; i <= MaxClients; ++i)
	{
		BotPathClient c = new BotPathClient(i);
		c.Enabled = false;
		c.JumpPath = false;
		c.Static = false;
		c.Ghost = false;
		c.Frames = null;
		c.Jumps = null;
		c.timer = INVALID_HANDLE;
		gI_ParticleReference[c.Index] = INVALID_ENT_REFERENCE;
	}

	for(int style = 0; style < STYLE_LIMIT; ++style)
	{
		for(int track = Track_Main; track < TRACKS_SIZE; ++track)
		{
			delete gA_Frames[style][track];
		}
	}
}

public void Shavit_OnStyleConfigLoaded(int styles)
{
	LoadAllReplays(styles);
}

void LoadAllReplays(int styles)
{
	char map[PLATFORM_MAX_PATH];
	GetCurrentMap(map, PLATFORM_MAX_PATH);
	GetMapDisplayName(map, map, PLATFORM_MAX_PATH);

	char path[PLATFORM_MAX_PATH];
	for(int style = 0; style < styles; ++style)
	{
		for(int track = Track_Main; track < TRACKS_SIZE; ++track)
		{
			char sTrack[4];
			FormatEx(sTrack, 4, "_%i", track);
			BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "data/replaybot/%i/%s%s.replay", style, map, (track == Track_Main? "": sTrack));
			if(FileExists(path))
			{
				// PrintToConsoleAll("file exists");
				LoadReplay(style, track, path);
			}
			else
			{
				// PrintToConsoleAll("file '%s' doesn't exist", path);
			}
		}
	}
}

bool LoadReplay(int style, int track, const char[] path)
{
	if(FileExists(path))
	{
		File file = OpenFile(path, "rb");

		char header[64];

		if(!file.ReadLine(header, 64))
		{
			delete file;

			return;
		}

		TrimString(header);
		char explodedHeader[2][64];
		ExplodeString(header, ":", explodedHeader, 2, 64);

		if(StrEqual(explodedHeader[1], REPLAY_FORMAT_FINAL)) // hopefully, the last of them
		{
			LoadCurrentReplayFormat(file, StringToInt(explodedHeader[0]), style, track);
		}
		else
		{
			LogError("kid-botpath encountered old replay format '%s'", explodedHeader[1]);
		}
	}

	return;
}

bool LoadCurrentReplayFormat(File file, int version, int style, int track)
{
	// replay file integrity and preframes
	if(version >= 0x03)
	{
		char map[160];
		file.ReadString(map, 160);

		file.Seek(6, SEEK_CUR);
	}

	int frameCount;
	file.ReadInt32(frameCount);

	if(gA_Frames[style][track] == null)
	{
		gA_Frames[style][track] = new ArrayList(CELLS_PER_FRAME);
	}

	gA_Frames[style][track].Resize(frameCount);

	file.Seek(4, SEEK_CUR);

	if(version >= 0x04)
	{
		file.Seek(4, SEEK_CUR);
	}
	else
	{
		char sAuthID[32];
		file.ReadString(sAuthID, 32);
	}

	int cells = 8;

	if(version == 0x01)
	{
		cells = 6;
	}

	any[] aReplayData = new any[cells];

	for(int i = 0; i < frameCount; i++)
	{
		if(file.Read(aReplayData, cells, 4) >= 0)
		{
			gA_Frames[style][track].Set(i, view_as<float>(aReplayData[origin_x]), 0);
			gA_Frames[style][track].Set(i, view_as<float>(aReplayData[origin_y]), 1);
			gA_Frames[style][track].Set(i, view_as<float>(aReplayData[origin_z]), 2);
		}
	}

	delete gA_Jumps[style][track]; // should be cleared, but better safe than sorry
	gA_Jumps[style][track] = AnalyzeFrames(gA_Frames[style][track]);

	delete file;

	return true;
}

ArrayList AnalyzeFrames(ArrayList list)
{
	if(list.Length < 10)
	{
		return null;
	}
	ArrayList jumps = new ArrayList(6);

	int len = list.Length;
	for(int i = 1; i < len - 4; ++i)
	{
		PathVec lastPos;
		PathVec currentPos;
		PathVec nextPos;
		PathVec nextNextPos;
		list.GetArray(i - 1, lastPos);
		list.GetArray(i, currentPos);
		list.GetArray(i + 1, nextPos);
		list.GetArray(i + 2, nextNextPos);
		if(lastPos.z > currentPos.z && currentPos.z <= nextPos.z && nextPos.z < nextNextPos.z)
		{
			float temp[9];
			temp[0] = currentPos.x + JUMP_BOX_SIZE;
			temp[1] = currentPos.y + JUMP_BOX_SIZE;
			temp[2] = currentPos.z;
			temp[3] = currentPos.x - JUMP_BOX_SIZE;
			temp[4] = currentPos.y - JUMP_BOX_SIZE;
			temp[5] = currentPos.z;

			jumps.PushArray(temp);

			temp[0] = currentPos.x - JUMP_BOX_SIZE;
			temp[1] = currentPos.y + JUMP_BOX_SIZE;
			temp[2] = currentPos.z;
			temp[3] = currentPos.x + JUMP_BOX_SIZE;
			temp[4] = currentPos.y - JUMP_BOX_SIZE;
			temp[5] = currentPos.z;

			jumps.PushArray(temp);
		}
		if(i == 1)
		{
			float temp[9];
			temp[0] = currentPos.x + JUMP_BOX_SIZE;
			temp[1] = currentPos.y + JUMP_BOX_SIZE;
			temp[2] = currentPos.z;
			temp[3] = currentPos.x - JUMP_BOX_SIZE;
			temp[4] = currentPos.y - JUMP_BOX_SIZE;
			temp[5] = currentPos.z;

			jumps.PushArray(temp);

			temp[0] = currentPos.x - JUMP_BOX_SIZE;
			temp[1] = currentPos.y + JUMP_BOX_SIZE;
			temp[2] = currentPos.z;
			temp[3] = currentPos.x + JUMP_BOX_SIZE;
			temp[4] = currentPos.y - JUMP_BOX_SIZE;
			temp[5] = currentPos.z;

			jumps.PushArray(temp);
		}
	}
	SortADTArray(jumps, Sort_Random, Sort_Float);
	// SortADTArrayCustom(jumps, Sort_Jumps);1
	return jumps;
}

/* public int Sort_Jumps(int index1, int index2, Handle array, Handle hndl)
{
	return GetRandomInt(0, 1)
} */

public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle, int track, bool manual)
{
	BotPathClient c = new BotPathClient(client);
	c.GetFrames();
	c.UpdateParticle();
}

public void Shavit_OnTrackChanged(int client, int oldtrack, int newtrack)
{
	BotPathClient c = new BotPathClient(client);
	c.GetFrames();
	c.UpdateParticle();
}

public void Shavit_OnRestart(int client, int track)
{
	BotPathClient c = new BotPathClient(client);
	c.GetFrames();
	c.UpdateParticle();
}

public Action Shavit_OnStart(int client, int track)
{
	BotPathClient c = new BotPathClient(client);
	c.GetFrames();
	c.UpdateParticle();
	return Plugin_Continue;
}

public void Shavit_OnTimeIncrementPost(int client, float time, stylesettings_t stylesettings)
{
	BotPathClient c = new BotPathClient(client);

	if(!c.Enabled || !c.Ghost)
	{
		return;
	}
	int style = c.Style;
	int track = c.Track;

	if(gA_Frames[style][track] == null)
	{
		// PrintToChat(client, "null");
		return;
	}

	if(c.Frames == null)
	{
		// PrintToChat(client, "null null null");
		return;
	}
	int frameCount = c.FrameCount;

	if(c.Frames.Length <= frameCount || frameCount < 1)
	{
		// PrintToChat(client, "length: %i framecount: %i", c.Frames.Length, frameCount);
		return;
	}

	float firstPos[3];

	c.Frames.GetArray(frameCount, firstPos);

	TeleportEntity(c.Particle, firstPos, NULL_VECTOR, NULL_VECTOR);
}

public Action Timer_DrawJumps(Handle timer, int client)
{
	BotPathClient c = new BotPathClient(client);
	if(!c.IsValid() || !c.Enabled || !c.JumpPath)
	{
		return Plugin_Continue;
	}
	int last;
	
	for(int i = c.LastJump; (i < c.Jumps.Length) && (i - c.LastJump <  MAX_BEAMS); ++i)
	{
		// PrintToConsole(client, "i: %i, length: %i", i, c.Jumps.Length);
		float all[6];
		c.Jumps.GetArray(i, all);

		float p1[3]; p1[0] = all[0]; p1[1] = all[1]; p1[2] = all[2];
		float p2[3]; p2[0] = all[3]; p2[1] = all[4]; p2[2] = all[5];

		BP_SetupBeamPoints(p1, p2, gI_BeamSprite, gC_TimerLife.FloatValue, 3.0, gI_CycleColor[client], 10);
		TE_SendToClient(c.Index);

		last = i;
	}
	if(c.LastJump >= c.Jumps.Length - 1)
	{
		c.LastJump = 0;
		UpdateJumpColor(client, MOD_STEP);
	}
	else
	{
		c.LastJump = last;
	}

	return Plugin_Continue;
}



/* Particle stuff from dominos aura menu */
public Action Hook_SetTransmit(int ent, int client)
{
	BotPathClient c = new BotPathClient(client);

	if (GetEdictFlags(ent) & FL_EDICT_ALWAYS)
    {
        SetEdictFlags(ent, (GetEdictFlags(ent) ^ FL_EDICT_ALWAYS));
    }

	if(c.Particle != ent || !c.Enabled || !c.Ghost)
	{
		return Plugin_Handled;	
	}
	return Plugin_Continue;
}

public void RemoveCustomParticle(int client)
{
	BotPathClient c = new BotPathClient(client);
	
	if(!IsValidEntity(c.Particle))
	{
		c.Particle = -1;
		return;
	}
	
	AcceptEntityInput(c.Particle, "DestroyImmediately"); //some particles don't disappear without this
	CreateTimer(1.0, Timer_KillParticle, c.Particle); 
}

public Action Timer_KillParticle(Handle timer, int particleIndex)
{
	if(IsValidEntity(particleIndex))
	{
		AcceptEntityInput(particleIndex, "kill");
	}
}

/* stocks */

void UpdateJumpColor(int client, int stepsize)
{
	BotPathClient c = new BotPathClient(client);

	switch (c.color)
	{
		case rty:
		{
			gI_CycleColor[client][0] = 255; gI_CycleColor[client][1] += stepsize; gI_CycleColor[client][2] = 0;
			
			if(gI_CycleColor[client][0] >= 255 && gI_CycleColor[client][1] >= 255 && gI_CycleColor[client][2] <= 0)
				c.color = ytg;
		}
		case ytg:
		{
			gI_CycleColor[client][0] -= stepsize; gI_CycleColor[client][1] = 255; gI_CycleColor[client][2] = 0;
			
			if(gI_CycleColor[client][0] <= 0 && gI_CycleColor[client][1] >= 255 && gI_CycleColor[client][2] <= 0)
				c.color = gtc;
		}
		case gtc:
		{
			gI_CycleColor[client][0] = 0; gI_CycleColor[client][1] = 255; gI_CycleColor[client][2] += stepsize;
			
			if(gI_CycleColor[client][0] <= 0 && gI_CycleColor[client][1] >= 255 && gI_CycleColor[client][2] >= 255)
				c.color = ctb;
		}
		case ctb:
		{
			gI_CycleColor[client][0] = 0; gI_CycleColor[client][1] -= stepsize; gI_CycleColor[client][2] = 255;
			
			if(gI_CycleColor[client][0] <= 0 && gI_CycleColor[client][1] <= 0 && gI_CycleColor[client][2] >= 255)
				c.color = btm;
		}
		case btm:
		{
			gI_CycleColor[client][0] += stepsize; gI_CycleColor[client][1] = 0; gI_CycleColor[client][2] = 255;
			
			if(gI_CycleColor[client][0] >= 255 && gI_CycleColor[client][1] <= 0 && gI_CycleColor[client][2] >= 255)
				c.color = mtr;
		}
		case mtr:
		{
			gI_CycleColor[client][0] = 255; gI_CycleColor[client][1] = 0; gI_CycleColor[client][2] -= stepsize;
			
			if(gI_CycleColor[client][0] >= 255 && gI_CycleColor[client][1] <= 0 && gI_CycleColor[client][2] <= 0)
				c.color = rty;
		}
	}
	gI_CycleColor[client][3] = 255;
}

stock void Rotate2DPoint(PathVec point, PathVec center, float angle)
{
	PathVec ret;

	angle *= ( FLOAT_PI / 180.0 );

	ret.x = Cosine(angle) * (point.x - center.x) - Sine(angle) * (point.y - center.y) + center.x;
	ret.y = Sine(angle) * (point.x - center.x) + Cosine(angle) * (point.y - center.y) + center.y;

	point.x = ret.x;
	point.y = ret.y;
}

stock void BP_SetupBeamPoints(const float start[3], const float end[3], int ModelIndex, float Life, float Width, const int Color[4], int FadeLength)
{
	TE_Start("BeamPoints");
	TE_WriteVector("m_vecStartPoint", start);
	TE_WriteVector("m_vecEndPoint", end);
	TE_WriteNum("m_nModelIndex", ModelIndex);
	TE_WriteNum("m_nHaloIndex", 0);
	TE_WriteNum("m_nStartFrame", 0);
	TE_WriteNum("m_nFrameRate", 0);
	TE_WriteFloat("m_fLife", Life);
	TE_WriteFloat("m_fWidth", Width);
	TE_WriteFloat("m_fEndWidth", Width);
	TE_WriteFloat("m_fAmplitude", 0.0);
	TE_WriteNum("r", Color[0]);
	TE_WriteNum("g", Color[1]);
	TE_WriteNum("b", Color[2]);
	TE_WriteNum("a", Color[3]);
	TE_WriteNum("m_nSpeed", 0);
	TE_WriteNum("m_nFadeLength", FadeLength);
}

/* notes */
/*
	Horizon static bot path:
	dashed line for walking on ground(origin.z == prevorigin.z)
	red box for starting point(first frame of replay)
	white boxes for jumps (origin.z > prevorigin.z)
	air path lines every X frames
	errors in replay files show up as pink lines ()
	blue sprites for teleports (speed.length > prevspeed.length * 10.0)
	white sprite for end of replays (last frame of replay)

*/

/*
	Horizon replay menu:
	1. auto detect !bp (on)
	3. specific replay
		style list with time and replay owner
	4. turn off
	5. ghost
		white particle trail running replay path
	6. color scheme
		normal
		rainbow
	7. Display
		Jumps only
		none (ghost only)
		full
*/
