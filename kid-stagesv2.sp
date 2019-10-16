#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <mapzonelib>
#define USES_CHAT_COLORS
#include <shavit>
#include <tr_trigger>

#define MAXSTAGES 64
#define MAXSTYLES 32
#define HUDWIDTH 25
#define SERVER 0


enum struct time_t
{
	float fPb;
	float fTime;
}

time_t gT_ClientStage[MAXPLAYERS][MAXSTYLES][MAXSTAGES];
float gF_BestTime[MAXSTYLES][MAXSTAGES];
char gS_Map[PLATFORM_MAX_PATH];
int gI_StageCount = 1;

int gI_MapID = -1;

Database gDB_Stages;

bool gB_Late;

public Plugin myinfo =
{
	name = "shavit Stages",
	author = "KiD Fearless",
	description = "Stage plugin for shavits bhop timer",
	version = "2.2",
	url = "https://steamcommunity.com/id/kidfearless/"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	gB_Late = late;
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_stages", Command_Stages, "Teleports to a stage or opens the menu");
	RegConsoleCmd("sm_stage", Command_Stages, "Teleports to a stage or opens the menu");
	//RegConsoleCmd("sm_t", Command_Stages, "Teleports you to your current stage");

	RegAdminCmd("sm_stagezones", Command_StageZones, ADMFLAG_CHANGEMAP);
	RegAdminCmd("sm_stagezone", Command_StageZones, ADMFLAG_CHANGEMAP);
	RegAdminCmd("sm_zonestages", Command_StageZones, ADMFLAG_CHANGEMAP);
	RegAdminCmd("sm_zonestage", Command_StageZones, ADMFLAG_CHANGEMAP);
	RegAdminCmd("sm_addstage", Command_StageZones, ADMFLAG_CHANGEMAP);

	HookEvent("cs_win_panel_match", Event_MatchEnd);
	char error[256];

	if(SQL_CheckConfig("shavit"))
	{
		gDB_Stages = SQL_Connect("shavit", true, error, 255);

		if(gDB_Stages == null)
		{
			SetFailState("Shavit-Stages startup failed. Reason: %s", error);
		}
	}
	else
	{
		SetFailState("Shavit-Stages startup failed. Reason: Could not find shavit database connection information.");
	}

	if(error[0] != 0)
	{
		LogError(error);
	}

	if(gB_Late)
	{

		if(LibraryExists("mapzonelib"))
		{
			MapZone_OnZonesLoaded();
		}
		QueryStageTimes();
	}
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "mapzonelib"))
	{
		MapZone_RegisterZoneGroup("stages");
	}
}

public Action Command_StageZones(int client, int args)
{
	char stage[6];
	IntToString(gI_StageCount, stage, 6);
	MapZone_SetNewZoneBaseName(client, "stages", stage, false);
	MapZone_ShowMenu(client, "stages");
	return Plugin_Handled;
}

public void MapZone_OnZoneRemoved(const char[] sZoneGroup, const char[] sZoneName, MapZoneType type, int iRemover)
{
	if(StrEqual(sZoneGroup, "stages"))
	{
		int stage = StringToInt(sZoneName);
		if(stage == gI_StageCount)
		{
			--gI_StageCount;
		}
		if(iRemover > 0)
		{
			char sStage[6];
			IntToString(gI_StageCount, sStage, 6);
			MapZone_SetNewZoneBaseName(iRemover, "stages", sStage, false);
		}
	}
}

public void MapZone_OnZoneCreated(const char[] sZoneGroup, const char[] sZoneName, MapZoneType type, int iCreator)
{
	if(StrEqual(sZoneGroup, "stages"))
	{
		gI_StageCount = GetGroupSize("stages") + 1;
		MapZone_SetZoneVisibility(sZoneGroup, sZoneName, ZoneVisibility_WhenEditing);
		if(iCreator > 0)
		{
			char sStage[6];
			IntToString(gI_StageCount, sStage, 6);
			MapZone_SetNewZoneBaseName(iCreator, "stages", sStage, false);
		}
	}
}

