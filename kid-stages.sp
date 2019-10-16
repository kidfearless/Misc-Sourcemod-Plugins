#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <mapzonelib>
#include <convert>
#define USES_CHAT_COLORS
#include <shavit>

#define MAXSTAGES 64
#define DEFAULTREPLAYINDEX 1


float gF_ClientPB[MAXPLAYERS+1][TRACKS_SIZE][MAXSTAGES][STYLE_LIMIT];
float gF_ClientTime[MAXPLAYERS+1][TRACKS_SIZE][MAXSTAGES][STYLE_LIMIT];
float gF_BestTime[TRACKS_SIZE][MAXSTAGES][STYLE_LIMIT];
bool gB_ZonesLoaded;
bool gB_Late = false;
any gA_StyleSettings[STYLE_LIMIT][STYLESETTINGS_SIZE];
char gS_ChatStrings[CHATSETTINGS_SIZE][128];
int gI_LastStage[MAXPLAYERS+1];
int replayBot = 1;
int stageCount = 1;
public Plugin myinfo =
{
	name = "shavit Stages",
	author = "KiD Fearless",
	description = "Stage plugin for shavits bhop timer",
	version = "1.1",
	url = "https://steamcommunity.com/id/kidfearless/"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	gB_Late = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_stages", Command_Stages, "Teleports to a stage or opens the menu");
	RegConsoleCmd("sm_stage", Command_Stages, "Teleports to a stage or opens the menu");
	//RegConsoleCmd("sm_t", Command_Stages, "Teleports you to your current stage");
	
	RegAdminCmd("sm_stagezones", Command_StageZones, ADMFLAG_CHANGEMAP);
	MapZone_RegisterZoneGroup("stages");
	if(gB_Late)
	{
		OnMapStart();
		Shavit_OnStyleConfigLoaded(-1);
		Shavit_OnChatConfigLoaded();
		MapZone_OnZonesLoaded();
	}
}

public Action Command_StageZones(int client, int args)
{
	MapZone_SetNewZoneBaseName(client, "stages", Convert_IntToString(stageCount), false);
	MapZone_ShowMenu(client, "stages");
	return Plugin_Handled;
}

public void MapZone_OnZoneRemoved(const char[] sZoneGroup, const char[] sZoneName, MapZoneType type, int iRemover)
{
	if(StrEqual(sZoneGroup, "stages"))
	{
		int stage = StringToInt(sZoneName);
		if(stage == stageCount)
		{
			--stageCount;
		}
	}
}

public void MapZone_OnZoneCreated(const char[] sZoneGroup, const char[] sZoneName, MapZoneType type, int iCreator)
{
	if(StrEqual(sZoneGroup, "stages"))
	{
		int stage = StringToInt(sZoneName);
		if(stage == stageCount)
		{
			++stageCount;
		}
		else if (stage > stageCount)
		{
			stageCount = stage + 1;
		}
		MapZone_SetZoneVisibility(sZoneGroup, sZoneName, ZoneVisibility_WhenEditing);
	}
}

public void OnMapStart()
{
	replayBot = DEFAULTREPLAYINDEX;
}

public void MapZone_OnZonesLoaded()
{
	
	stageCount = GetGroupSize("stages") + 1;
	gB_ZonesLoaded = true;
}

public void OnMapEnd()
{
	gB_ZonesLoaded = false;
	stageCount = 0;
	ResetAllTimes();
}

public void OnClientDisconnect(int client)
{
	ResetClientTimes(client);
}

public void Shavit_OnReplayStart(int replay)
{
	replayBot = replay;
	gI_LastStage[replayBot] = 0;
}

public void Shavit_OnChatConfigLoaded()
{
	for(int i = 0; i < CHATSETTINGS_SIZE; ++i)
	{
		Shavit_GetChatStrings(i, gS_ChatStrings[i], 128);
	}
}

public void Shavit_OnStyleConfigLoaded(int styles)
{
	if(styles == -1)
	{
		styles = Shavit_GetStyleCount();
	}

	for(int i = 0; i < styles; ++i)
	{
		Shavit_GetStyleSettings(i, gA_StyleSettings[i]);	
	}
}

public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle)
{
	gI_LastStage[client] = 0;
}

