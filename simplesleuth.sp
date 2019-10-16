#pragma semicolon 1
#pragma tabsize 0
#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <sourcebans>

#define PLUGIN_VERSION "1.0"
#define STRING_NOT_FOUND -1

Database gDB_SourceBans = null;

ConVar gC_Action;
ConVar gC_BanLength;
ConVar gC_Prefix;

char gS_Prefix[16];

public Plugin myinfo = 
{
	name    = "Simple Sleuth",
	author    = "KiD Fearless",
	description= "Bans the alts",
	version    = PLUGIN_VERSION,
	url        = "https://github.com/kidfearless"
};

public void OnPluginStart()
{		
	gC_Action = CreateConVar("sm_sleuth_actions", "3", "Sleuth Ban Type: 1 - Original Length, 2 - Custom Length, 3 - Double Length");
	gC_BanLength = CreateConVar("sm_sleuth_duration", "0", "Required: sm_sleuth_actions 1: Bantime to ban player if we got a match (0 = permanent (defined in minutes) )");
	gC_Prefix = CreateConVar("sm_sleuth_prefix", "sb", "Prexfix for sourcebans tables: Default sb");
	gC_Prefix.AddChangeHook(OnPrefixChanged);
	gC_Prefix.GetString(gS_Prefix, sizeof(gS_Prefix));
	AutoExecConfig(true, "SimpleSleuth");

	Database.Connect(ConnectCallback, "sourcebans");
}

public void ConnectCallback(Database db, const char[] error, any data)
{
	if (error[0] != 0)
	{
		SetFailState("SimpleSleuth: Database connection error: '%s'", error);
	}
	else if(db == null)
	{
		SetFailState("SimpleSleuth: Null database connection: '%s'", error);
	}
	else
	{
		gDB_SourceBans = db;
	}
}

public void OnPrefixChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	strcopy(gS_Prefix, sizeof(gS_Prefix), newValue);
}

public void OnClientPostAdminCheck(int client)
{
	if(!IsFakeClient(client))
	{
		char IP[32];
		GetClientIP(client, IP, sizeof(IP));
		char query[160];
		
		FormatEx(query, sizeof(query),  "SELECT * FROM %s_bans WHERE ip='%s' AND (LENGTH = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL", gS_Prefix, IP);

		gDB_SourceBans.Query(BanResultsCallback, query, GetClientSerial(client), DBPrio_Low);
	}
}

public void BanResultsCallback(Database db, DBResultSet results, const char[] error, int serial)
{
	#define BAN_REASON 8
	#define BAN_LENGTH 6

	int client = GetClientFromSerial(serial);
	
	if (error[0] != 0)
	{
		LogError("SimpleSleuth: Database query error: '%s'", error);
		return;
	}
	if (client == 0)
	{
		LogMessage("SimpleSleuth: Invalid Client Index: '%s'", error);
		return;
	}
	if(db == null)
	{
		LogError("SimpleSleuth: Empty database connection: '%s'", error);
		return;
	}
	
	if (results.FetchRow())
	{
		char reason[256];
		results.FetchString(BAN_REASON, reason, sizeof(reason));
		
		if(StrContains(reason, "[SourceSleuth]", true) == STRING_NOT_FOUND)
		{
			int time = -1;
			FormatEx(reason, sizeof(reason), "[SourceSleuth] Duplicate account");
			switch (gC_Action.IntValue)
			{
				case 1: time = results.FetchInt(BAN_LENGTH) * 60;			
				case 2: time = gC_BanLength.IntValue;
				case 3: time = results.FetchInt(BAN_LENGTH) * 2;
			}
			SBBanPlayer(0, client, time, reason);
		}
	}

	#undef BAN_REASON
	#undef BAN_LENGTH
}