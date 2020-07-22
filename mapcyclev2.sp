#include <sourcemod>
#include <regex>
#pragma newdecls required

#define DB_NAME			"db_mapcycle"
#define DEFAULT_MAP		726282962
#define DEFAULT_SMAP	"726282962"
#define HOUR			3600
#define DAY 			86400
#define CHICAGO_OFFSET	-18000
#define WIPE_SERVER 1
Database gDB_Mapcycle = null;

Menu MapsFolder = null;

char Map[PLATFORM_MAX_PATH];
Regex gR_WorkshopID;

Handle RestartTimer = null;
bool RestartServer = false;



//int Save;

public Plugin myinfo =
{
	name = "Generate Mapcycle",
	author = "KiD Fearless",
	description = "Scans the maps folder and builds a maplist from it.",
	version = "2.5",
	url = "sourcemod.net"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_addmap", Command_AddMap, ADMFLAG_CHANGEMAP, "Add a map to the maplist database, Usage: sm_addmap <workshopid> <map name>");
	RegAdminCmd("sm_removeallmaps", Command_RemoveAll, ADMFLAG_RCON, "Removes all maps from the server");
	RegAdminCmd("sm_removemap", Command_RemoveMap, ADMFLAG_CHANGEMAP, "Removes a map from the maplist database, Usage: sm_removemap <workshopid>");
	RegAdminCmd("sm_savemap", Command_SaveMap, ADMFLAG_CHANGEMAP, "Marks a map to be saved from deletion, Usage: sm_savemap <workshopid>");
	RegConsoleCmd("sm_request", Command_Request, "Request something to be added to the server");

	AutoExecConfig();

	char error[256];
	delete gDB_Mapcycle;
	gDB_Mapcycle = SQLite_UseDatabase("db_mapcycle", error, sizeof(error));

	//Create maplist database.
	DB_CreateTables();
	#if WIPE_SERVER
	RestartTimer = CreateTimer(1.0, Timer_Restart, _, TIMER_REPEAT);
	#endif
	
	gR_WorkshopID = new Regex("(\\d+)");

}

public void OnPluginEnd()
{
	delete RestartTimer;
}

public Action Timer_Restart(Handle timer, Handle hndl)
{
	if(GetTime() % DAY == (3 * HOUR) + CHICAGO_OFFSET)
	{
		RestartServer = true;
		for(int i = 0; i < 10; ++i)
		{
			PrintToChatAll(" \x02** THE SERVER WILL RESTART AT THE END OF THE MAP **");
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void OnMapStart()
{
	//allocate
	char fullMap[PLATFORM_MAX_PATH], currentMap[PLATFORM_MAX_PATH], id[PLATFORM_MAX_PATH];
	//get the current map
	GetCurrentMap(fullMap, sizeof(fullMap));
	//split it into map and id
	ParseWorkshopMap(fullMap, id, currentMap);
	LogMessage("ParseMapPost: ID: '%s' maps: '%s'", id, currentMap);
	FormatEx(Map, sizeof(Map), "%s", id);

	LogMessage("MAPCYCLEV2: OnMapStart: '%s' ", fullMap);
	if(StringToInt(id) != 0)
	{
		AddMapToList(id, currentMap);
	}
	CreateMapsMenu();
}

public void OnMapEnd()
{
	#if WIPE_SERVER
	if(RestartServer)
	{
		LogMessage("** Deleting all maps **");

		DeleteAllMaps();
		LogMessage("** Deleted all maps **");
		CreateTimer(15.0, Timer_RestartServer);
	}
	#endif
}

public Action Timer_RestartServer(Handle timer, Handle hndl)
{
	LogMessage("** Restarting Server **");
	ServerCommand("_restart");
	return Plugin_Stop;
}

void CreateMapsMenu()
{
	char buffer[512];
	
	Format(buffer, sizeof(buffer), "SELECT WorkshopID, Map, Save FROM db_maplist ORDER BY Map ASC");
	gDB_Mapcycle.Query(LoadMapListCallback, buffer, _, DBPrio_High);
	ServerCommand("sm_reloadmaplist");
}

public void LoadMapListCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if(results == null)
	{
		LogError("[SM] - (Generate maps menu) - %s", error);
		return;	
	}

	delete MapsFolder;
	MapsFolder = new Menu(MapsMenuHandler);
	MapsFolder.SetTitle("MapList Menu");

	char id[PLATFORM_MAX_PATH];
	char map[PLATFORM_MAX_PATH];
	bool save = false;
	while(results.FetchRow())
	{	
		results.FetchString(0, id, sizeof(id));
		results.FetchString(1, map, sizeof(map));
		save = view_as<bool>(results.FetchInt(2));
		Format(map, sizeof(map), "%s (%b)", map, save);
		MapsFolder.AddItem(id, map);
	}
}

public int MapsMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select)
	{
		char mapid[PLATFORM_MAX_PATH];
		char mapname[PLATFORM_MAX_PATH];
		
		int style;
		menu.GetItem(param2, mapid, sizeof(mapid), style, mapname, sizeof(mapname));
		LogMessage("MAPCYCLEV2: MapsMenuHandler: mapid '%s' mapname: '%s'", mapid, mapname);
		DB_RemoveMap(mapid);
	}
}