public void OnMapStart()
{
	gI_StageCount = 0;
	GetCurrentMap(gS_Map, sizeof(gS_Map));
	GetMapDisplayName(gS_Map, gS_Map, sizeof(gS_Map));
}

/* Called after configs are executed and mapzones are loaded */
public void MapZone_OnZonesLoaded()
{
	ResetAllTimes();
	gI_StageCount = GetGroupSize("stages") + 1;//+1 for the end zone.
}

public void Ent_OnMapIDReady(int mapid)
{
	gI_MapID = mapid;
	DebugPrint("$mapid: %i, stagecount: %i$", gI_MapID, gI_StageCount);
	QueryStageTimes();
}

void QueryStageTimes()
{
	DebugPrint("$mapid: %i, stagecount: %i$", gI_MapID, gI_StageCount);
	if(gI_MapID > 0)
	{
		char query[256];
		FormatEx(query, 256, "SELECT StageStyle, ZoneIndex, StageTime FROM stage_times WHERE MapID = %i", gI_MapID);
		gDB_Stages.Query(GetBestTimesCallback, query);
	}
}

public void GetBestTimesCallback(Database db, DBResultSet results, const char[] error, bool once)
{
	if(error[0] != 0)
	{
		LogError("[SM] - (GetBestTimesCallback) - %s", error);
	}
	DebugPrint("$$$ GetBestTimesCallback $$$");
	while(results.FetchRow())
	{
		int style = results.FetchInt(0);
		int stage = results.FetchInt(1);
		float time = results.FetchFloat(2);
		gF_BestTime[style][stage] = time;
		DebugPrint("$$$ GetBestTimesCallback: style: %i, stage: %i, time: %f $$$", style, stage, time);
	}
}

public void Event_MatchEnd(Event event, const char[] name, bool dontBroadcast)
{
	OnMatchEnd();
}

public void OnMatchEnd()
{
	DebugPrint("$$$ OnMatchEnd(), Mapid: %i $$$", gI_MapID);
	if(gI_MapID > 0)
	{
		char query[256];
		FormatEx(query, 256, "DELETE * FROM stage_times WHERE MapID = %i;", gI_MapID);
		gDB_Stages.Query(DeleteCallback, query);
	}
}

stock void DeleteCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if(error[0] != 0)
	{
		LogError("[SM] - (DeleteCallback) - %s", error);
	}
	char query[256];
	for(int style = 0; style < MAXSTYLES; ++style)
	{
		DebugPrint("$$$ DeleteCallback, style: %i, stagecount: %i, time: %f $$$", style, gI_StageCount, gF_BestTime[style][gI_StageCount-1]);
		if(gF_BestTime[style][gI_StageCount-1] != 0.0)
		{
			for(int stage = 1; stage < gI_StageCount; ++stage)
			{
				FormatEx(query, 256, "INSERT INTO stage_times(StageStyle, ZoneIndex, StageTime, MapID) VALUES(%i, %i, %f, %i);", style, stage, gF_BestTime[style][stage], gI_MapID);
				DebugPrint("$$$ query: %s $$$", query);
				gDB_Stages.Query(NullCallback, query);
			}
		}
	}
}

stock void NullCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if(error[0] != 0)
	{
		LogError("[SM] - (NullCallback) - %s", error);
	}
}

public void OnClientDisconnect(int client)
{
	ResetClientTimes(client);
}

public void MapZone_OnClientEnterZone(int client, const char[] sZoneGroup, const char[] sZoneName)
{
	if(StrContains(sZoneGroup, "stages", false) != -1)
	{
		OnEnterStage(client, StringToInt(sZoneName));
	}
}