public void MapZone_OnClientEnterZone(int client, const char[] sZoneGroup, const char[] sZoneName)
{
	if(StrContains(sZoneGroup, "stages", false) != -1)
	{
		OnEnterStage(client, StringToInt(sZoneName), Track_Main);
	}
	else if(StrContains(sZoneGroup, "bonus", false) != -1)
	{
		OnEnterStage(client, StringToInt(sZoneName), Track_Bonus);
	}
}

void OnEnterStage(int client, int stage, int track)
{
	int style;
	float time, pbDiff, wrDiff;
	char sTime[64], pbTime[64], wrTime[64], buffer[128];

	

	if(client != replayBot)
	{
		if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client) || (Shavit_GetTimerStatus(client) != Timer_Running) || (Shavit_IsPracticeMode(client)) || (track != Shavit_GetClientTrack(client)))
		{
			return;
		}

		style = Shavit_GetBhopStyle(client);
		time = Shavit_GetClientTime(client);

		if(stage - gI_LastStage[client] == 1) //incremented stages normally
		{
			gF_ClientTime[client][track][stage][style] = time;
				

			FormatEx(buffer, sizeof(buffer), "Stage %i {default}[ ", stage);

			FormatSeconds(gF_ClientTime[client][track][stage][style], sTime, sizeof(sTime));
			Format(buffer, sizeof(buffer), "%s{default}T %s | ", buffer, sTime);

			if(gF_ClientPB[client][track][stage][style] != 0.0)
			{
				pbDiff = time - gF_ClientPB[client][track][stage][style];
				FormatSeconds(pbDiff, pbTime, sizeof(pbTime));
				Format(buffer, sizeof(buffer), "%s{yellow}PB %s%s{yellow} | ", buffer, (pbDiff > 0.0?"+{lightred}":"-{lime}"), pbTime);
			}
			if(gF_BestTime[track][stage][style] != 0.0)
			{
				wrDiff = time - gF_BestTime[track][stage][style];
				FormatSeconds(wrDiff, wrTime, sizeof(wrTime));
				Format(buffer, sizeof(buffer), "%s{bluegrey}WR %s%s{default} ]", buffer, (wrDiff > 0.0? "+{lightred}":"-{lime}"), wrTime);
			}
			
			ColorPrintToChat(client, buffer);
			gI_LastStage[client] = stage;
		}
		else if(stage - gI_LastStage[client] > 1)//skipped a stage
		{
			gI_LastStage[client] = 0;
		}
	}
	else
	{
		style = Shavit_GetReplayBotStyle(replayBot);
		track = Shavit_GetReplayBotTrack(replayBot);

		if(stage - gI_LastStage[replayBot] == 1)// incremented stages normally
		{
			time = Shavit_GetReplayTime(style, track);
		
			gF_ClientTime[replayBot][track][stage][style] = time;

			gF_BestTime[track][stage][style] = time;
			gI_LastStage[replayBot] = stage;
		}
		else if(stage - gI_LastStage[replayBot] > 1)//skipped a stage
		{
			gI_LastStage[replayBot] = 0;
		}
	}
}

public void Shavit_OnFinish(int client, int style, float time, int jumps, int strafes, float sync, int track, float oldtime, float perfs)
{
	if(time <= oldtime)
	{
		UpdateClientPB(client, style, track);
	}
	else if(gF_ClientPB[client][track][1][style] == 0.0)
	{
		UpdateClientPB(client, style, track);
	}
}

public void Shavit_OnWorldRecord(int client, int style, float time, int jumps, int strafes, float sync, int track, float oldwr, float oldtime, float perfs)
{
	UpdateStyleWR(client, style, track);
}

public void Shavit_OnRestart(int client, int track)
{
	gI_LastStage[client] = 0;
	ResetClientTimes(client);
}

public Action Command_Stages(int client, int args)
{
	if(args < 1)
	{
		DisplayStageMenu(client);
	}
	else
	{
		char stage[2];
		float position[3];
		GetCmdArg(1, stage, sizeof(stage));

		MapZone_GetZonePosition("stages", stage, position);

		if(!IsNullVector(position))
		{
			Shavit_SetPracticeMode(client, true, true);
			TeleportEntity(client, position, NULL_VECTOR , NULL_VECTOR);
			Shavit_PrintToChat(client, "Teleported to %s", stage);
		}
		else
		{
			Shavit_PrintToChat(client, "Error: Unable To Find Stage");
		}
	}
	return Plugin_Handled;
}