void AddMapToList(char[] id, char[] map)
{
	LogMessage("MAPCYCLEV2: ADDMAPTOLIST: ID '%s' map: '%s'", id, map);

	DB_AddNewMap(id, map);
}

public Action Command_AddMap(int client, int args)
{
	char id[PLATFORM_MAX_PATH];
	char mapname[PLATFORM_MAX_PATH];
	char sArgs[PLATFORM_MAX_PATH];
	if(args < 1)
	{
		ReplyToCommand(client, "Usage: sm_addmap <workshopid> <map name>.");

		return Plugin_Handled;
	}
	
	GetCmdArg(1, id, sizeof(id));

	if(args == 1)
	{
		Format(mapname, sizeof(mapname), "<Unzoned Map %i>", GetTime());
	}
	else 
	{
		GetCmdArg(2, mapname, sizeof(mapname));
	}

	GetCmdArgString(sArgs, PLATFORM_MAX_PATH);
	LogAction(client, -1, "%L Has added a map to the maplist. query '%s'", client, sArgs);
	if(StrContains(sArgs, "http", false) != -1)
	{
		char buffer[256];
		for(int i = 0; i <= GetCmdArgs()+1; ++i)
		{
			GetCmdArg(i, buffer, 256);
			PrintToConsole(client, buffer);
		}
	}
	TrimString(id);
	TrimString(mapname);

	if(id[0] == 0 || mapname[0] == 0)
	{
		ReplyToCommand(client, "ERROR: Command Failed.");
		return Plugin_Handled;
	}
	if(StringToInt(id) == 0)
	{
		if(gR_WorkshopID.Match(id) > 0)
		{
			if(!gR_WorkshopID.GetSubString(0, id, PLATFORM_MAX_PATH))
			{
				ReplyToCommand(client, "ERROR: Failed to parse workshop url substring");
				return Plugin_Handled;
			}
		}
		else
		{
			ReplyToCommand(client, "ERROR: Failed to match url regex");
			return Plugin_Handled;
		}

	}
	DB_AddNewMap(id, mapname);
	PrintToChatAll("Succefully added %s to the map pool", mapname);
	return Plugin_Handled;
}