void OnEnterStage(int client, int stage)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) || (Shavit_GetTimerStatus(client) != Timer_Running) || Shavit_IsPracticeMode(client) || (Shavit_GetClientTrack(client) != Track_Main))
	{
		return;
	}

	char sTime[64], pbTime[64], wrTime[64], buffer[128];
	int style = Shavit_GetBhopStyle(client);
	float time = Shavit_GetClientTime(client);

	// Update client pb
	if(gT_ClientStage[client][style][stage].fPb == 0.0)
	{
		gT_ClientStage[client][style][stage].fPb = time;
	}

	//update clients time
	gT_ClientStage[client][style][stage].fTime = time;

	FormatStageSeconds(time, sTime, sizeof(sTime));

	float pbDiff = time - gT_ClientStage[client][style][stage].fPb;
	FormatStageSeconds(pbDiff, pbTime, sizeof(pbTime));

	if(gF_BestTime[style][stage] == 0.0	)//the wr hasn't been recorded yet, use theirs
	{
		gF_BestTime[style][stage] = time;
	}
	float wrDiff = time - gF_BestTime[style][stage];

	FormatStageSeconds(wrDiff, wrTime, sizeof(wrTime));
	FormatEx(buffer, sizeof(buffer), "Stage %i {default}[T %s | {yellow}PB %s%s{yellow} | {bluegrey}WR %s%s{default}]", stage, sTime, (pbDiff > 0.0?"+{lightred}":"-{lime}"), pbTime, (wrDiff > 0.0? "+{lightred}":"-{lime}"), wrTime);

	ColorPrintToChat(client, buffer);
}

public void Shavit_OnFinish(int client, int style, float time, int jumps, int strafes, float sync, int track, float oldtime, float perfs)
{
	if(gI_StageCount > 1)//non-linear map
	{
		float fTime = gT_ClientStage[client][style][gI_StageCount].fTime;//readibility pls
		gT_ClientStage[client][style][gI_StageCount].fTime = time;
		if(time <= fTime || fTime == 0.0)//improved stage time
		{
			UpdateClientPB(client, style);
		}
		if(fTime <= gF_BestTime[style][gI_StageCount])
		{
			UpdateStyleWR(client, style);
		}
	}
}

public void Shavit_OnWorldRecord(int client, int style, float time, int jumps, int strafes, float sync, int track, float oldwr, float oldtime, float perfs)
{
	if(gI_StageCount > 1)//non-linear map
	{
		UpdateStyleWR(client, style);
	}
}

