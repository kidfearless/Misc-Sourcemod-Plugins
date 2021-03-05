#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <shavit>
#include <cstrike>

#undef REQUIRE_PLUGIN
// for MapChange type
#include <mapchooser>

#define PLUGIN_VERSION "1.0.4.1"

Database g_hDatabase;
char g_cSQLPrefix[32];

bool g_bLate;

#if defined DEBUG
bool g_bDebug;
#endif

/* ConVars */
ConVar g_cvRTVRequiredPercentage;
ConVar g_cvRTVAllowSpectators;
ConVar g_cvRTVMinimumPoints;
ConVar g_cvRTVDelayTime;

ConVar g_cvMapListType;

ConVar g_cvMapVoteStartTime;
ConVar g_cvMapVoteDuration;
ConVar g_cvMapVoteBlockMapInterval;
ConVar g_cvMapVoteExtendLimit;
ConVar g_cvMapVoteEnableNoVote;
ConVar g_cvMapVoteExtendTime;
ConVar g_cvMapVoteShowTier;
ConVar g_cvMapVoteRunOff;
ConVar g_cvMapVoteRunOffPerc;

/* Map arrays */
ArrayList g_aMapList;
ArrayList g_aMapTiers;
ArrayList g_aNominateList;
ArrayList g_aOldMaps;

/* Map Data */
char g_cMapName[PLATFORM_MAX_PATH];

MapChange g_ChangeTime;

bool g_bMapVoteStarted;
bool g_bMapVoteFinished;
float g_fMapStartTime;

int g_iExtendCount;

Menu g_hNominateMenu;
Menu g_hVoteMenu;

/* Player Data */
bool	g_bRockTheVote[MAXPLAYERS + 1];
char g_cNominatedMap[MAXPLAYERS + 1][PLATFORM_MAX_PATH];

enum MapListType
{
	MapListZoned,
	MapListFile,
	MapListFolder
}

public Plugin myinfo =
{
	name = "shavit - MapChooser",
	author = "SlidyBat",
	description = "Automated Map Voting and nominating with Shavit timer integration",
	version = PLUGIN_VERSION,
	url = ""
}