public Action DisplayStageMenu(int client)
{
	Menu menu = new Menu(StageHandler);
	menu.SetTitle("Select A Stage\nYOU WILL BE PUT IN PRACTICE MODE!");

	for(int i = 0; i < (stageCount - 1); ++i)//stages start at 1, length also starts at 1
	{
		char buffer[12];
		char stage[2];
		Format(stage, sizeof(stage), "%i", (i+1));
		Format(buffer, sizeof(buffer), "Stage: %i", (i+1));

		menu.AddItem(stage, buffer);
	}

	
	menu.ExitButton = true;
	menu.Display(client, 60);
 
	return Plugin_Handled;
}

public int StageHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char stage[2];
			float position[3];
			menu.GetItem(param2, stage, sizeof(stage));

			MapZone_GetZonePosition("stages", stage, position);
			if(!IsNullVector(position))
			{
				Shavit_SetPracticeMode(param1, true, true);
				TeleportEntity(param1, position, NULL_VECTOR , NULL_VECTOR);
				Shavit_PrintToChat(param1, "Teleported to %s", stage);
			}
			else
			{
				Shavit_PrintToChat(param1, "Error: Unable To Find Stage");
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
 
	return 1;
}

void UpdateStyleWR(int client, int style, int track)
{
	for(int i = 0; i < MAXSTAGES; ++i)
	{
		gF_BestTime[track][i][style] = gF_ClientTime[client][track][i][style];
	}
}

void UpdateClientPB(int client, int style, int track)
{
	for(int i = 0; i < MAXSTAGES; ++i)
	{
		gF_ClientPB[client][track][i][style] = gF_ClientTime[client][track][i][style];
	}
}

stock void ResetClientTimes(int client)
{
	for(int track = 0; track < TRACKS_SIZE; ++track)
	{
		for(int stage = 0; stage < MAXSTAGES; ++stage)
		{
			int styleCount = Shavit_GetStyleCount();
			for(int style = 0; style < styleCount; ++style)
			{
				gF_ClientTime[client][track][stage][style] = 0.0;
			}
		}
	}
}
stock void ResetWRTimes()
{
	for(int track = 0; track < TRACKS_SIZE; ++track)
	{
		for(int stage = 0; stage < MAXSTAGES; ++stage)
		{
			int styleCount = Shavit_GetStyleCount();
			for(int style = 0; style < styleCount; ++style)
			{
				gF_BestTime[track][stage][style] = 0.0;
			}
		}
	}
}
stock void ResetAllTimes()
{
	for(int client = 0; client < MaxClients; ++client)
	{
		for(int track = 0; track < TRACKS_SIZE; ++track)
		{	
			for(int stage = 0; stage < MAXSTAGES; ++stage)
			{
				int styleCount = Shavit_GetStyleCount();
				for(int style = 0; style < styleCount; ++style)
				{
					gF_ClientPB[client][track][stage][style] = 0.0;
					gF_ClientTime[client][track][stage][style] = 0.0;
				}
			}
		}
	}
	ResetWRTimes();
}

//Taken from slidy's ssj
void FormatColors(char[] buffer, int size, bool colors, bool escape)
{
	if(colors)
	{
		static EngineVersion engine = Engine_Unknown;
		if( engine == Engine_Unknown )
		{
			engine = GetEngineVersion();
		}
	
		for(int i = 0; i < sizeof(gS_GlobalColorNames); i++)
		{
			ReplaceString(buffer, size, gS_GlobalColorNames[i], gS_GlobalColors[i]);
		}

		if(engine == Engine_CSGO)
		{
			for(int i = 0; i < sizeof(gS_CSGOColorNames); i++)
			{
				ReplaceString(buffer, size, gS_CSGOColorNames[i], gS_CSGOColors[i]);
			}
		}

		ReplaceString(buffer, size, "^", "\x07");
		ReplaceString(buffer, size, "{RGB}", "\x07");
		ReplaceString(buffer, size, "&", "\x08");
		ReplaceString(buffer, size, "{RGBA}", "\x08");
	}

	if(escape)
	{
		ReplaceString(buffer, size, "%%", "");
	}
}

void ColorPrintToChat( int client, char[] format, any ... )
{
	char buffer[512];
	VFormat( buffer, sizeof(buffer), format, 3 );
	FormatColors( buffer, sizeof(buffer), true, false );
	Shavit_PrintToChat( client, buffer );
}

int GetGroupSize(const char[] group, bool bIncludeClusters=true)
{
	return MapZone_GetGroupZones(group, bIncludeClusters).Length;
}