public Action Command_Stages(int client, int args)
{
	if(args < 1)
	{
		DisplayStageMenu(client);
	}
	else
	{
		char stage[6];
		float position[3];
		GetCmdArg(1, stage, sizeof(stage));

		MapZone_GetZonePosition("stages", stage, position);

		if(!IsNullVector(position))
		{
			Shavit_SetPracticeMode(client, true, true);
			TeleportEntity(client, position, NULL_VECTOR , NULL_VECTOR);
			Shavit_PrintToChat(client, "Teleported to stage: %s", stage);
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

	for(int i = 1; i < gI_StageCount; ++i)//stages start at 1, length also starts at 1
	{
		char buffer[12];
		char stage[6];
		Format(stage, sizeof(stage), "%i", (i));
		Format(buffer, sizeof(buffer), "Stage: %i", (i));

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
			char stage[6];
			float position[3];
			menu.GetItem(param2, stage, sizeof(stage));

			MapZone_GetZonePosition("stages", stage, position);
			if(!IsNullVector(position))
			{
				Shavit_SetPracticeMode(param1, true, true);
				TeleportEntity(param1, position, NULL_VECTOR , NULL_VECTOR);
				Shavit_PrintToChat(param1, "Teleported to stage: %s", stage);
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


stock void UpdateStyleWR(int client, int style)
{
	for(int i = 0; i < MAXSTAGES; ++i)
	{
		gF_BestTime[style][i] = gT_ClientStage[client][style][i].fTime;
	}
}

stock void UpdateClientPB(int client, int style)
{
	for(int i = 0; i < MAXSTAGES; ++i)
	{
		gT_ClientStage[client][style][i].fPb = gT_ClientStage[client][style][i].fTime;
	}
}

stock void ResetClientTimes(int client)
{
	for(int style = 0; style < MAXSTYLES; ++style)
	{
		for(int stage = 0; stage < MAXSTAGES; ++stage)
		{
			gT_ClientStage[client][style][stage].fTime = 0.0;
			gT_ClientStage[client][style][stage].fPb = 0.0;
		}
	}
}
stock void ResetWRTimes()
{
	for(int style = 0; style < MAXSTYLES; ++style)
	{
		for(int stage = 0; stage < MAXSTAGES; ++stage)
		{
			gF_BestTime[style][stage] = 0.0;
		}
	}
}

stock void ResetAllTimes()
{
	for(int style = 0; style < MAXSTYLES; ++style)
	{
		for(int stage = 0; stage < MAXSTAGES; ++stage)
		{
			for(int client = 1; client <= MaxClients; ++client)
			{
				gT_ClientStage[client][style][stage].fPb = 0.0;
				gT_ClientStage[client][style][stage].fTime = 0.0;
			}
			gF_BestTime[style][stage] = 0.0;
		}
	}
}

//Taken from slidy's ssj
stock void FormatColors(char[] buffer, int size, bool colors, bool escape)
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

stock void ColorPrintToChat( int client, char[] format, any ... )
{
	char buffer[512];
	VFormat( buffer, sizeof(buffer), format, 3 );
	FormatColors( buffer, sizeof(buffer), true, false );
	Shavit_PrintToChat( client, buffer );
}

stock int GetGroupSize(const char[] group, bool bIncludeClusters=true)
{
	ArrayList temp = MapZone_GetGroupZones(group, bIncludeClusters);
	if(temp == null)
	{
		return 0;
	}
	int length = temp.Length;
	delete temp;
	return length;
}

stock void CreateHudText()
{
	const float	posx =		0.9;
	const float	posy =		0.1;
	const float	time =		0.2;
	const float	fxtime =	0.0;
	const float	fadein =	0.0;
	const float	fadeout =	0.0;

	const int r = 				255;
	const int g = 				255;
	const int b = 				255;
	const int a = 				255;
	const int effect = 			0;
	SetHudTextParams(posx, posy, time, r, g, b, a, effect, fxtime, fadein, fadeout);
}

void DebugPrint( const char[] message, any ... )
{
	#if defined DEBUG1
	char buffer[254];

	VFormat(buffer, sizeof(buffer), message, 2);
	PrintToServer(buffer);
	LogMessage(buffer);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			PrintToConsole(i, "%s", buffer);
		}
	}
	#endif
}

stock void FormatStageSeconds(float time, char[] newtime, int newtimesize, bool precise = true)
{
	time = FloatAbs(time);

	int iRounded = RoundToFloor(time);
	float fSeconds = (iRounded % 60) + time - iRounded;

	char sSeconds[8];
	FormatEx(sSeconds, 8, precise? "%.03f":"%.01f", fSeconds);

	if(time < 60.0)
	{
		strcopy(newtime, newtimesize, sSeconds);
	}

	else
	{
		int iMinutes = (iRounded / 60);

		if(time < 3600.0)
		{
			FormatEx(newtime, newtimesize, "%d:%s%s", iMinutes, (fSeconds < 10)? "0":"", sSeconds);
		}
		else
		{
			iMinutes %= 60;
			int iHours = (iRounded / 3600);

			FormatEx(newtime, newtimesize, "%d:%s%d:%s%s", iHours, (iMinutes < 10)? "0":"", iMinutes, (fSeconds < 10)? "0":"", sSeconds);
		}
	}
}