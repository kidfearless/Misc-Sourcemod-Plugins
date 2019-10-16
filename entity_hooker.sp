#include <sourcemod>
#include <sdkhooks>
#include <tr_trigger>
#include <shavit>

#define _MAX_ZONES 24

int gI_HaloSprite = -1;

enum struct zone_cache
{
	int iZoneType;
	int iZoneTrack; // 0 - main, 1 - bonus
	int iEntityID;
}

#define Zone_Stage 11

Database gDB_EntHook = null;

bool gB_MenuOpen[MAXPLAYERS];
bool gB_Held[MAXPLAYERS];
bool gB_Staging[MAXPLAYERS];

char gS_ClassName[MAXPLAYERS][64];
char gS_TargetName[MAXPLAYERS][64];
char gS_Map[PLATFORM_MAX_PATH];

Menu gM_SelectorMenu;
Menu gM_StageMenu;

int gI_Entity[MAXPLAYERS];
int gI_Track[MAXPLAYERS];
int gI_Type[MAXPLAYERS];
int gI_Stage[MAXPLAYERS];	
int gI_MapID = -1;

Handle gH_OnMapIDReady;


//2start/endzones
zone_cache gZ_Zones[_MAX_ZONES];

public Plugin myinfo =
{
	name = "Entity Hooker",
	author = "KiD Fearless",
	description = "N/A",
	version = "1.1",
	url = "https://steamcommunity.com/id/kidfearless/"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Ent_GetCurrentMapID", Native_GetCurrentMapID);

	return APLRes_Success;
}

public void OnPluginStart()
{
	RegAdminCmd("sm_enthook", Command_EntHook, ADMFLAG_RCON, "Add entity to hook list");
	RegAdminCmd("sm_hookmenu", Command_HookMenu, ADMFLAG_RCON, "Add entity to hook list");
	RegAdminCmd("sm_entmenu", Command_HookMenu, ADMFLAG_RCON, "Add entity to hook list");
	
	gH_OnMapIDReady = CreateGlobalForward("Ent_OnMapIDReady", ET_Event, Param_Cell);
	char sError[255];

	if(SQL_CheckConfig("shavit"))
	{
		gDB_EntHook = SQL_Connect("shavit", true, sError, 255);

		if(gDB_EntHook == null)
		{
			SetFailState("Ent_Hook startup failed. Reason: %s", sError);
		}
	}

	BuildMenu();
}

public void OnPluginEnd()
{
	delete gDB_EntHook;
	delete gM_SelectorMenu;
	delete gM_StageMenu;
}

public void OnMapStart()
{
	gI_HaloSprite = PrecacheModel("sprites/glow01.vmt", true);

	for(int i = 0; i < _MAX_ZONES; ++i)
	{
		ClearCache(i);
	}
	gI_MapID = -1;
	GetCurrentMap(gS_Map, PLATFORM_MAX_PATH);
	GetMapDisplayName(gS_Map, gS_Map, PLATFORM_MAX_PATH);
	gDB_EntHook.Escape(gS_Map, gS_Map, sizeof(gS_Map));
	char query[256];
	//FormatEx(query, sizeof(query), "INSERT INTO ent_maps (Mapname) VALUES ('%s');", gS_Map);
	FormatEx(query, sizeof(query), "SELECT Count(*) FROM ent_maps WHERE Mapname = '%s';", gS_Map);
	gDB_EntHook.Query(CheckMapCallback, query, _, DBPrio_High);

	FormatEx(query, sizeof(query), "SELECT ent_zones.HammerID, ent_zones.Track, ent_zones.Type FROM ent_zones LEFT JOIN ent_maps ON ent_zones.MapID = '%i';", gI_MapID);
	gDB_EntHook.Query(MapStartCallback, query, _, DBPrio_High);
}