public Action Command_RemoveMap(int client, int args)
{
	if(args < 1)
	{
		MapsFolder.Display(client, MENU_TIME_FOREVER);
		return Plugin_Handled;
	}
	char id[PLATFORM_MAX_PATH];
	char sArgs[PLATFORM_MAX_PATH];
	GetCmdArg(1, id, sizeof(id));
	GetCmdArgString(sArgs, PLATFORM_MAX_PATH);
	LogAction(client, -1, "%L Has removed a map from the maplist. query '%s'", client, sArgs);

	TrimString(id);

	for(int i = 0; i < strlen(id); ++i)
	{
		if(!IsCharNumeric(id[i]))
		{
			ReplyToCommand(client, "ERROR: Arguments contained non-numeric characters!");
			return Plugin_Handled;
		}
	}

	DB_RemoveMap(id);

	ReplyToCommand(client, "Succefully removed %s from the map pool", id);

	return Plugin_Handled;
}

public Action Command_SaveMap(int client, int args)
{
	if(args < 1)
	{
		//MapsFolder.Display(client, MENU_TIME_FOREVER);
		return Plugin_Handled;
	}

	char id[32];
	GetCmdArg(1, id, sizeof(id));
	char query[128];
	FormatEx(query, sizeof(query), "UPDATE db_mapcycle SET Save = !Save WHERE WorkshopID = '%s';", id);
	gDB_Mapcycle.Query(NullCallback, query);

	return Plugin_Handled;
}

public Action Command_RemoveAll(int client, int args)
{
	DeleteAllMaps();
	ReplyToCommand(client, "Check Console");

	return Plugin_Handled;
}


public Action Command_Request(int client, int args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "Usage: sm_request <suggestion>.");
		return Plugin_Handled;
	}
	char query[320];
	char request[256];
	char userid[64];
	char name[32];
	GetCmdArgString(request, sizeof(request));
	GetClientAuthId(client, AuthId_Steam3, userid, sizeof(userid));
	GetClientName(client, name, sizeof(name));
	FormatEx(query, sizeof(query), "INSERT INTO db_requests(Request, UserID, Name) VALUES ('%s', '%s', '%s');", request, userid, name);
	gDB_Mapcycle.Query(NullCallback, query);
	ReplyToCommand(client, "You have made the request '%s'", request);

	return Plugin_Handled;
}


void DB_CreateTables()
{
	char query[256];
	FormatEx(query, sizeof(query), "CREATE TABLE IF NOT EXISTS 'db_maplist' ( `WorkshopID` NUMERIC NOT NULL UNIQUE, `Map` TEXT NOT NULL, `Save` INTEGER NOT NULL DEFAULT 0 );" ...
									"CREATE TABLE CREATE TABLE db_requests (Request TEXT, UserID TEXT, Name TEXT);");
	gDB_Mapcycle.Query(NullCallback, query, _, DBPrio_Low);
}

void DB_AddNewMap(char[] id, char[] map)
{
	if(!IsValidString(id) || !IsValidString(map))
	{
		return;
	}
	if(!IsStringNumeric(id, strlen(id)))
	{
		return;
	}
	char query[256];
	FormatEx(query, sizeof(query), "INSERT OR REPLACE INTO db_maplist(WorkshopID, Map) VALUES ('%s', '%s');", id, map);
	gDB_Mapcycle.Query(NullCallback, query, _, DBPrio_Low);
	CreateMapsMenu();
}

void DB_RemoveMap(char[] id)
{
	char query[256];
	FormatEx(query, sizeof(query), "SELECT WorkshopID FROM db_maplist WHERE WorkshopID = %s;", id);
	DataPack pack = new DataPack();
	pack.WriteString(id);
	
	gDB_Mapcycle.Query(DeleteMapCallback, query, pack, DBPrio_Low);
}

public void DeleteMapCallback(Database db, DBResultSet results, const char[] error, DataPack pack)
{
	if(results == null)
	{
		LogError("[SM] - (DeleteMapCallback) - %s", error);
		return;	
	}

	char map[PLATFORM_MAX_PATH];
	char id[256];
	pack.Reset(false);
	pack.ReadString(id, sizeof(id));
	delete pack;


	if(results.RowCount > 1)
	{
		LogError("MAPCYCLEV2: DeleteMapCallback: RowCount > 1");
		return;
	}
	results.FetchRow();
	results.FetchString(0, map, sizeof(map));
	TrimString(map);
	if(StrEqual(map, id, false))
	{
		char query[256];
		FormatEx(query, sizeof(query), "DELETE FROM db_maplist WHERE WorkshopID = '%s';", id);
		DeleteFolder(id);
		gDB_Mapcycle.Query(NullCallback, query, _, DBPrio_Low);
	}
}

