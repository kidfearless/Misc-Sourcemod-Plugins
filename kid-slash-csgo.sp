#include <sourcemod>
#include <shavit>
#include <sdkhooks>
#include <sdktools>

ConVar sv_friction = null;
ConVar sv_stopspeed = null;
ConVar sv_accelerate = null;

ConVar gCv_SlashAccelerate;
ConVar gCv_SlashStopSpeed;
ConVar gCv_SlashFriction;


float gF_DefaultStopSpeed = 80.0;
char gS_DefaultStopSpeed[16];
float gF_SlashStopSpeed = 0.0;
char gS_SlashStopSpeed[16];

float gF_DefaultFriction = 4.0;
char gS_DefaultFriction[16];
float gF_SlashFriction = 0.0;
char gS_SlashFriction[16];

float gF_DefaultAccelerate = 5.0;
char gS_DefaultAccelerate[16];
float gF_SlashAccelerate = 500.0;
char gS_SlashAccelerate[16];

bool gB_Enabled[MAXPLAYERS+1];
bool gB_Activated[MAXPLAYERS+1];
//bool gB_SoundStarted[MAXPLAYERS+1];
//bool gB_AllowSliding[MAXPLAYERS+1];

//float gF_Empty = 0.0;

public Plugin myinfo = 
{
	name = "shavit - slash",
	author = "KiD Fearless",
	description = "",
	version = "1.1",
	url = "http://steamcommunity.com/id/kidfearless"
}

public OnPluginStart()
{

//	RegAdminCmd("sm_slash", Command_Slash, ADMFLAG_RCON);
	
	gCv_SlashAccelerate = CreateConVar("sm_slash_accelerate", "500.0", "slashes accelerate");
	gCv_SlashStopSpeed = CreateConVar("sm_slash_stopspeed", "0.0", "slashes stop speed");
	gCv_SlashFriction = CreateConVar("sm_slash_friction", "0.0", "slashes friction");
	
	gCv_SlashAccelerate.AddChangeHook(OnConVarChanged);
	gCv_SlashStopSpeed.AddChangeHook(OnConVarChanged);
	gCv_SlashFriction.AddChangeHook(OnConVarChanged);
	
	AutoExecConfig();
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
	
	OnConfigsExecuted();
	
	
	gCv_SlashAccelerate.GetString(gS_SlashAccelerate, sizeof(gS_SlashAccelerate));
	gCv_SlashFriction.GetString(gS_SlashFriction, sizeof(gS_SlashFriction));
	gCv_SlashStopSpeed.GetString(gS_SlashStopSpeed, sizeof(gS_SlashStopSpeed));
	
	
	gF_SlashAccelerate = gCv_SlashAccelerate.FloatValue;
	gF_SlashFriction = gCv_SlashFriction.FloatValue;
	gF_SlashStopSpeed = gCv_SlashStopSpeed.FloatValue;
	
	
	sv_friction = FindConVar("sv_friction");
	sv_friction.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);
	sv_friction.GetString(gS_DefaultFriction, sizeof(gS_DefaultFriction));
	
	sv_stopspeed = FindConVar("sv_stopspeed");
	sv_stopspeed.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);
	sv_stopspeed.GetString(gS_DefaultStopSpeed, sizeof(gS_DefaultStopSpeed));
	
	sv_accelerate = FindConVar("sv_accelerate");
	sv_accelerate.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);
	sv_accelerate.GetString(gS_DefaultAccelerate, sizeof(gS_DefaultAccelerate));
}