public void OnClientDisconnect(int client)
{
	ResetClient(client);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	for(int i = 0; i < _MAX_ZONES; ++i)
	{
		if(entity == gZ_Zones[i].iEntityID)
		{
			if(gZ_Zones[i].iZoneTrack == Track_Main)
			{
				if(gZ_Zones[i].iZoneType == Zone_Start)
				{
					SetEntPropString(entity, Prop_Data, "m_iName", "mod_zone_start");
				}
				else if(gZ_Zones[i].iZoneType == Zone_End)
				{
					SetEntPropString(entity, Prop_Data, "m_iName", "mod_zone_end");
				}
			}
			else if(gZ_Zones[i].iZoneTrack == Track_Bonus)
			{
				if(gZ_Zones[i].iZoneType == Zone_Start)
				{
					SetEntPropString(entity, Prop_Data, "m_iName", "mod_zone_bonus_1_start");
				}
				else if(gZ_Zones[i].iZoneType == Zone_End)
				{
					SetEntPropString(entity, Prop_Data, "m_iName", "mod_zone_bonus_1_end");
				}
			}
		}
	}
}

public Action Command_EntHook(int client, int args)
{
	gI_Entity[client] = GetTriggerAtAim(client);
	if(gI_Entity[client] < 1)
	{
		ReplyToCommand(client, "ERROR: Please select a valid entity");
		return Plugin_Handled;
	}
	PrintEntities(gI_Entity[client], client);
	return Plugin_Handled;
}

public Action Command_HookMenu(int client, int args)
{
	gB_MenuOpen[client] = true;
	gM_SelectorMenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int Native_GetCurrentMapID(Handle handler, int numParams)
{
	return gI_MapID;
}

public void CheckMapCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if(error[0] != 0)
	{
		LogError("[SM] - (CheckMapCallback) - %s", error);
	}
	if(results.FetchRow())//valid table results check
	{
		if(results.FetchInt(0) == 0)// Map not found, insert into database
		{
			char query[128];
			FormatEx(query, sizeof(query), "INSERT INTO ent_maps (Mapname) VALUES ('%s');", gS_Map);
			gDB_EntHook.Query(InsertMapCallback, query, _, DBPrio_High);
		}
		else //map found grab it's id
		{
			char query[128];
			FormatEx(query, sizeof(query), "SELECT ID FROM ent_maps WHERE MapName = '%s'", gS_Map);
			gDB_EntHook.Query(GetMapCallback, query, _, DBPrio_High);
		}
	}
	else
	{
		LogError("[SM] - (CheckMapCallback) - WARNING: FETCH ROW RETURNED FALSE");
	}
}

public void InsertMapCallback(Database db, DBResultSet results, const char[] error, bool once)
{
	if(error[0] != 0)
	{
		LogError("[SM] - (InsertMapCallback) - %s", error);
	}

	char query[128];
	FormatEx(query, sizeof(query), "SELECT ID FROM ent_maps WHERE MapName = '%s'", gS_Map);
	gDB_EntHook.Query(GetMapCallback, query, _, DBPrio_High);
}

stock void GetMapCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if(error[0] != 0)
	{
		LogError("[SM] - (GetMapCallback) - %s", error);
	}
	if(results.FetchRow())
	{
		gI_MapID = results.FetchInt(0);
		if(gI_MapID == 0)
		{
			gI_MapID = -1;
			LogError("[SM] - (GetMapCallback) - WARNING: INVALID MAP ID");
		}
		else
		{
			Call_StartForward(gH_OnMapIDReady);
			Call_PushCell(gI_MapID);
			Call_Finish();
		}
	}
	else
	{
		gI_MapID = -1;
		LogError("[SM] - (GetMapCallback) - WARNING: FETCH ROW RETURNED FALSE");
	}
}

stock void NullCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if(error[0] != 0)
	{
		LogError("[SM] - (NullCallback) - %s", error);
	}
}