void DeleteFolder(const char[] id)
{
	if(StrEqual(id,DEFAULT_SMAP) || StringToInt(id) == 0)
	{
		return;
	}

	char directory[PLATFORM_MAX_PATH];
	FormatEx(directory, sizeof(directory), "maps/workshop/%s/", id);
	DirectoryListing workshopFolder = OpenDirectory(directory);
	char buffer[PLATFORM_MAX_PATH];

	while(workshopFolder.GetNext(directory, sizeof(directory)))
	{
		if(StrEqual(directory, ".", false) || StrEqual(directory, "..", false))
		{
			continue;
		}
		FormatEx(buffer, sizeof(buffer), "maps/workshop/%s/%s", id, directory);
		DeleteFile(buffer);
		LogMessage("[SM] - DeleteFolder - %s", buffer);
	}
	delete workshopFolder;
}


void DeleteAllMaps()
{
	int currentMap = GetCurrentWorkshopID();
	if(currentMap < 1)
	{
		return;
	}

	DirectoryListing workshopFolder = OpenDirectory("maps/workshop/");
	char buffer[PLATFORM_MAX_PATH];

	while(workshopFolder.GetNext(buffer, sizeof(buffer)))
	{
		int workshopID = StringToInt(buffer);
		if((workshopID != currentMap) && (workshopID != 0) && (workshopID != DEFAULT_MAP))
		{
			DeleteFolder(buffer);
		}
	}
	delete workshopFolder;
}


/************************************************************
*															*
*															*
*						Stocks								*
*															*
*															*
************************************************************/


stock void GetMapName(char[] buffer, int size)
{
	if(current)
	{
		GetCurrentMap(buffer, size);
	}

	GetMapDisplayName(buffer, buffer, size);	
}

stock void LowerCaseString(char[] buffer, int size)
{
	for(int i = 0; i < size; ++i)
	{
		if(IsCharUpper(buffer[i]))
		{
			buffer[i] = CharToLower(buffer[i]);
		}
	}
}
stock void ParseWorkshopMap(char[] inputmap, char[] id, char[] map)
{
	char mapsplit[2][64];
	char input[256];
	FormatEx(input, sizeof(input), "%s", inputmap);

	ReplaceString(input, PLATFORM_MAX_PATH, "workshop/", "", false);
	
	ExplodeString(input, "/", mapsplit, 2, 64);
	
	strcopy(id, PLATFORM_MAX_PATH, mapsplit[0]);
	strcopy(map, PLATFORM_MAX_PATH, mapsplit[1]);
	LogMessage("MAPCYCLEV2: PARSE: ID: '%s' MAP: '%s'", mapsplit[0], mapsplit[1]);
}

stock int GetCurrentWorkshopID()
{
	char currentMap[PLATFORM_MAX_PATH];
	GetCurrentMap(currentMap, PLATFORM_MAX_PATH);
	char id[32];
	ParseWorkshopMap(currentMap, id, currentMap);
	return StringToInt(id);
}

stock void NullCallback (Database db, DBResultSet results, const char[] error, any data)
{
	if(error[0] != 0)
	{
		LogError("[SM] - (NullCallback) - %s", error);
	}
}

stock bool IsStringNumeric(const char[] input, const int length)
{
	for(int i = 0; i < length; ++i)
	{
		if(!IsCharNumeric(input[i]))
		{
			return false;
		}
	}
	return true;
}

stock bool IsValidString(const char[] input)
{
	if(IsNullString(input))
	{
		return false;
	}
	if(input[0] == 0)
	{
		return false;
	}
	return true;
}