public void OnConfigsExecuted()
{
		sv_friction.GetString(gS_DefaultFriction, sizeof(gS_DefaultFriction));
		gF_DefaultFriction = sv_friction.FloatValue;
		gF_SlashFriction = gCv_SlashFriction.FloatValue;
	
		sv_stopspeed.GetString(gS_DefaultStopSpeed, sizeof(gS_DefaultStopSpeed));
		gF_DefaultStopSpeed = sv_stopspeed.FloatValue;
		gF_SlashStopSpeed = gCv_SlashStopSpeed.FloatValue;
	
		sv_accelerate.GetString(gS_DefaultAccelerate, sizeof(gS_DefaultAccelerate));
		gF_DefaultAccelerate = sv_accelerate.FloatValue;
		gF_SlashAccelerate = gCv_SlashAccelerate.FloatValue;
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gCv_SlashAccelerate.GetString(gS_SlashAccelerate, sizeof(gS_SlashAccelerate));
	gCv_SlashFriction.GetString(gS_SlashFriction, sizeof(gS_SlashFriction));
	gCv_SlashStopSpeed.GetString(gS_SlashStopSpeed, sizeof(gS_SlashStopSpeed));
	
	
	gF_SlashAccelerate = gCv_SlashAccelerate.FloatValue;
	gF_SlashFriction = gCv_SlashFriction.FloatValue;
	gF_SlashStopSpeed = gCv_SlashStopSpeed.FloatValue;
}

public void OnClientPutInServer(int client)
{
	//gB_SoundStarted[client] = false;
//	gB_AllowSliding[client] = false;

	SDKHook(client, SDKHook_PreThinkPost, PreThinkPost);
	
}

public void OnClientDisconnect(int client)
{
	gB_Enabled[client] = false;
	gB_Activated[client] = false;
}

public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle)
{
	char[] sSpecial = new char[128];
	Shavit_GetStyleStrings(newstyle, sSpecialString, sSpecial, 128);

	if(StrContains(sSpecial, "slash", false) == -1)
	{
		gB_Enabled[client] = false;
	}
	else
	{
		gB_Enabled[client] = true;
	}
	
}

public void PreThinkPost(int client)
{
	if(IsPlayerAlive(client))
	{
		sv_friction.FloatValue = (gB_Activated[client])? gF_SlashFriction : gF_DefaultFriction;
		sv_stopspeed.FloatValue = (gB_Activated[client])? gF_SlashStopSpeed : gF_DefaultStopSpeed;
		sv_accelerate.FloatValue = (gB_Activated[client])? gF_SlashAccelerate : gF_DefaultAccelerate;
	}
}

public Action OnPlayerRunCmd(int client, int &buttons)
{

	if(!IsPlayerAlive(client))
	{
		return Plugin_Continue;
	}
	
	if(!gB_Enabled[client])
	{
		return Plugin_Continue;
	}
	
	
	if((buttons & IN_DUCK == IN_DUCK) && (GetEntityFlags( client ) & FL_ONGROUND == FL_ONGROUND))
	{
		gB_Activated[client] = true;
		
		SetEntPropFloat(client, Prop_Send, "m_flStepSize", 68.0);
		sv_friction.ReplicateToClient(client, gS_SlashFriction);
		sv_stopspeed.ReplicateToClient(client, gS_SlashStopSpeed);
		
		//if(!gB_SoundStarted[client])
		//{
		//	Play_SlideSound(client);
		//}
		//gB_AllowSliding[client] = true;
		sv_accelerate.ReplicateToClient(client, gS_SlashAccelerate);
		
	}
	else if(gB_Activated[client])
	{
		if((buttons & IN_DUCK != IN_DUCK))
		{
			buttons |= IN_JUMP;
		}
		
		SetEntPropFloat(client, Prop_Send, "m_flStepSize", 18.0);
		sv_friction.ReplicateToClient(client, gS_DefaultFriction);
		sv_stopspeed.ReplicateToClient(client, gS_DefaultStopSpeed);
		sv_accelerate.ReplicateToClient(client, gS_DefaultAccelerate);
		
		gB_Activated[client] = false;
		//gB_SoundStarted[client] = false;
		//gB_AllowSliding[client] = false;
		
		//Stop_SlideSound(client);
		
		
		
		//SetEntityMoveType(client, MOVETYPE_WALK);
	}

	
	return Plugin_Continue;
}

