void MapStartCallback (Database db, DBResultSet results, const char[] error, any data)
{
	//SELECT zones.HammerID, zones.Track, zones.Type FROM zones LEFT JOIN maps ON zones.MapID = maps.MapID WHERE maps.MapName = '%s';
	if(error[0] != 0)
	{
		LogError("[SM] - (MapStartCallback) - %s", error);
	}

	for(int i = 0; i < _MAX_ZONES; ++i)
	{
		if(results.FetchRow())
		{
			gZ_Zones[i].iEntityID = results.FetchInt(0);
			gZ_Zones[i].iZoneTrack = results.FetchInt(1);
			gZ_Zones[i].iZoneType = results.FetchInt(2);
		}
	}	
}

public void StartTouchPost_Trigger(int entity, int other)//other == client
{
	if(other < 1 || other > MaxClients || IsFakeClient(other))
	{
		return;
	}
	PrintToConsole(other, "StartTouchPost_Trigger: %i", entity);
	int index = -1;

	for(int i = 0; i < _MAX_ZONES; ++i)
	{
		PrintToConsole(other, "StartTouchPost_Trigger: %i, iEntityID: %i", entity, gZ_Zones[i].iEntityID);

		if(gZ_Zones[i].iEntityID == entity)
		{
			index = i;
		}
	}
	if(index == -1)
	{
		return;
	}
	
	TimerStatus status = Shavit_GetTimerStatus(other);
	PrintToConsole(other, "StartTouchPost_Trigger: %i, b1:%b b2:%b b3:%b", entity, (gZ_Zones[index].iZoneType == Zone_End), (status != Timer_Stopped), (Shavit_GetClientTrack(other) == gZ_Zones[index].iZoneTrack));

	if((gZ_Zones[index].iZoneType == Zone_End) && (status != Timer_Stopped) && (Shavit_GetClientTrack(other) == gZ_Zones[index].iZoneTrack))
	{
		Shavit_FinishMap(other, Shavit_GetClientTrack(other));
	}
}

//no start zone support

public void EndTouchPost_Trigger(int entity, int other)
{
	if(other < 1 || other > MaxClients || IsFakeClient(other))
	{
		return;
	}

	if(other < 1 || other > MaxClients || IsFakeClient(other))
	{
		return;
	}
	PrintToConsole(other, "EndTouchPost_Trigger: %i", entity);
	int index = -1;

	for(int i = 0; i < _MAX_ZONES; ++i)
	{
		if(gZ_Zones[i].iEntityID == entity)
		{
			index = i;
		}
	}
	if(index == -1)
	{
		return;
	}
	
	TimerStatus status = Shavit_GetTimerStatus(other);

	if((gZ_Zones[index].iZoneType == Zone_End) && (status != Timer_Stopped) && (Shavit_GetClientTrack(other) == gZ_Zones[index].iZoneTrack))
	{
		Shavit_FinishMap(other, gZ_Zones[index].iZoneTrack);
	}
}

public void TouchPost_Trigger(int entity, int other)
{
	if(other < 1 || other > MaxClients || IsFakeClient(other))
	{
		return;
	}
	PrintToConsole(other, "TouchPost_Trigger: %i", entity);

	int index = -1;

	for(int i = 0; i < _MAX_ZONES; ++i)
	{
		if(gZ_Zones[i].iEntityID == entity)
		{
			index = i;
		}
	}
	if(index == -1)
	{
		return;
	}
	
	TimerStatus status = Shavit_GetTimerStatus(other);

	if((gZ_Zones[index].iZoneType == Zone_End) && (status != Timer_Stopped) && (Shavit_GetClientTrack(other) == gZ_Zones[index].iZoneTrack))
	{
		Shavit_FinishMap(other, gZ_Zones[index].iZoneTrack);
	}
}

void BuildMenu()
{
	gM_SelectorMenu = new Menu(SelectorCallback);
	gM_SelectorMenu.SetTitle("Selector Menu\n+use to select brush");
	gM_SelectorMenu.AddItem("1", "Toggle Track");
	gM_SelectorMenu.AddItem("2", "Toggle Type");
	gM_SelectorMenu.AddItem("3", "Set As Stage");
	gM_SelectorMenu.AddItem("4", "Save");
}

