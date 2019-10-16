#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <smc>
#pragma newdecls required

//bool gB_IsMySql;
//bool gB_DatabaseReady
bool gB_MapActive = false;

int gI_rtvcount = 0;
int	gI_SuccessfulRTV = 0;
int	gI_PlayTime = 0;
int	gI_PlayCount = 0;
int	gI_PlayerHours = 0;

char gS_SQLBuffer[4096];
char gS_DatabaseLogPath[256];
char gS_LastTimePlayed[128];
char gS_MapName[PLATFORM_MAX_PATH];
Handle gH_DB;

//sql setup taken from mostactive plugin https://forums.alliedmods.net/showthread.php?p=1751973
public Plugin myinfo =
{
	name = "SQL Map Stats",
	author = "KiD Fearless",
	description = "Tracks Map Play Time And RTV Count.",
	version = "1.1.1",
	url = "https://steamcommunity.com/id/kidfearless/"
}

public void OnPluginStart()
{
	//gB_DatabaseReady = false;
	char error[256];
	gH_DB = SQLite_UseDatabase("Map_Stats", error, sizeof(error));
	if (gH_DB == null)
	{
		SetFailState("Could not open database: %s", error);
	}
	BuildPath(Path_SM, gS_DatabaseLogPath, sizeof(gS_DatabaseLogPath), "logs/MapStats.log");
}

public void OnConfigsExecuted()
{
	SQL_TConnect(OnSQLConnect, "Map_Stats");
}

public int OnSQLConnect(Handle owner, Handle hndl, char [] error, any data)
{
	if(hndl == null)
	{
		LogError("Database failure: %s", error);
		
		SetFailState("Databases dont work");
	}
	else
	{
		Format(gS_SQLBuffer, sizeof(gS_SQLBuffer), "CREATE TABLE IF NOT EXISTS Map_Stats (MapName TEXT PRIMARY KEY NOT NULL, RTVCount INTEGER UNSIGNED DEFAULT 0, SuccessfulRTV INTEGER UNSIGNED DEFAULT 0, PlayTime INTEGER UNSIGNED DEFAULT 0, PlayCount INTEGER UNSIGNED DEFAULT 0, PlayerHours INTEGER UNSIGNED DEFAULT 0, LastTimePlayed TEXT, `MapSize` INTEGER DEFAULT 0, UNIQUE(MapName));");
		
		SQL_TQuery(gH_DB, OnSQLConnectCallback, gS_SQLBuffer);
		LogToFileEx(gS_DatabaseLogPath, "Query: %s", gS_SQLBuffer);
		//PruneDatabase();
	}
}

public int OnSQLConnectCallback(Handle owner, Handle hndl, char [] error, any data)
{
	if(hndl == null)
	{
		LogError("Query failure: %s", error);
		return;
	}
}

public void OnMapStart()
{
	char MapName[PLATFORM_MAX_PATH];
	GetCurrentMap(MapName, sizeof(MapName));
	GetMapDisplayName(MapName, MapName, sizeof(MapName));

	strcopy(gS_MapName, sizeof(gS_MapName), MapName);
	gB_MapActive = true;
	CheckSQLMapName(MapName);
}

public void OnMapEnd()
{
	gB_MapActive = false
	UpdateMapStats();
}

public void CheckSQLMapName(const char[] MapName)
{
	char query[256];
	Format(query, sizeof(query), "SELECT MapName, RTVCount, SuccessfulRTV, PlayTime, PlayCount, PlayerHours, LastTimePlayed FROM Map_Stats WHERE MapName = '%s';", MapName);
	SQL_TQuery(gH_DB, CheckSQLMapNameCallback, query);
	LogToFileEx(gS_DatabaseLogPath, "Query %s", query);
}

public int CheckSQLMapNameCallback(Handle owner, Handle hndl, char [] error, any data)
{
	char mapname[PLATFORM_MAX_PATH];
	GetCurrentMap(mapname, sizeof(mapname));
	GetMapDisplayName(mapname, mapname, sizeof(mapname));

	if(hndl == null)
	{
		LogError("Query failure: %s", error);
		return;
	}

	//while unlikely, check for mapchange when the map starts
	if(!StrEqual(gS_MapName, mapname, true))
	{
		return;
	}

	ResetTrackers();

	if(!SQL_GetRowCount(hndl) || !SQL_FetchRow(hndl)) 
	{
		//map wasn't found so add it to the db
		InsertSQLNewMap(mapname);
		CreateTimer(1.0, Timer_OnSecond, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		return;
	}
	
	//Save results for use later.
	//mapname = SQL_FetchInt(hndl, 0);
	gI_rtvcount = SQL_FetchInt(hndl, 1);
	gI_SuccessfulRTV = SQL_FetchInt(hndl, 2);
	gI_PlayTime = SQL_FetchInt(hndl, 3);
	gI_PlayCount = SQL_FetchInt(hndl, 4);
	gI_PlayerHours = SQL_FetchInt(hndl, 5);
	SQL_FetchString(hndl, 6, gS_LastTimePlayed, sizeof(gS_LastTimePlayed));
	
	CreateTimer(1.0, Timer_OnSecond, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	gI_PlayCount++;

	//Update LastAccessTime
	UpdateAccessTime(mapname);
}

public Action Timer_OnSecond(Handle timer)
{
	int players = 0;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientValid(i, true))
		{
			gI_PlayerHours++;
			players++;
		}
	}
	if(players > 0)
	{
		gI_PlayTime++;
	}
}