public APLRes AskPluginLoad2( Handle myself, bool late, char[] error, int err_max )
{
	g_bLate = late;
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	HookEvent( "round_start", OnRoundStartPost );
	LoadTranslations("mapchooser.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("rockthevote.phrases");
	LoadTranslations("nominations.phrases");

	g_aMapList = new ArrayList( ByteCountToCells(PLATFORM_MAX_PATH) );
	g_aMapTiers = new ArrayList();
	g_aNominateList = new ArrayList( ByteCountToCells(PLATFORM_MAX_PATH) );
	g_aOldMaps = new ArrayList( ByteCountToCells(PLATFORM_MAX_PATH) );
	
	g_cvMapListType = CreateConVar( "smc_maplist_type", "0", "Where the plugin should get the map list from. 0 = zoned maps from database, 1 = from maplist file (maplist.txt), 2 = from maps folder", _, true, 0.0, true, 2.0 );
	
	g_cvMapVoteBlockMapInterval = CreateConVar( "smc_mapvote_blockmap_interval", "1", "How many maps should be played before a map can be nominated again", _, true, 0.0, false );
	g_cvMapVoteEnableNoVote = CreateConVar( "smc_mapvote_enable_novote", "1", "Whether players are able to choose 'No Vote' in map vote", _, true, 0.0, true, 1.0 );
	g_cvMapVoteExtendLimit = CreateConVar( "smc_mapvote_extend_limit", "3", "How many times players can choose to extend a single map (0 = block extending)", _, true, 0.0, false );
	g_cvMapVoteExtendTime = CreateConVar( "smc_mapvote_extend_time", "10", "How many minutes should the map be extended by if the map is extended through a mapvote", _, true, 1.0, false );
	g_cvMapVoteShowTier = CreateConVar( "smc_mapvote_show_tier", "1", "Whether the map tier should be displayed in the map vote", _, true, 0.0, true, 1.0 );
	g_cvMapVoteDuration = CreateConVar( "smc_mapvote_duration", "1", "Duration of time in minutes that map vote menu should be displayed for", _, true, 0.1, false );
	g_cvMapVoteStartTime = CreateConVar( "smc_mapvote_start_time", "5", "Time in minutes before map end that map vote starts", _, true, 1.0, false );
	
	g_cvRTVAllowSpectators = CreateConVar( "smc_rtv_allow_spectators", "1", "Whether spectators should be allowed to RTV", _, true, 0.0, true, 1.0 );
	g_cvRTVMinimumPoints = CreateConVar( "smc_rtv_minimum_points", "-1", "Minimum number of points a player must have before being able to RTV, or -1 to allow everyone", _, true, -1.0, false );
	g_cvRTVDelayTime = CreateConVar( "smc_rtv_delay", "5", "Time in minutes after map start before players should be allowed to RTV", _, true, 0.0, false );
	g_cvRTVRequiredPercentage = CreateConVar( "smc_rtv_required_percentage", "50", "Percentage of players who have RTVed before a map vote is initiated", _, true, 1.0, true, 100.0 );

	g_cvMapVoteRunOff = CreateConVar("smc_mapvote_runoff", "0", "Hold run of votes if winning choice is less than a certain margin", _, true, 0.0, true, 1.0);
	g_cvMapVoteRunOffPerc = CreateConVar("smc_mapvote_runoffpercent", "50", "If winning choice has less than this percent of votes, hold a runoff", _, true, 0.0, true, 100.0);


	AutoExecConfig();
	
	RegAdminCmd( "sm_extend", Command_Extend, ADMFLAG_CHANGEMAP, "Admin command for extending map" );
	RegAdminCmd( "sm_forcemapvote", Command_ForceMapVote, ADMFLAG_RCON, "Admin command for forcing the end of map vote" );
	RegAdminCmd( "sm_reloadmaplist", Command_ReloadMaplist, ADMFLAG_CHANGEMAP, "Admin command for forcing maplist to be reloaded" );
	
	RegConsoleCmd( "sm_nominate", Command_Nominate, "Lets players nominate maps to be on the end of map vote" );
	RegConsoleCmd( "sm_unnominate", Command_UnNominate, "Removes nominations" );
	RegConsoleCmd( "sm_rtv", Command_RockTheVote, "Lets players Rock The Vote" );
	RegConsoleCmd( "sm_unrtv", Command_UnRockTheVote, "Lets players un-Rock The Vote" );
	
	if( g_bLate )
	{
		OnMapStart();
	}
	
	#if defined DEBUG
	RegConsoleCmd( "sm_smcdebug", Command_Debug );
	#endif
}

public void OnMapStart()
{
	GetCurrentMap( g_cMapName, sizeof(g_cMapName) );
	
	// disable rtv if delay time is > 0
	g_fMapStartTime = GetGameTime();
	
	g_iExtendCount = 0;
	
	g_bMapVoteFinished = false;
	g_bMapVoteStarted = false;
	
	g_aNominateList.Clear();
	for( int i = 1; i <= MaxClients; i++ )
	{
		g_cNominatedMap[i][0] = '\0';
	}
	ClearRTV();
	
	// reload maplist array
	LoadMapList();
	// cache the nominate menu so that it isn't being built every time player opens it
	
	CreateTimer( 2.0, Timer_OnMapTimeLeftChanged, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
}

public Action OnRoundStartPost( Event event, const char[] name, bool dontBroadcast )
{
	// disable rtv if delay time is > 0
	g_fMapStartTime = GetGameTime();
	
	g_iExtendCount = 0;
	
	g_bMapVoteFinished = false;
	g_bMapVoteStarted = false;
	
	g_aNominateList.Clear();
	for( int i = 1; i <= MaxClients; i++ )
	{
		g_cNominatedMap[i][0] = '\0';
	}
	ClearRTV();
}

public void OnMapEnd()
{
	if( g_cvMapVoteBlockMapInterval.IntValue > 0 )
	{
		g_aOldMaps.PushString( g_cMapName );
		if( g_aOldMaps.Length > g_cvMapVoteBlockMapInterval.IntValue )
		{
			g_aOldMaps.Erase( 0 );
		}
	}
	
	g_iExtendCount = 0;
	
	g_bMapVoteFinished = false;
	g_bMapVoteStarted = false;
	
	g_aNominateList.Clear();
	for( int i = 1; i <= MaxClients; i++ )
	{
		g_cNominatedMap[i][0] = '\0';
	}
	
	ClearRTV();
}

public Action Timer_OnMapTimeLeftChanged(Handle Timer)
{
	#if defined DEBUG
	if( g_bDebug )
	{
		DebugPrint( "[SMC] OnMapTimeLeftChanged: maplist_length=%i mapvote_started=%s mapvotefinished=%s", g_aMapList.Length, g_bMapVoteStarted ? "true" : "false", g_bMapVoteFinished ? "true" : "false" );
	}
	#endif
	
	int timeleft;
	if( GetMapTimeLeft( timeleft ) )
	{
		if( !g_bMapVoteStarted && !g_bMapVoteFinished )
		{
			int mapvoteTime = timeleft - RoundFloat( g_cvMapVoteStartTime.FloatValue * 60.0 );
			switch( mapvoteTime )
			{
				case (10 * 60) - 3:
				{
					PrintToChatAll( "[SMC] 10 minutes until map vote" );
				}
				case (5 * 60) - 3:
				{
					PrintToChatAll( "[SMC] 5 minutes until map vote" );
				}
				case 60 - 3:
				{
					PrintToChatAll( "[SMC] 1 minute until map vote" );
				}
				case 30 - 3:
				{
					PrintToChatAll( "[SMC] 30 seconds until map vote" );
				}
				case 5 - 3:
				{
					PrintToChatAll( "[SMC] 5 seconds until map vote" );
				}
			}
		}
		else if( g_bMapVoteFinished )
		{
			switch( timeleft )
			{
				case (30 * 60) - 3:
				{
					PrintToChatAll( "[SMC] 30 minutes remaining" );
				}
				case (20 * 60) - 3:
				{
					PrintToChatAll( "[SMC] 20 minutes remaining" );
				}
				case (10 * 60) - 3:
				{
					PrintToChatAll( "[SMC] 10 minutes remaining" );
				}
				case (5 * 60) - 3:
				{
					PrintToChatAll( "[SMC] 5 minutes remaining" );
				}
				case 60 - 3:
				{
					PrintToChatAll( "[SMC] 1 minute remaining" );
				}
				case 10 - 3:
				{
					PrintToChatAll( "[SMC] 10 seconds remaining" );
				}
				case 5 - 3:
				{
					PrintToChatAll( "[SMC] 5 seconds remaining" );
				}
				case 3 - 3:
				{
					PrintToChatAll( "[SMC] 3 seconds remaining" );
				}
				case 2 - 3:
				{
					PrintToChatAll( "[SMC] 2 seconds remaining" );
				}
				case 1 - 3:
				{
					PrintToChatAll( "[SMC] 1 seconds remaining" );
				}
			}
		}
	}
	
	if( g_aMapList.Length && !g_bMapVoteStarted && !g_bMapVoteFinished )
	{
		CheckTimeLeft();
	}
}

void CheckTimeLeft()
{
	int timeleft;
	if( GetMapTimeLeft( timeleft ) && timeleft > 0 )
	{
		int startTime = RoundFloat( g_cvMapVoteStartTime.FloatValue * 60.0 );
		#if defined DEBUG
		if( g_bDebug )
		{
			DebugPrint( "[SMC] CheckTimeLeft: timeleft=%i startTime=%i", timeleft, startTime );
		}
		#endif
		
		if( timeleft - startTime <= 0 )
		{
			#if defined DEBUG
			if( g_bDebug )
			{
				DebugPrint( "[SMC] CheckTimeLeft: Initiating map vote ...", timeleft, startTime );
			}
			#endif
		
			InitiateMapVote( MapChange_MapEnd );
		}
	}
	#if defined DEBUG
	else
	{
		if( g_bDebug )
		{
			DebugPrint( "[SMC] CheckTimeLeft: GetMapTimeLeft=%s timeleft=%i", GetMapTimeLeft(timeleft) ? "true" : "false", timeleft );
		}
	}
	#endif
}

public void OnClientDisconnect( int client )
{
	// clear player data
	g_bRockTheVote[client] = false;
	g_cNominatedMap[client][0] = '\0';
	
	CheckRTV();
}

public void OnClientSayCommand_Post( int client, const char[] command, const char[] sArgs )
{
	if( StrEqual( sArgs, "rtv", false ) || StrEqual( sArgs, "rockthevote", false ) )
	{
		ReplySource old = SetCmdReplySource(SM_REPLY_TO_CHAT);
		
		Command_RockTheVote( client, 0 );
		
		SetCmdReplySource(old);
	}
	else if( StrEqual( sArgs, "nominate", false ) )
	{
		ReplySource old = SetCmdReplySource(SM_REPLY_TO_CHAT);
		
		Command_Nominate( client, 0 );
		
		SetCmdReplySource(old);
	}
}

void InitiateMapVote( MapChange when )
{
	g_ChangeTime = when;
	g_bMapVoteStarted = true;
	
	// create menu
	Menu menu = new Menu( Handler_MapVoteMenu, MENU_ACTIONS_ALL );
	menu.VoteResultCallback = Handler_MapVoteFinished;
	menu.Pagination = MENU_NO_PAGINATION;
	menu.SetTitle( "Vote Nextmap" );
	
	int mapsToAdd = 8;
	if( g_cvMapVoteExtendLimit.IntValue > 0 && g_iExtendCount < g_cvMapVoteExtendLimit.IntValue )
	{
		mapsToAdd--;
	}
	
	if( g_cvMapVoteEnableNoVote.BoolValue )
	{
		mapsToAdd--;
	}
	
	char map[PLATFORM_MAX_PATH];
	char mapdisplay[PLATFORM_MAX_PATH + 32];
	
	int nominateMapsToAdd = ( mapsToAdd > g_aNominateList.Length ) ? g_aNominateList.Length : mapsToAdd;
	for( int i = 0; i < nominateMapsToAdd; i++ )
	{
		g_aNominateList.GetString( i, map, sizeof(map) );
		GetMapDisplayName(map, mapdisplay, sizeof(mapdisplay));	
		
		if( g_cvMapVoteShowTier.BoolValue )
		{
			int tier = 1;
			int idx = g_aMapList.FindString( map );
			if( idx != -1 )
			{
				tier = g_aMapTiers.Get( idx );
			}
			
			Format( mapdisplay, sizeof(mapdisplay), "[T%i] %s", tier, mapdisplay );
		}
		else
		{
			strcopy( mapdisplay, sizeof(mapdisplay), map );
		}
		
		menu.AddItem( map, mapdisplay );
		
		mapsToAdd--;
	}
	
	for( int i = 0; i < mapsToAdd; i++ )
	{
		int rand = GetRandomInt( 0, g_aMapList.Length - 1 );
		g_aMapList.GetString( rand, map, sizeof(map) );
		
		GetMapDisplayName(map, mapdisplay, sizeof(mapdisplay));		
		
		if( StrEqual( map, g_cMapName ) )
		{
			// don't add current map to vote
			i--;
			continue;
		}
		
		int idx = g_aOldMaps.FindString( map );
		if( idx != -1 )
		{
			// map already played recently, get another map
			i--;
			continue;
		}
		
		if( g_cvMapVoteShowTier.BoolValue )
		{
			int tier = g_aMapTiers.Get( rand );
			
			Format( mapdisplay, sizeof(mapdisplay), "[T%i] %s", tier, mapdisplay );
		}

		
		menu.AddItem( map, mapdisplay );
	}
	
	if( when == MapChange_MapEnd && g_cvMapVoteExtendLimit.IntValue > 0 && g_iExtendCount < g_cvMapVoteExtendLimit.IntValue )
	{
		menu.AddItem( "extend", "Extend Map" );
	}
	else if( when == MapChange_Instant )
	{
		menu.AddItem( "dontchange", "Don't Change" );
	}
	
	menu.NoVoteButton = g_cvMapVoteEnableNoVote.BoolValue;
	menu.ExitButton = false;
	menu.DisplayVoteToAll( RoundFloat( g_cvMapVoteDuration.FloatValue * 60.0 ) );
	
	PrintToChatAll( "[SMC] %t", "Nextmap Voting Started" );
}

public void Handler_MapVoteFinished(Menu menu, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	if (g_cvMapVoteRunOff.BoolValue && num_items > 1)
	{
		float winningvotes = float(item_info[0][VOTEINFO_ITEM_VOTES]);
		float required = num_votes * (g_cvMapVoteRunOffPerc.FloatValue / 100.0);
		
		if (winningvotes < required)
		{
			/* Insufficient Winning margin - Lets do a runoff */
			g_VoteMenu = new Menu(Handler_MapVoteMenu, MENU_ACTIONS_ALL);
			g_VoteMenu.SetTitle("Runoff Vote Nextmap");
			g_VoteMenu.VoteResultCallback = Handler_VoteFinishedGeneric;

			char map[PLATFORM_MAX_PATH];
			char info1[PLATFORM_MAX_PATH];
			char info2[PLATFORM_MAX_PATH];
			
			menu.GetItem(item_info[0][VOTEINFO_ITEM_INDEX], map, sizeof(map), _, info1, sizeof(info1));
			g_VoteMenu.AddItem(map, info1);
			menu.GetItem(item_info[1][VOTEINFO_ITEM_INDEX], map, sizeof(map), _, info2, sizeof(info2));
			g_VoteMenu.AddItem(map, info2);
			
			int voteDuration = g_Cvar_VoteDuration.IntValue;
			g_VoteMenu.ExitButton = true;
			g_VoteMenu.DisplayVoteToAll(voteDuration);
			
			/* Notify */
			float map1percent = float(item_info[0][VOTEINFO_ITEM_VOTES])/ float(num_votes) * 100;
			float map2percent = float(item_info[1][VOTEINFO_ITEM_VOTES])/ float(num_votes) * 100;
			
			
			PrintToChatAll("[SM] %t", "Starting Runoff", g_Cvar_RunOffPercent.FloatValue, info1, map1percent, info2, map2percent);
			LogMessage("Voting for next map was indecisive, beginning runoff vote");
					
			return;
		}
	}
	
	Handler_VoteFinishedGeneric(menu, num_votes, num_clients, client_info, num_items, item_info);
}



public void Handler_MapVoteFinished(Menu menu, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	char map[PLATFORM_MAX_PATH];
	char displayName[PLATFORM_MAX_PATH];
	
	if( num_votes == 0 )
	{
		menu.GetItem( GetRandomInt( 0, num_votes - 1 ), map, sizeof(map) ); // if no votes, pick a random selection from the vote options
	}
	else
	{
		menu.GetItem(item_info[0][VOTEINFO_ITEM_INDEX], map, sizeof(map), _, displayName, sizeof(displayName));
	}
	
	PrintToChatAll( "#1 vote was %s (%s)", map, (g_ChangeTime == MapChange_Instant) ? "instant" : "map end" );
	
	if( StrEqual( map, "extend" ) )
	{
		g_iExtendCount++;
		
		int time;
		if( GetMapTimeLimit( time ) )
		{
			if( time > 0 )
			{
				ExtendMapTimeLimit( g_cvMapVoteExtendTime.IntValue * 60 );						
			}
		}

		PrintToChatAll( "[SMC] Voting for next map has finished. The current map has been extended." );
		
		// We extended, so we'll have to vote again.
		g_bMapVoteStarted = false;
		
		ClearRTV();
	}
	else if( StrEqual( map, "dontchange" ) )
	{
		g_bMapVoteFinished = false;
		g_bMapVoteStarted = false;
		
		PrintToChatAll( "[SMC] The map will continue" );
		
		ClearRTV();
	}
	else
	{	
		if( g_ChangeTime == MapChange_MapEnd )
		{
			SetNextMap(map);
		}
		else if( g_ChangeTime == MapChange_Instant )
		{
			DataPack data;
			CreateDataTimer(2.0, Timer_ChangeMap, data);
			data.WriteString(map);
		}
		
		g_bMapVoteStarted = false;
		g_bMapVoteFinished = true;
		
		PrintToChatAll( "[SMC] Voting for next map has finished. Next map: %s.", map );
	}	
}

public int Handler_MapVoteMenu( Menu menu, MenuAction action, int param1, int param2 )
{
	switch( action )
	{
		case MenuAction_End:
		{
			delete menu;
		}
		
		case MenuAction_Display:
		{
			Panel panel = view_as<Panel>(param2);
			panel.SetTitle( "Vote Nextmap" );
		}		
		
		case MenuAction_DisplayItem:
		{
			if (menu.ItemCount - 1 == param2)
			{
				char map[PLATFORM_MAX_PATH], buffer[255];
				menu.GetItem(param2, map, sizeof(map));
				if (strcmp(map, "extend", false) == 0)
				{
					Format( buffer, sizeof(buffer), "Extend Map" );
					return RedrawMenuItem(buffer);
				}
				else if (strcmp(map, "novote", false) == 0)
				{
					Format( buffer, sizeof(buffer), "No Vote" );
					return RedrawMenuItem(buffer);					
				}
			}
		}		
	
		case MenuAction_VoteCancel:
		{
			// If we receive 0 votes, pick at random.
			if( param1 == VoteCancel_NoVotes )
			{
				int count = menu.ItemCount;
				char map[PLATFORM_MAX_PATH];
				menu.GetItem(0, map, sizeof(map));
				
				// Make sure the first map in the menu isn't one of the special items.
				// This would mean there are no real maps in the menu, because the special items are added after all maps. Don't do anything if that's the case.
				if( strcmp( map, "extend", false ) != 0 )
				{
					// Get a random map from the list.
					
					// Make sure it's not one of the special items.
					do
					{
						int item = GetRandomInt(0, count - 1);
						menu.GetItem(item, map, sizeof(map));
					}
					while( strcmp( map, "extend", false ) == 0 );
					
					SetNextMap( map );
					g_bMapVoteFinished = true;
				}
			}
			else
			{
				// We were actually cancelled. I guess we do nothing.
			}
			
			g_bMapVoteStarted = false;
		}
	}
	
	return 0;
}

// extends map while also notifying players and setting plugin data
void ExtendMap( int time = 0 )
{
	if( time == 0 )
	{
		time = RoundFloat( g_cvMapVoteExtendTime.FloatValue * 60 );
	}

	ExtendMapTimeLimit( time );
	PrintToChatAll( "[SMC] The map was extended for %.1f minutes", time / 60.0 );
	
	g_bMapVoteStarted = false;
	g_bMapVoteFinished = false;
}

void LoadMapList()
{
	g_aMapList.Clear();
	g_aMapTiers.Clear();

	MapListType type = view_as<MapListType>( g_cvMapListType.IntValue );
	switch( type )
	{
		case MapListZoned:
		{
			delete g_hDatabase;
			SQL_SetPrefix();
			
			char buffer[512];
			g_hDatabase = SQL_Connect( "shavit", true, buffer, sizeof(buffer) );

			Format( buffer, sizeof(buffer), "SELECT zones.map, tiers.tier FROM `%smapzones` zones JOIN `%smaptiers` tiers ON zones.map = tiers.map WHERE type = 1 AND track = 0 ORDER BY `map`", g_cSQLPrefix, g_cSQLPrefix );
			g_hDatabase.Query( LoadZonedMapsCallback, buffer, _, DBPrio_High );
		}
		case MapListFolder:
		{
			LoadFromMapsFolder( g_aMapList );
		}
		case MapListFile:
		{
			ReadMapList( g_aMapList, _, "default" );
		}
	}
}

public void LoadZonedMapsCallback( Database db, DBResultSet results, const char[] error, any data )
{
	if( results == null )
	{
		LogError( "[SMC] - (LoadMapZonesCallback) - %s", error );
		return;	
	}

	char map[PLATFORM_MAX_PATH];
	char map2[PLATFORM_MAX_PATH];
	while( results.FetchRow() )
	{	
		results.FetchString( 0, map, sizeof(map) );
		
		
		if( ( FindMap( map, map2, sizeof(map2) ) == FindMap_Found ) || ( FindMap( map, map2, sizeof(map2) ) == FindMap_FuzzyMatch ) )
		{						  
			g_aMapList.PushString( map2 );
			g_aMapTiers.Push( results.FetchInt( 1 ) );
		}
	}
	
	CreateNominateMenu();
}

bool SMC_FindMap( const char[] mapname, char[] output, int maxlen )
{
	int length = g_aMapList.Length;	
	for( int i = 0; i < length; i++ )
	{
		char entry[PLATFORM_MAX_PATH];
		g_aMapList.GetString( i, entry, sizeof(entry) );
		
		if( StrContains( entry, mapname ) != -1 )
		{
			strcopy( output, maxlen, entry );
			return true;
		}
	}
	
	return false;
}

bool IsRTVEnabled()
{
	float time = GetGameTime();
	return ( time - g_fMapStartTime > g_cvRTVDelayTime.FloatValue * 60 );
}

void ClearRTV()
{
	for( int i = 1; i <= MaxClients; i++ )
	{
		g_bRockTheVote[i] = false;
	}
}

/* Timers */
public Action Timer_ChangeMap( Handle timer, DataPack data )
{
	char map[PLATFORM_MAX_PATH];
	data.Reset();
	data.ReadString( map, sizeof(map) );
	ForceChangeLevel( map, "RTV Mapvote" );
}

/* Commands */
public Action Command_Extend( int client, int args )
{
	int extendtime;
	if( args > 0 )
	{
		char sArg[8];
		GetCmdArg( 1, sArg, sizeof(sArg) );
		extendtime = RoundFloat( StringToFloat( sArg ) * 60 );
	}
	else
	{
		extendtime = RoundFloat( g_cvMapVoteExtendTime.FloatValue * 60.0 );
	}
	
	ExtendMap( extendtime );
	
	return Plugin_Handled;
}

public Action Command_ForceMapVote( int client, int args )
{
	if( g_bMapVoteStarted || g_bMapVoteFinished )
	{
		ReplyToCommand( client, "[SMC] Map vote already %s", ( g_bMapVoteStarted ) ? "initiated" : "finished" );
	}
	else
	{
		InitiateMapVote( MapChange_Instant );
	}
	
	return Plugin_Handled;
}

public Action Command_ReloadMaplist( int client, int args )
{
	LoadMapList();
	
	return Plugin_Handled;
}

public Action Command_Nominate( int client, int args )
{
	if( args < 1 )
	{
		OpenNominateMenu( client );
		return Plugin_Handled;
	}
	
	char mapname[PLATFORM_MAX_PATH];
	GetCmdArg( 1, mapname, sizeof(mapname) );
	if( SMC_FindMap( mapname, mapname, sizeof(mapname) ) )
	{
		if( StrEqual( mapname, g_cMapName ) )
		{
			ReplyToCommand( client, "[SMC] %t", "Can't Nominate Current Map" );
			return Plugin_Handled;
		}
		
		int idx = g_aOldMaps.FindString( mapname );
		if( idx != -1 )
		{
			ReplyToCommand( client, "[SMC] %s %t", mapname, "Recently Played" );
			return Plugin_Handled;
		}
	
		ReplySource old = SetCmdReplySource( SM_REPLY_TO_CHAT );
		Nominate( client, mapname );
		SetCmdReplySource( old );
	}
	else
	{
		PrintToChatAll( "[SMC] %t", "Map was not found", mapname );
	}
	
	return Plugin_Handled;
}

public Action Command_UnNominate( int client, int args )
{
	if( g_cNominatedMap[client][0] == '\0' )
	{
		ReplyToCommand( client, "[SMC] You haven't nominated a map" );
		return Plugin_Handled;
	}

	int idx = g_aNominateList.FindString( g_cNominatedMap[client] );
	if( idx != -1 )
	{
		g_aNominateList.Erase( idx );
		g_cNominatedMap[client][0] = '\0';
	}

	ReplyToCommand( client, "[SMC] Successfully removed nomination for '%s'", g_cNominatedMap[client] );
	
	
	return Plugin_Handled;
}

void CreateNominateMenu()
{
	delete g_hNominateMenu;
	g_hNominateMenu = new Menu( NominateMenuHandler );
	
	g_hNominateMenu.SetTitle( "Nominate Menu" );
	
	int length = g_aMapList.Length;
	for( int i = 0; i < length; i++ )
	{
		int tier = g_aMapTiers.Get( i );
		
		char mapname[PLATFORM_MAX_PATH];
		g_aMapList.GetString( i, mapname, sizeof(mapname) );
		
		if( StrEqual( mapname, g_cMapName ) )
		{
			continue;
		}
		
		int idx = g_aOldMaps.FindString( mapname );
		if( idx != -1 )
		{
			continue;
		}
		
		char mapdisplay[PLATFORM_MAX_PATH + 32];
		GetMapDisplayName(mapname, mapdisplay, sizeof(mapdisplay));
		Format( mapdisplay, sizeof(mapdisplay), "%s (Tier %i)", mapdisplay, tier );
		
		
		g_hNominateMenu.AddItem( mapname, mapdisplay );
	}
}

void OpenNominateMenu( int client )
{
	g_hNominateMenu.Display( client, MENU_TIME_FOREVER );
}

public int NominateMenuHandler( Menu menu, MenuAction action, int param1, int param2 )
{
	if( action == MenuAction_Select )
	{
		char mapname[PLATFORM_MAX_PATH];
		menu.GetItem( param2, mapname, sizeof(mapname) );
		
		Nominate( param1, mapname );
	}
}

void Nominate( int client, const char mapname[PLATFORM_MAX_PATH] )
{
	int idx = g_aNominateList.FindString( mapname );
	if( idx != -1 )
	{
		ReplyToCommand( client, "[SMC] %t", "Map Already Nominated" );
		return;
	}
	
	if( g_cNominatedMap[client][0] != '\0' )
	{
		RemoveString( g_aNominateList, g_cNominatedMap[client] );
	}
	
	g_aNominateList.PushString( mapname );
	g_cNominatedMap[client] = mapname;
	char name[MAX_NAME_LENGTH];
	GetClientName( client, name, sizeof( name ) );
	
	PrintToChatAll("[SMC] %t", "Map Nominated", name, mapname );
}

public Action Command_RockTheVote( int client, int args )
{
	if( !IsRTVEnabled() )
	{
		ReplyToCommand( client, "[SMC] %t", "RTV Not Allowed" );
	}
	else if( g_bMapVoteStarted )
	{
		ReplyToCommand( client, "[SMC] %t", "RTV Started" );
	}
	else if( g_bRockTheVote[client] )
	{
		int needed = GetRTVVotesNeeded();
		ReplyToCommand( client, "[SMC] You have already RTVed, if you want to un-RTV use the command sm_unrtv (%i more %s needed)", needed, (needed == 1) ? "vote" : "votes" );
	}
	else if( g_cvRTVMinimumPoints.IntValue != -1 && Shavit_GetPoints( client ) <= g_cvRTVMinimumPoints.FloatValue )
	{
		ReplyToCommand( client, "[SMC] You must be a higher rank to RTV!" );
	}
	else if( GetClientTeam( client ) == CS_TEAM_SPECTATOR && !g_cvRTVAllowSpectators.BoolValue )
	{
		ReplyToCommand( client, "[SMC] Spectators have been blocked from RTVing" );
	}
	else
	{
		g_bRockTheVote[client] = true;
		CheckRTV( client );
	}
	
	return Plugin_Handled;
}

void CheckRTV( int client = 0 )
{
	int needed = GetRTVVotesNeeded();
	int total = GetRTVCount();
	char name[MAX_NAME_LENGTH];
	
	if( client != 0 )
	{
		GetClientName(client, name, sizeof(name));
	}
	if( needed > 0 )
	{
		if( client != 0 )
		{
			PrintToChatAll( "[SMC] %t", "RTV Requested", name, total, needed );
		}
	}
	else
	{
		if( g_bMapVoteFinished )
		{
			char map[PLATFORM_MAX_PATH];
			GetNextMap( map, sizeof(map) );
		
			if( client != 0 )
			{
				PrintToChatAll( "[SMC] %N wants to rock the vote! Map will now change to %s ...", client, map );
			}
			else
			{
				PrintToChatAll( "[SMC] RTV vote now majority, map changing to %s ...", map );
			}
			
			ChangeMapDelayed( map );
		}
		else
		{
			if( client != 0 )
			{
				PrintToChatAll( "[SMC] %N wants to rock the vote! Map vote will now start ...", client );
			}
			else
			{
				PrintToChatAll( "[SMC] RTV vote now majority, map vote starting ..." );
			}
			
			InitiateMapVote( MapChange_Instant );
		}
	}
}

public Action Command_UnRockTheVote( int client, int args )
{
	if( !IsRTVEnabled() )
	{
		ReplyToCommand( client, "[SMC] RTV has not been enabled yet" );
	}
	else if( g_bMapVoteStarted || g_bMapVoteFinished )
	{
		ReplyToCommand( client, "[SMC] Map vote already %s", ( g_bMapVoteStarted ) ? "initiated" : "finished" );
	}
	else if( g_bRockTheVote[client] )
	{
		g_bRockTheVote[client] = false;
		
		int needed = GetRTVVotesNeeded();
		if( needed > 0 )
		{
			PrintToChatAll( "[SMC] %N no longer wants to rock the vote! (%i more votes needed)", client, needed );
		}
	}

	return Plugin_Handled;
}

#if defined DEBUG
public Action Command_Debug( int client, int args )
{
	if( IsSlidy( client ) )
	{
		g_bDebug = !g_bDebug;
		ReplyToCommand( client, "[SMC] Debug mode: %s", g_bDebug ? "ENABLED" : "DISABLED" );
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
#endif

/* Stocks */
stock void SQL_SetPrefix()
{
	char sFile[PLATFORM_MAX_PATH];
	BuildPath( Path_SM, sFile, sizeof(sFile), "configs/shavit-prefix.txt" );

	File fFile = OpenFile( sFile, "r" );
	if( fFile == null )
	{
		SetFailState("Cannot open \"configs/shavit-prefix.txt\". Make sure this file exists and that the server has read permissions to it.");
	}

	char sLine[PLATFORM_MAX_PATH*2];
	while( fFile.ReadLine( sLine, sizeof(sLine) ) )
	{
		TrimString( sLine );
		strcopy( g_cSQLPrefix, sizeof(g_cSQLPrefix), sLine );

		break;
	}

	delete fFile;	
}

stock void RemoveString( ArrayList array, const char[] target )
{
	int idx = array.FindString( target );
	if( idx != -1 )
	{
		array.Erase( idx );
	}
}

stock bool LoadFromMapsFolder( ArrayList list )
{
	//from yakmans maplister plugin
	DirectoryListing mapdir = OpenDirectory("maps/");
	if( mapdir == null )
		return false;
	
	char name[PLATFORM_MAX_PATH];
	FileType filetype;
	int namelen;
	
	while( mapdir.GetNext( name, sizeof(name), filetype ) )
	{
		if( filetype != FileType_File )
			continue;
				
		namelen = strlen( name ) - 4;
		if( StrContains( name, ".bsp", false ) != namelen )
			continue;
				
		name[namelen] = '\0';
			
		list.PushString( name );
	}

	delete mapdir;

	return true;
}

stock void ChangeMapDelayed( const char[] map, float delay = 2.0 )
{
	DataPack data;
	CreateDataTimer( delay, Timer_ChangeMap, data );
	data.WriteString( map );
}

stock int GetRTVVotesNeeded()
{
	int total = 0;
	int rtvcount = 0;
	for( int i = 1; i <= MaxClients; i++ )
	{
		if( IsClientInGame( i ) )
		{
			// dont count players that can't vote
			if( !g_cvRTVAllowSpectators.BoolValue && IsClientObserver( i ) )
			{
				continue;
			}
			
			if( g_cvRTVMinimumPoints.IntValue != -1 && Shavit_GetPoints( i ) <= g_cvRTVMinimumPoints.FloatValue )
			{
				continue;
			}
		
			total++;
			if( g_bRockTheVote[i] )
			{
				rtvcount++;
			}
		}
	}
	
	int Needed = RoundToFloor( total * (g_cvRTVRequiredPercentage.FloatValue / 100) );
	
	// always clamp to 1, so if rtvcount is 0 it never initiates RTV
	if( Needed < 1 )
	{
		Needed = 1;
	}
	
	return Needed - rtvcount;
}

stock int GetRTVCount()
{
	int rtvcount = 0;
	for( int i = 1; i <= MaxClients; i++ )
	{
		if( IsClientInGame( i ) )
		{
			// dont count players that can't vote
			if( !g_cvRTVAllowSpectators.BoolValue && IsClientObserver( i ) )
			{
				continue;
			}
			
			if( g_cvRTVMinimumPoints.IntValue != -1 && Shavit_GetPoints( i ) <= g_cvRTVMinimumPoints.FloatValue )
			{
				continue;
			}
			if( g_bRockTheVote[i] )
			{
				rtvcount++;
			}
		}
	}
	
	return rtvcount;
}

stock void DebugPrint( const char[] message, any ... )
{		
	char buffer[256];
	VFormat( buffer, sizeof( buffer ), message, 2 );
	
	for( int i = 1; i <= MaxClients; i++ )
	{
		// STEAM_1:1:159678344 (SlidyBat)
		if( GetSteamAccountID( i ) == 319356689 )
		{
			PrintToChat( i, buffer );
			return;
		}
	}
}