public int SelectorCallback(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Cancel)
	{
		gB_MenuOpen[param1] = false;
	}
	else if(action == MenuAction_Select)
	{
		if(IsClientInGame(param1))
		{
			char info[8];
			menu.GetItem(param2, info, 8);

			int item = StringToInt(info);
			switch(item)
			{
				case 1:
				{
					gI_Track[param1] = !gI_Track[param1];
					PrintToChat(param1, "Track: %s", (gI_Track[param1]?"Track_Bonus":"Track_Main"));
				}
				case 2:
				{
					gI_Type[param1] = !gI_Type[param1];
					PrintToChat(param1, "Type: %s", (gI_Type[param1]?"Zone_End":"Zone_Start"));
				}
				case 3:
				{
					PrintToChat(param1, "Enter The Stage Number:");
					gB_Staging[param1] = true;
				}
				case 4:
				{
					PrintToChat(param1, "Saving Zone");
					InsertZone(param1);
				}
			}
			menu.Display(param1, MENU_TIME_FOREVER);
		}
	}
	return 0;
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] args)
{
	if(gB_Staging[client])
	{
		gI_Stage[client] = StringToInt(args);
		if(gI_Stage[client] == 0)
		{
			PrintToChat(client, "You have Cancelled The staging process");
		}
		else
		{
			gI_Type[client] = Zone_Stage;
			PrintToChat(client, "Stage: %i", gI_Stage[client]);
		}

		gB_Staging[client] = false;
	}
}

void InsertZone(int client)
{
	char query[256];
	if(gI_Entity[client] < 1 || gI_MapID == -1)
	{
		return;
	}
	FormatEx(query, sizeof(query), "INSERT INTO ent_zones (HammerID, MapID, Track, Type, Stage) VALUES (%i, %i, %i, %i, %i);", gI_Entity[client], gI_MapID, gI_Track[client], gI_Type[client], gI_Stage[client]);
	gDB_EntHook.Query(InsertZoneCallback, query, client, DBPrio_High);
}



void InsertZoneCallback(Database db, DBResultSet results, const char[] error, int client)
{
	if(error[0] != 0)
	{
		LogError("[SM] - (InsertZoneCallback) - %s", error);
	}
	PrintToChat(client, "Zone addition was %s!", (results.AffectedRows > 0?"succesful":"unsuccesful"));
	ResetClient(client);
}

void ResetClient(int client)
{
	gB_Held[client] = false;
	gB_MenuOpen[client] = false;
	gB_Staging[client] = false;

	gI_Entity[client] = -1;
	gS_ClassName[client][0] = 0;
	gS_TargetName[client][0] = 0;
	gI_Stage[client] = 0;

	gI_Track[client] = Track_Main;
	gI_Type[client] = Zone_End;
}

void ClearCache(int index)
{
	gZ_Zones[index].iZoneType = -1;
	gZ_Zones[index].iZoneTrack = Track_Main; 
	gZ_Zones[index].iEntityID = -1;
}

void PrintEntities(int entity, int client)
{
	char classname[32];
	char targetname[32];
	GetEntityClassname(entity, classname, sizeof(classname));
	GetEntPropString(entity, Prop_Data, "m_iName", targetname, 32);

	PrintToChat(client, "Info: '%s' '%s' at index[%i]", targetname, classname, entity);
	float vec[3];

	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vec);
	TE_SetupGlowSprite(vec, gI_HaloSprite, 5.0, 5.0, 255);
	TE_SendToClient(client);
}

public void OnPlayerRunCmdPost(int client, int buttons)
{
	if(gB_MenuOpen[client])
	{
		if(buttons & IN_USE == IN_USE)
		{
			if(!gB_Held[client])
			{
				gI_Entity[client] = GetTriggerAtAim(client);
				if(gI_Entity[client] < 1)
				{
					PrintToChat(client, "ERROR: Please select a valid entity");
					return;
				}
				PrintEntities(gI_Entity[client], client);
				gB_Held[client] = true;
			}
		}
		else
		{
			gB_Held[client] = false;
		}
	}
}