public void InsertSQLNewMap(const char[] MapName)
{
	char query[256];
	char mapname[PLATFORM_MAX_PATH];
	char datetime[128];

	FormatTime(datetime, sizeof(datetime), NULL_STRING);

	SQL_EscapeString(gH_DB, MapName, mapname, sizeof(mapname));
	SQL_EscapeString(gH_DB, datetime, datetime, sizeof(datetime));
	
	Format(query, sizeof(query), "INSERT INTO Map_Stats (MapName, LastTimePlayed) VALUES('%s', '%s');", mapname, datetime);
	SQL_TQuery(gH_DB, InsertSQLNewMapCallback, query);
	LogToFileEx(gS_DatabaseLogPath, "Query %s", query);	
}

public int InsertSQLNewMapCallback(Handle owner, Handle hndl, char [] error, any data)
{
	if(hndl == null)
	{
		LogToFileEx(gS_DatabaseLogPath, "InsertSQLNewMapCallback failure: %s", error);
	}
	LogToFileEx(gS_DatabaseLogPath, "InsertSQLNewMapCallback successful");
}

public void UpdateAccessTime(const char[] MapName)
{
	char query[256];
	char mapname[PLATFORM_MAX_PATH];
	char datetime[128];

	FormatTime(datetime, sizeof(datetime), NULL_STRING);

	SQL_EscapeString(gH_DB, MapName, mapname, sizeof(mapname));
	SQL_EscapeString(gH_DB, datetime, datetime, sizeof(datetime));

	Format(query, sizeof(query), "UPDATE Map_Stats SET LastTimePlayed = '%s' WHERE MapName = '%s';", datetime, mapname);
	SQL_TQuery(gH_DB, UpdateAccessTimeCallback, query);
	LogToFileEx(gS_DatabaseLogPath, "Query %s", query);	
}

public void UpdateMapStats()
{
	char datetime[128];
	FormatTime(datetime, sizeof(datetime), NULL_STRING);
	SQL_EscapeString(gH_DB, datetime, datetime, sizeof(datetime));
	int mapSize = GetCurrentMapSize();

	char query[256];
	Format(query, sizeof(query), "UPDATE Map_Stats SET RTVCount = %i, SuccessfulRTV = %i, PlayTime = %i, PlayCount = %i, PlayerHours = %i, LastTimePlayed = '%s', MapSize = %i WHERE MapName = '%s';", gI_rtvcount, gI_SuccessfulRTV, gI_PlayTime, gI_PlayCount, gI_PlayerHours, datetime, mapSize, gS_MapName);
	SQL_TQuery(gH_DB, UpdateMapStatsCallback, query);
	LogToFileEx(gS_DatabaseLogPath, "Query %s", query);	
}

public int UpdateMapStatsCallback(Handle owner, Handle hndl, char [] error, any data)
{
	if(hndl == null)
	{
		LogToFileEx(gS_DatabaseLogPath, "UpdateMapStatsCallback failure: %s", error);
	}
	LogToFileEx(gS_DatabaseLogPath, "UpdateMapStatsCallback successful");
}

public int UpdateAccessTimeCallback(Handle owner, Handle hndl, char [] error, any data)
{
	if(hndl == null)
	{
		LogToFileEx(gS_DatabaseLogPath, "UpdateAccessTimeCallback failure: %s", error);
	}
	LogToFileEx(gS_DatabaseLogPath, "UpdateAccessTimeCallback successful");
}

stock bool IsClientValid(int client, bool bAlive = false)
{
	return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client) && !IsFakeClient(client) && !IsClientReplay (client) && (!bAlive || IsPlayerAlive(client)));
}

//forwards

public void SMC_OnRTV()
{
	if(!gB_MapActive)
	{
		return;
	}
	gI_rtvcount++;
}

public void SMC_OnSuccesfulRTV()
{
	if(!gB_MapActive)
	{
		return;
	}
	gI_SuccessfulRTV++;
}

public void SMC_OnUnRTV()
{
	if(!gB_MapActive)
	{
		return;
	}
	gI_rtvcount--;
}

void ResetTrackers()
{
	gI_rtvcount = 0;
	gI_SuccessfulRTV = 0;
	gI_PlayTime = 0;
	gI_PlayCount = 0;
	gI_PlayerHours = 0;
}

int GetCurrentMapSize()
{
	char currentMap[PLATFORM_MAX_PATH];
	GetCurrentMap(currentMap, sizeof(currentMap));

	if(!Format(currentMap, sizeof(currentMap), "maps/%s.bsp", currentMap)) return 0;
	int size = ( (FileSize(currentMap)) / 1000000);
	return size;
}

//future implementation 
/*
public void PruneDatabase()
{
	if(gH_DB == null)
	{
		LogToFileEx(gS_DatabaseLogPath, "Prune Database: No connection");
		return;
	}

	int maxlastaccuse;
	maxlastaccuse = GetTime() - (IDAYS * 86400);

	char buffer[1024];

	if(gB_IsMySql)
		Format(buffer, sizeof(buffer), "DELETE FROM `mostactive` WHERE `last_accountuse`<'%d' AND `last_accountuse`>'0';", maxlastaccuse);
	else
		Format(buffer, sizeof(buffer), "DELETE FROM mostactive WHERE last_accountuse<'%d' AND last_accountuse>'0';", maxlastaccuse);

	LogToFileEx(gS_DatabaseLogPath, "Query %s", buffer);
	SQL_TQuery(gH_DB, PruneDatabaseCallback, buffer);
}

public int PruneDatabaseCallback(Handle owner, Handle hndl, char [] error, any data)
{
	if(hndl == null)
	{
		LogToFileEx(gS_DatabaseLogPath, "Query failure: %s", error);
	}
	//LogMessage("Prune Database successful");
}
*/