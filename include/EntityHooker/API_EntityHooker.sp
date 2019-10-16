#include <sourcemod>
#include <sdkhooks>
#include <sdktools_functions>
#include <sdktools_tempents>
#include <sdktools_tempents_stocks>
#include "../DatabaseCore/database_core"
#include "../DatabaseMaps/database_maps"
#include <hls_color_chat>

#pragma semicolon 1

new const String:PLUGIN_NAME[] = "API: Entity Hooker";
new const String:PLUGIN_VERSION[] = "1.8";

public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = "hlstriker",
	description = "An API to hook entities.",
	version = PLUGIN_VERSION,
	url = "www.swoobles.com"
}

#define MAX_CLASSNAME_LEN	48
#define MAX_DATA_NAME_LEN	48
#define MAX_PROPERTY_LEN	48

#define SOLID_NONE	0

new g_iUniqueMapCounter;

new Handle:g_aHookData;
enum _:HookData
{
	HOOK_DATA_TYPE,
	String:HOOK_DATA_NAME[MAX_DATA_NAME_LEN],
	Handle:HOOK_DATA_ENTITY_CLASSNAMES
};

new Handle:g_aTrie_HookedEntityMap;
new Handle:g_aHookedEntities;
enum _:HookedEntity
{
	HOOKED_ENT_DATA_TYPE,
	HOOKED_ENT_HAMMER_ID,
	String:HOOKED_ENT_CLASSNAME[MAX_CLASSNAME_LEN],
	HOOKED_ENT_CUSTOM_DATA_1
};

new Handle:g_aHookDataProperties;
enum _:HookDataProperty
{
	HOOK_PROP_DATA_TYPE,
	PropType:HOOK_PROP_PROP_TYPE,
	PropFieldType:HOOK_PROP_FIELD_TYPE,
	String:HOOK_PROP_PROPERTY[MAX_PROPERTY_LEN]
};

enum
{
	ENT_SELECT_TYPE_NEXT = 1,
	ENT_SELECT_TYPE_PREV,
	ENT_SELECT_TYPE_HOOK,
	ENT_SELECT_TYPE_UNHOOK
};

new Handle:g_hFwd_OnRegisterReady;
new Handle:g_hFwd_OnEntityHooked;
new Handle:g_hFwd_OnEntityUnhooked;
new Handle:g_hFwd_OnInitialHooksReady;

new g_iStartEnt[MAXPLAYERS+1];

new g_iHookDataIndex[MAXPLAYERS+1];

new bool:g_bInitialEntitiesHooked;

new Handle:cvar_database_servers_configname;
new String:g_szDatabaseConfigName[64];

new const Float:DISPLAY_BOX_DELAY = 0.1;
new Float:g_fNextDisplayBoxTime[MAXPLAYERS+1];

new const Float:BOX_BEAM_WIDTH = 2.5;
new const BOX_BEAM_COLOR[] = {0, 255, 255, 220};

new g_iBeamIndex;
new const String:SZ_BEAM_MATERIAL[] = "materials/sprites/laserbeam.vmt";

new g_iClassNameSelectStartItem[MAXPLAYERS+1];


public OnPluginStart()
{
	CreateConVar("api_entity_hooker_ver", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_PRINTABLEONLY);
	
	g_aHookData = CreateArray(HookData);
	g_aHookedEntities = CreateArray(HookedEntity);
	g_aHookDataProperties = CreateArray(HookDataProperty);
	
	g_aTrie_HookedEntityMap = CreateTrie();
	
	g_hFwd_OnRegisterReady = CreateGlobalForward("EntityHooker_OnRegisterReady", ET_Ignore);
	g_hFwd_OnEntityHooked = CreateGlobalForward("EntityHooker_OnEntityHooked", ET_Ignore, Param_Cell, Param_Cell);
	g_hFwd_OnEntityUnhooked = CreateGlobalForward("EntityHooker_OnEntityUnhooked", ET_Ignore, Param_Cell, Param_Cell);
	g_hFwd_OnInitialHooksReady = CreateGlobalForward("EntityHooker_OnInitialHooksReady", ET_Ignore);
	
	RegAdminCmd("sm_enthook", Command_EntityHook, ADMFLAG_ROOT, "sm_enthook - Opens the entity hook menu.");
	
	HookEvent("round_start", Event_RoundStart_Pre, EventHookMode_Pre);
	HookEvent("round_prestart", Event_RoundPrestart_Post, EventHookMode_PostNoCopy);
}

public OnAllPluginsLoaded()
{
	cvar_database_servers_configname = FindConVar("sm_database_servers_configname");
}

public DB_OnStartConnectionSetup()
{
	if(cvar_database_servers_configname != INVALID_HANDLE)
		GetConVarString(cvar_database_servers_configname, g_szDatabaseConfigName, sizeof(g_szDatabaseConfigName));
}

public APLRes:AskPluginLoad2(Handle:hMyself, bool:bLate, String:szError[], iErrLen)
{
	RegPluginLibrary("entity_hooker");
	CreateNative("EntityHooker_Register", _EntityHooker_Register);
	CreateNative("EntityHooker_RegisterAdditional", _EntityHooker_RegisterAdditional);
	CreateNative("EntityHooker_RegisterProperty", _EntityHooker_RegisterProperty);
	CreateNative("EntityHooker_IsEntityHooked", _EntityHooker_IsEntityHooked);
	
	return APLRes_Success;
}

GetHookedEntityIndex(iDataType, iHammerID)
{
	static String:szBuffer[24];
	FormatEx(szBuffer, sizeof(szBuffer), "%i/%i", iDataType, iHammerID);
	
	static iHookedEntityIndex;
	if(!GetTrieValue(g_aTrie_HookedEntityMap, szBuffer, iHookedEntityIndex))
		return -1;
	
	return iHookedEntityIndex;
}

public _EntityHooker_IsEntityHooked(Handle:hPlugin, iNumParams)
{
	if(iNumParams != 2)
		return false;
	
	new iDataType = GetNativeCell(1);
	new iHammerID = GetEntProp(GetNativeCell(2), Prop_Data, "m_iHammerID");
	
	if(GetHookedEntityIndex(iDataType, iHammerID) == -1)
		return false;
	
	return true;
}

public _EntityHooker_RegisterAdditional(Handle:hPlugin, iNumParams)
{
	if(iNumParams < 2)
		return false;
	
	new iHookType = GetNativeCell(1);
	new iArraySize = GetArraySize(g_aHookData);
	
	decl eHookData[HookData], iIndex;
	for(iIndex=0; iIndex<iArraySize; iIndex++)
	{
		GetArrayArray(g_aHookData, iIndex, eHookData);
		if(iHookType == eHookData[HOOK_DATA_TYPE])
			break;
	}
	
	if(iIndex >= iArraySize)
		return false;
	
	if(eHookData[HOOK_DATA_ENTITY_CLASSNAMES] == INVALID_HANDLE)
		eHookData[HOOK_DATA_ENTITY_CLASSNAMES] = CreateArray(MAX_CLASSNAME_LEN);
	
	decl String:szClassName[MAX_CLASSNAME_LEN];
	for(new i=2; i<=iNumParams; i++)
	{
		GetNativeString(i, szClassName, sizeof(szClassName));
		PushArrayString(eHookData[HOOK_DATA_ENTITY_CLASSNAMES], szClassName);
	}
	
	SetArrayArray(g_aHookData, iIndex, eHookData);
	
	return true;
}

public _EntityHooker_RegisterProperty(Handle:hPlugin, iNumParams)
{
	if(iNumParams != 4)
		return false;
	
	new iHookType = GetNativeCell(1);
	new PropType:iPropType = GetNativeCell(2);
	new PropFieldType:iFieldType = GetNativeCell(3);
	
	decl String:szProperty[MAX_PROPERTY_LEN];
	GetNativeString(4, szProperty, sizeof(szProperty));
	
	decl eHookDataProperty[HookDataProperty];
	for(new i=0; i<GetArraySize(g_aHookDataProperties); i++)
	{
		GetArrayArray(g_aHookDataProperties, i, eHookDataProperty);
		
		if(iHookType != eHookDataProperty[HOOK_PROP_DATA_TYPE])
			continue;
		
		if(iPropType != eHookDataProperty[HOOK_PROP_PROP_TYPE])
			continue;
		
		if(iFieldType != eHookDataProperty[HOOK_PROP_FIELD_TYPE])
			continue;
		
		if(!StrEqual(szProperty, eHookDataProperty[HOOK_PROP_PROPERTY]))
			continue;
		
		return true;
	}
	
	eHookDataProperty[HOOK_PROP_DATA_TYPE] = iHookType;
	eHookDataProperty[HOOK_PROP_PROP_TYPE] = iPropType;
	eHookDataProperty[HOOK_PROP_FIELD_TYPE] = iFieldType;
	strcopy(eHookDataProperty[HOOK_PROP_PROPERTY], MAX_PROPERTY_LEN, szProperty);
	
	PushArrayArray(g_aHookDataProperties, eHookDataProperty);
	
	return true;
}

public _EntityHooker_Register(Handle:hPlugin, iNumParams)
{
	if(iNumParams < 2)
		return false;
	
	new iHookType = GetNativeCell(1);
	
	decl eHookData[HookData];
	for(new i=0; i<GetArraySize(g_aHookData); i++)
	{
		GetArrayArray(g_aHookData, i, eHookData);
		if(iHookType != eHookData[HOOK_DATA_TYPE])
			continue;
		
		if(eHookData[HOOK_DATA_ENTITY_CLASSNAMES] != INVALID_HANDLE)
			CloseHandle(eHookData[HOOK_DATA_ENTITY_CLASSNAMES]);
		
		RemoveFromArray(g_aHookData, i);
		break;
	}
	
	eHookData[HOOK_DATA_TYPE] = iHookType;
	eHookData[HOOK_DATA_ENTITY_CLASSNAMES] = CreateArray(MAX_CLASSNAME_LEN);
	GetNativeString(2, eHookData[HOOK_DATA_NAME], MAX_DATA_NAME_LEN);
	
	decl String:szClassName[MAX_CLASSNAME_LEN];
	for(new i=3; i<=iNumParams; i++)
	{
		GetNativeString(i, szClassName, sizeof(szClassName));
		PushArrayString(eHookData[HOOK_DATA_ENTITY_CLASSNAMES], szClassName);
	}
	
	PushArrayArray(g_aHookData, eHookData);
	
	return true;
}

public OnMapStart()
{
	for(new i=0; i<sizeof(g_iStartEnt); i++)
		g_iStartEnt[i] = INVALID_ENT_REFERENCE;
	
	g_bInitialEntitiesHooked = false;
	g_iBeamIndex = PrecacheModel(SZ_BEAM_MATERIAL);
	
	g_iUniqueMapCounter++;
	
	decl eHookData[HookData];
	for(new i=0; i<GetArraySize(g_aHookData); i++)
	{
		GetArrayArray(g_aHookData, i, eHookData);
		
		if(eHookData[HOOK_DATA_ENTITY_CLASSNAMES] != INVALID_HANDLE)
			CloseHandle(eHookData[HOOK_DATA_ENTITY_CLASSNAMES]);
	}
	
	ClearArray(g_aHookData);
	ClearArray(g_aHookedEntities);
	ClearArray(g_aHookDataProperties);
	
	ClearTrie(g_aTrie_HookedEntityMap);
	
	Forward_OnRegisterReady();
}

public Event_RoundPrestart_Post(Handle:hEvent, const String:szName[], bool:bDontBroadcast)
{
	g_bInitialEntitiesHooked = false;
}

public Event_RoundStart_Pre(Handle:hEvent, const String:szName[], bool:bDontBroadcast)
{
	RehookEntities();
}

Forward_OnRegisterReady()
{
	decl result;
	Call_StartForward(g_hFwd_OnRegisterReady);
	Call_Finish(result);
}

public DBServers_OnServerIDReady(iServerID, iGameID)
{
	if(!Query_CreateTable_EntityHooker())
		return;
}

bool:Query_CreateTable_EntityHooker()
{
	static bool:bTableCreated = false;
	if(bTableCreated)
		return true;
	
	new Handle:hQuery = DB_Query(g_szDatabaseConfigName, "\
	CREATE TABLE IF NOT EXISTS plugin_entity_hooker\
	(\
		map_id			MEDIUMINT UNSIGNED	NOT NULL,\
		hook_type		SMALLINT UNSIGNED	NOT NULL,\
		hammer_id		INT UNSIGNED		NOT NULL,\
		ent_classname	VARCHAR( 255 )		NOT NULL,\
		custom_data_1	INT					NOT NULL,\
		PRIMARY KEY ( map_id, hook_type, hammer_id )\
	) ENGINE = INNODB");
	
	if(hQuery == INVALID_HANDLE)
	{
		LogError("There was an error creating the plugin_entity_hooker sql table.");
		return false;
	}
	
	DB_CloseQueryHandle(hQuery);
	bTableCreated = true;
	
	return true;
}

public DBMaps_OnMapIDReady(iMapID)
{
	DB_TQuery(g_szDatabaseConfigName, Query_GetHookedEntities, DBPrio_High, g_iUniqueMapCounter, "SELECT hook_type, hammer_id, ent_classname, custom_data_1 FROM plugin_entity_hooker WHERE map_id=%i", iMapID);
}

public Query_GetHookedEntities(Handle:hDatabase, Handle:hQuery, any:iUniqueMapCounter)
{
	if(g_iUniqueMapCounter != iUniqueMapCounter)
		return;
	
	if(hQuery == INVALID_HANDLE)
		return;
	
	decl String:szClassName[MAX_CLASSNAME_LEN];
	while(SQL_FetchRow(hQuery))
	{
		SQL_FetchString(hQuery, 2, szClassName, sizeof(szClassName));
		AddHookedEntityToArray(SQL_FetchInt(hQuery, 0), SQL_FetchInt(hQuery, 1), szClassName, SQL_FetchInt(hQuery, 3));
	}
	
	RehookEntities();
}

AddHookedEntityToTrieMap(iDataType, iHammerID, iHookedEntityIndex)
{
	static String:szBuffer[24];
	FormatEx(szBuffer, sizeof(szBuffer), "%i/%i", iDataType, iHammerID);
	
	SetTrieValue(g_aTrie_HookedEntityMap, szBuffer, iHookedEntityIndex, true);
}

AddHookedEntityToArray(iDataType, iHammerID, String:szClassName[], iCustomData1)
{
	// Return if this data type and hammerID combination is already in the hooked entity array.
	if(GetHookedEntityIndex(iDataType, iHammerID) != -1)
		return;
	
	decl eHookedEntity[HookedEntity];
	eHookedEntity[HOOKED_ENT_DATA_TYPE] = iDataType;
	eHookedEntity[HOOKED_ENT_HAMMER_ID] = iHammerID;
	strcopy(eHookedEntity[HOOKED_ENT_CLASSNAME], MAX_CLASSNAME_LEN, szClassName);
	
	eHookedEntity[HOOKED_ENT_CUSTOM_DATA_1] = iCustomData1;
	
	new iIndex = PushArrayArray(g_aHookedEntities, eHookedEntity);
	AddHookedEntityToTrieMap(iDataType, iHammerID, iIndex);
}

RemoveHookedEntityFromTrieMap(iDataType, iHammerID)
{
	static String:szBuffer[24];
	FormatEx(szBuffer, sizeof(szBuffer), "%i/%i", iDataType, iHammerID);
	
	RemoveFromTrie(g_aTrie_HookedEntityMap, szBuffer);
}

RemoveHookedEntityFromArray(iDataType, iHammerID)
{
	decl eHookedEntity[HookedEntity];
	for(new i=0; i<GetArraySize(g_aHookedEntities); i++)
	{
		GetArrayArray(g_aHookedEntities, i, eHookedEntity);
		
		if(iDataType != eHookedEntity[HOOKED_ENT_DATA_TYPE])
			continue;
		
		if(iHammerID != eHookedEntity[HOOKED_ENT_HAMMER_ID])
			continue;
		
		RemoveFromArray(g_aHookedEntities, i);
		RemoveHookedEntityFromTrieMap(iDataType, iHammerID);
		break;
	}
}

RehookEntities()
{
	new iArraySize = GetArraySize(g_aHookedEntities);
	
	decl eHookedEntity[HookedEntity], iEnt;
	for(new i=0; i<iArraySize; i++)
	{
		GetArrayArray(g_aHookedEntities, i, eHookedEntity);
		
		iEnt = -1;
		while((iEnt = FindEntityByClassname(iEnt, eHookedEntity[HOOKED_ENT_CLASSNAME])) != -1)
		{
			if(GetEntProp(iEnt, Prop_Data, "m_iHammerID") != eHookedEntity[HOOKED_ENT_HAMMER_ID])
				continue;
			
			Forward_OnEntityHooked(eHookedEntity[HOOKED_ENT_DATA_TYPE], iEnt);
			break;
		}
	}
	
	Forward_OnInitialHooksReady();
}

public OnEntityCreated(iEnt, const String:szClassName[])
{
	if(!g_bInitialEntitiesHooked/* || !IsValidEntity(iEnt)*/)
		return;
	
	RequestFrame(OnEntityCreated_NextFrame, iEnt < 0 ? iEnt : EntIndexToEntRef(iEnt));
	
	/*
	// Can't get the hammerID until the entity spawns.. at least for ents created by point_template.
	SDKHook(iEnt, SDKHook_SpawnPost, OnEntitySpawnPost);
	*/
}

public OnEntityCreated_NextFrame(any:iData)
{
	new iEnt = EntRefToEntIndex(iData);
	if(iEnt == INVALID_ENT_REFERENCE)
		return;
	
	static iHammerID;
	iHammerID = GetEntProp(iEnt, Prop_Data, "m_iHammerID");
	
	if(!iHammerID)
		return;
	
	static iDataType, i, iArraySize;
	iArraySize = GetArraySize(g_aHookData);
	
	for(i=0; i<iArraySize; i++)
	{
		iDataType = GetArrayCell(g_aHookData, i);
		
		if(GetHookedEntityIndex(iDataType, iHammerID) != -1)
			Forward_OnEntityHooked(iDataType, iEnt);
	}
}

/*
public OnEntitySpawnPost(iEnt)
{
	SDKUnhook(iEnt, SDKHook_SpawnPost, OnEntitySpawnPost);
	
	static iHammerID;
	iHammerID = GetEntProp(iEnt, Prop_Data, "m_iHammerID");
	if(!iHammerID)
		return;
	
	static iDataType, i, iArraySize;
	iArraySize = GetArraySize(g_aHookData);
	
	for(i=0; i<iArraySize; i++)
	{
		iDataType = GetArrayCell(g_aHookData, i);
		
		if(GetHookedEntityIndex(iDataType, iHammerID) != -1)
			Forward_OnEntityHooked(iDataType, iEnt);
	}
}
*/

Forward_OnInitialHooksReady()
{
	decl result;
	Call_StartForward(g_hFwd_OnInitialHooksReady);
	Call_Finish(result);
	
	g_bInitialEntitiesHooked = true;
}

Forward_OnEntityHooked(iHookType, iEnt)
{
	decl result;
	Call_StartForward(g_hFwd_OnEntityHooked);
	Call_PushCell(iHookType);
	Call_PushCell(iEnt);
	Call_Finish(result);
}

Forward_OnEntityUnhooked(iHookType, iEnt)
{
	decl result;
	Call_StartForward(g_hFwd_OnEntityUnhooked);
	Call_PushCell(iHookType);
	Call_PushCell(iEnt);
	Call_Finish(result);
}

CreateNewEntityHook(iClient, iHookType, iEnt, iCustomData1)
{
	new iHammerID = GetEntProp(iEnt, Prop_Data, "m_iHammerID");
	
	if(iHammerID < 1)
	{
		CPrintToChat(iClient, "{green}[{lightred}SM{green}] {red}Cannot hook entities without an ID.");
		return;
	}
	
	decl String:szClassName[MAX_CLASSNAME_LEN];
	GetEntityClassname(iEnt, szClassName, sizeof(szClassName));
	
	DB_TQuery(g_szDatabaseConfigName, _, DBPrio_Low, _, "\
		INSERT INTO plugin_entity_hooker \
		(map_id, hook_type, hammer_id, ent_classname, custom_data_1) \
		VALUES \
		(%i, %i, %i, '%s', %i) \
		ON DUPLICATE KEY UPDATE ent_classname='%s', custom_data_1=%i",
		DBMaps_GetMapID(), iHookType, iHammerID, szClassName, iCustomData1, szClassName, iCustomData1);
	
	AddHookedEntityToArray(iHookType, iHammerID, szClassName, iCustomData1);
	Forward_OnEntityHooked(iHookType, iEnt);
}

RemoveEntityHook(iHookType, iEnt)
{
	new iHammerID = GetEntProp(iEnt, Prop_Data, "m_iHammerID");
	
	DB_TQuery(g_szDatabaseConfigName, _, DBPrio_Low, _, "\
		DELETE FROM plugin_entity_hooker \
		WHERE map_id=%i AND hook_type=%i AND hammer_id=%i",
		DBMaps_GetMapID(), iHookType, iHammerID);
	
	RemoveHookedEntityFromArray(iHookType, iHammerID);
	Forward_OnEntityUnhooked(iHookType, iEnt);
}

public Action:Command_EntityHook(iClient, iArgs)
{
	DisplayMenu_HookTypeSelect(iClient);
	return Plugin_Handled;
}

DisplayMenu_HookTypeSelect(iClient)
{
	new Handle:hMenu = CreateMenu(MenuHandle_HookTypeSelect);
	SetMenuTitle(hMenu, "Select type");
	
	decl eHookData[HookData], String:szInfo[12];
	for(new i=0; i<GetArraySize(g_aHookData); i++)
	{
		GetArrayArray(g_aHookData, i, eHookData);
		
		IntToString(i, szInfo, sizeof(szInfo));
		AddMenuItem(hMenu, szInfo, eHookData[HOOK_DATA_NAME]);
	}
	
	if(!DisplayMenu(hMenu, iClient, 0))
	{
		CPrintToChat(iClient, "{green}[{lightred}SM{green}] {red}There are no plugins using the entity hooker.");
		return;
	}
	
	SDKHook(iClient, SDKHook_PreThinkPost, OnPreThinkPost);
}

public MenuHandle_HookTypeSelect(Handle:hMenu, MenuAction:action, iParam1, iParam2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}
	
	if(action == MenuAction_Cancel)
	{
		SDKUnhook(iParam1, SDKHook_PreThinkPost, OnPreThinkPost);
		return;
	}
	
	if(action != MenuAction_Select)
		return;
	
	decl String:szInfo[12];
	GetMenuItem(hMenu, iParam2, szInfo, sizeof(szInfo));
	
	DisplayMenu_ClassNameSelect(iParam1, StringToInt(szInfo));
}

DisplayMenu_ClassNameSelect(iClient, iHookDataIndex, iStartItem=0)
{
	g_iHookDataIndex[iClient] = iHookDataIndex;
	
	decl eHookData[HookData];
	GetArrayArray(g_aHookData, iHookDataIndex, eHookData);
	
	if(eHookData[HOOK_DATA_ENTITY_CLASSNAMES] == INVALID_HANDLE || !GetArraySize(eHookData[HOOK_DATA_ENTITY_CLASSNAMES]))
	{
		CPrintToChat(iClient, "{green}[{lightred}SM{green}] {red}There are no entity classnames for this hook.");
		DisplayMenu_HookTypeSelect(iClient);
		return;
	}
	
	new Handle:hMenu = CreateMenu(MenuHandle_ClassNameSelect);
	
	decl String:szBuffer[128];
	strcopy(szBuffer, sizeof(szBuffer), eHookData[HOOK_DATA_NAME]);
	StrCat(szBuffer, sizeof(szBuffer), "\nSelect entity type");
	SetMenuTitle(hMenu, szBuffer);
	
	decl String:szInfo[24];
	for(new i=0; i<GetArraySize(eHookData[HOOK_DATA_ENTITY_CLASSNAMES]); i++)
	{
		GetArrayString(eHookData[HOOK_DATA_ENTITY_CLASSNAMES], i, szBuffer, sizeof(szBuffer));
		
		FormatEx(szInfo, sizeof(szInfo), "%i/%i", iHookDataIndex, i);
		AddMenuItem(hMenu, szInfo, szBuffer);
	}
	
	SetMenuExitBackButton(hMenu, true);
	if(!DisplayMenuAtItem(hMenu, iClient, iStartItem, 0))
	{
		CPrintToChat(iClient, "{green}[{lightred}SM{green}] {red}Problem displaying classnames menu.");
		return;
	}
	
	SDKHook(iClient, SDKHook_PreThinkPost, OnPreThinkPost);
}

public MenuHandle_ClassNameSelect(Handle:hMenu, MenuAction:action, iParam1, iParam2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}
	
	if(action == MenuAction_Cancel)
	{
		SDKUnhook(iParam1, SDKHook_PreThinkPost, OnPreThinkPost);
		
		if(iParam2 == MenuCancel_ExitBack)
			DisplayMenu_HookTypeSelect(iParam1);
		
		return;
	}
	
	if(action != MenuAction_Select)
		return;
	
	g_iClassNameSelectStartItem[iParam1] = GetMenuSelectionPosition();
	
	decl String:szInfo[24];
	GetMenuItem(hMenu, iParam2, szInfo, sizeof(szInfo));
	
	decl String:szExplode[2][12];
	ExplodeString(szInfo, "/", szExplode, sizeof(szExplode), sizeof(szExplode[]));
	
	DisplayMenu_EntitySelect(iParam1, StringToInt(szExplode[0]), StringToInt(szExplode[1]));
}

DisplayMenu_EntitySelect(iClient, iHookDataIndex, iClassNameIndex, iSelectType=0)
{
	decl eHookData[HookData];
	GetArrayArray(g_aHookData, iHookDataIndex, eHookData);
	
	if(eHookData[HOOK_DATA_ENTITY_CLASSNAMES] == INVALID_HANDLE || !GetArraySize(eHookData[HOOK_DATA_ENTITY_CLASSNAMES]))
	{
		CPrintToChat(iClient, "{green}[{lightred}SM{green}] {red}There are no entity classnames for this hook.");
		DisplayMenu_HookTypeSelect(iClient);
		return;
	}
	
	decl String:szClassName[MAX_CLASSNAME_LEN];
	GetArrayString(eHookData[HOOK_DATA_ENTITY_CLASSNAMES], iClassNameIndex, szClassName, sizeof(szClassName));
	
	decl iEnt, bool:bForceTeleport;
	if(iSelectType == 0)
		iEnt = FindNextEntity(iClient, szClassName, false, bForceTeleport);
	else if(iSelectType == 1)
		iEnt = FindPrevEntity(iClient, szClassName);
	else
		iEnt = FindNextEntity(iClient, szClassName, true, bForceTeleport);
	
	if(iEnt == -1)
	{
		CPrintToChat(iClient, "{green}[{lightred}SM{green}] {red}There are no entities for this classname.");
		DisplayMenu_ClassNameSelect(iClient, iHookDataIndex, g_iClassNameSelectStartItem[iClient]);
		return;
	}
	
	new iHammerID = GetEntProp(iEnt, Prop_Data, "m_iHammerID");
	
	if(iSelectType != 2 || bForceTeleport)
		TeleportToEntity(iClient, iEnt);
	
	new bool:bIsEntityHooked = (GetHookedEntityIndex(eHookData[HOOK_DATA_TYPE], iHammerID) != -1);
	
	new iLen;
	decl String:szTitle[512];
	iLen += FormatEx(szTitle[iLen], sizeof(szTitle)-iLen, "%s\n%s\nID: %i", eHookData[HOOK_DATA_NAME], szClassName, iHammerID);
	
	decl eHookDataProperty[HookDataProperty], Float:fVector[3], String:szString[128];
	for(new i=0; i<GetArraySize(g_aHookDataProperties); i++)
	{
		GetArrayArray(g_aHookDataProperties, i, eHookDataProperty);
		
		if(eHookData[HOOK_DATA_TYPE] != eHookDataProperty[HOOK_PROP_DATA_TYPE])
			continue;
		
		//if(!HasEntProp(iEnt, eHookDataProperty[HOOK_PROP_PROP_TYPE], eHookDataProperty[HOOK_PROP_PROPERTY]))
		//	continue;
		
		switch(eHookDataProperty[HOOK_PROP_FIELD_TYPE])
		{
			case PropField_Integer:
			{
				iLen += FormatEx(szTitle[iLen], sizeof(szTitle)-iLen, "\n%s: %i", eHookDataProperty[HOOK_PROP_PROPERTY], GetEntProp(iEnt, eHookDataProperty[HOOK_PROP_PROP_TYPE], eHookDataProperty[HOOK_PROP_PROPERTY]));
			}
			case PropField_Float:
			{
				iLen += FormatEx(szTitle[iLen], sizeof(szTitle)-iLen, "\n%s: %f", eHookDataProperty[HOOK_PROP_PROPERTY], GetEntPropFloat(iEnt, eHookDataProperty[HOOK_PROP_PROP_TYPE], eHookDataProperty[HOOK_PROP_PROPERTY]));
			}
			case PropField_Entity:
			{
				iLen += FormatEx(szTitle[iLen], sizeof(szTitle)-iLen, "\n%s: %i", eHookDataProperty[HOOK_PROP_PROPERTY], GetEntPropEnt(iEnt, eHookDataProperty[HOOK_PROP_PROP_TYPE], eHookDataProperty[HOOK_PROP_PROPERTY]));
			}
			case PropField_Vector:
			{
				GetEntPropVector(iEnt, eHookDataProperty[HOOK_PROP_PROP_TYPE], eHookDataProperty[HOOK_PROP_PROPERTY], fVector);
				iLen += FormatEx(szTitle[iLen], sizeof(szTitle)-iLen, "\n%s: [%f] [%f] [%f]", eHookDataProperty[HOOK_PROP_PROPERTY], fVector[0], fVector[1], fVector[2]);
			}
			case PropField_String, PropField_String_T:
			{
				GetEntPropString(iEnt, eHookDataProperty[HOOK_PROP_PROP_TYPE], eHookDataProperty[HOOK_PROP_PROPERTY], szString, sizeof(szString));
				iLen += FormatEx(szTitle[iLen], sizeof(szTitle)-iLen, "\n%s: %s", eHookDataProperty[HOOK_PROP_PROPERTY], szString);
			}
		}
	}
	
	new Handle:hMenu = CreateMenu(MenuHandle_EntitySelect);
	SetMenuTitle(hMenu, szTitle);
	
	decl iEntRef;
	if(iEnt < 0)
		iEntRef = iEnt;
	else
		iEntRef = EntIndexToEntRef(iEnt);
	
	decl String:szInfo[42];
	FormatEx(szInfo, sizeof(szInfo), "%i/%i/%i/%i", iHookDataIndex, iClassNameIndex, ENT_SELECT_TYPE_NEXT, iEntRef);
	AddMenuItem(hMenu, szInfo, "Next entity");
	
	FormatEx(szInfo, sizeof(szInfo), "%i/%i/%i/%i", iHookDataIndex, iClassNameIndex, ENT_SELECT_TYPE_PREV, iEntRef);
	AddMenuItem(hMenu, szInfo, "Prev entity");
	
	AddMenuItem(hMenu, szInfo, "", ITEMDRAW_SPACER);
	
	if(bIsEntityHooked)
	{
		FormatEx(szInfo, sizeof(szInfo), "%i/%i/%i/%i", iHookDataIndex, iClassNameIndex, ENT_SELECT_TYPE_UNHOOK, iEntRef);
		AddMenuItem(hMenu, szInfo, "Unhook this entity");
	}
	else
	{
		FormatEx(szInfo, sizeof(szInfo), "%i/%i/%i/%i", iHookDataIndex, iClassNameIndex, ENT_SELECT_TYPE_HOOK, iEntRef);
		AddMenuItem(hMenu, szInfo, "Hook this entity");
	}
	
	SetMenuExitBackButton(hMenu, true);
	if(!DisplayMenu(hMenu, iClient, 0))
	{
		CPrintToChat(iClient, "{green}[{lightred}SM{green}] {red}Problem displaying entity select menu.");
		return;
	}
	
	SDKHook(iClient, SDKHook_PreThinkPost, OnPreThinkPost);
}

public MenuHandle_EntitySelect(Handle:hMenu, MenuAction:action, iParam1, iParam2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}
	
	if(action == MenuAction_Cancel)
	{
		SDKUnhook(iParam1, SDKHook_PreThinkPost, OnPreThinkPost);
		
		if(iParam2 == MenuCancel_ExitBack)
			DisplayMenu_ClassNameSelect(iParam1, g_iHookDataIndex[iParam1], g_iClassNameSelectStartItem[iParam1]);
		
		return;
	}
	
	if(action != MenuAction_Select)
		return;
	
	decl String:szInfo[42];
	GetMenuItem(hMenu, iParam2, szInfo, sizeof(szInfo));
	
	decl String:szExplode[4][12];
	ExplodeString(szInfo, "/", szExplode, sizeof(szExplode), sizeof(szExplode[]));
	
	new iHookDataIndex = StringToInt(szExplode[0]);
	new iClassNameIndex = StringToInt(szExplode[1]);
	new iEntSelectType = StringToInt(szExplode[2]);
	new iEnt = EntRefToEntIndex(StringToInt(szExplode[3]));
	
	switch(iEntSelectType)
	{
		case ENT_SELECT_TYPE_NEXT:
		{
			DisplayMenu_EntitySelect(iParam1, iHookDataIndex, iClassNameIndex, 0);
		}
		case ENT_SELECT_TYPE_PREV:
		{
			DisplayMenu_EntitySelect(iParam1, iHookDataIndex, iClassNameIndex, 1);
		}
		case ENT_SELECT_TYPE_HOOK:
		{
			if(iEnt < 0)
			{
				CPrintToChat(iParam1, "{green}[{lightred}SM{green}] {red}Invalid entity.");
				return;
			}
			
			decl eHookData[HookData];
			GetArrayArray(g_aHookData, iHookDataIndex, eHookData);
			
			CreateNewEntityHook(iParam1, eHookData[HOOK_DATA_TYPE], iEnt, 0); // TODO: Set custom data.
			
			DisplayMenu_EntitySelect(iParam1, iHookDataIndex, iClassNameIndex, 2);
		}
		case ENT_SELECT_TYPE_UNHOOK:
		{
			if(iEnt < 0)
			{
				CPrintToChat(iParam1, "{green}[{lightred}SM{green}] {red}Invalid entity.");
				return;
			}
			
			decl eHookData[HookData];
			GetArrayArray(g_aHookData, iHookDataIndex, eHookData);
			
			RemoveEntityHook(eHookData[HOOK_DATA_TYPE], iEnt);
			
			DisplayMenu_EntitySelect(iParam1, iHookDataIndex, iClassNameIndex, 2);
		}
	}
}

FindNextEntity(iClient, const String:szClassName[], bool:bUseSameEntity, &bool:bForceTeleport)
{
	new iInvalidEnt = -1;
	if(!IsValidEntity(g_iStartEnt[iClient]) || (GetEntityFlags(g_iStartEnt[iClient]) & FL_KILLME))
	{
		iInvalidEnt = g_iStartEnt[iClient];
		g_iStartEnt[iClient] = INVALID_ENT_REFERENCE;
		
		bForceTeleport = true;
	}
	else
	{
		bForceTeleport = false;
		
		if(bUseSameEntity)
			return g_iStartEnt[iClient];
	}
	
	new iEnt = g_iStartEnt[iClient];
	while((iEnt = FindEntityByClassname(iEnt, szClassName)) != -1)
	{
		if(iInvalidEnt != INVALID_ENT_REFERENCE && iEnt <= iInvalidEnt)
			continue;
		
		g_iStartEnt[iClient] = iEnt;
		return iEnt;
	}
	
	iEnt = -1;
	while((iEnt = FindEntityByClassname(iEnt, szClassName)) != -1)
	{
		g_iStartEnt[iClient] = iEnt;
		return iEnt;
	}
	
	return -1;
}

FindPrevEntity(iClient, const String:szClassName[])
{
	new iNumFound;
	new Handle:hArray = CreateArray();
	new iStartEntIndex = -1;
	
	new iEnt = -1;
	while((iEnt = FindEntityByClassname(iEnt, szClassName)) != -1)
	{
		if(iEnt == g_iStartEnt[iClient])
			iStartEntIndex = iNumFound;
		
		PushArrayCell(hArray, iEnt);
		iNumFound++;
	}
	
	if(!iNumFound)
	{
		CloseHandle(hArray);
		return -1;
	}
	
	if(iStartEntIndex == 0)
	{
		iEnt = GetArrayCell(hArray, iNumFound-1);
	}
	else
	{
		if(iStartEntIndex != -1)
			iEnt = GetArrayCell(hArray, iStartEntIndex-1);
		else
			iEnt = GetArrayCell(hArray, 0);
	}
	
	CloseHandle(hArray);
	
	g_iStartEnt[iClient] = iEnt;
	return iEnt;
}

TeleportToEntity(iClient, iEnt)
{
	decl Float:fOrigin[3], Float:fMins[3], Float:fMaxs[3];
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", fOrigin);
	GetEntPropVector(iEnt, Prop_Send, "m_vecMins", fMins);
	GetEntPropVector(iEnt, Prop_Send, "m_vecMaxs", fMaxs);
	
	fOrigin[0] += ((fMins[0] + fMaxs[0]) * 0.5);
	fOrigin[1] += ((fMins[1] + fMaxs[1]) * 0.5);
	fOrigin[2] += ((fMins[2] + fMaxs[2]) * 0.5);
	
	SetEntProp(iClient, Prop_Send, "m_nSolidType", SOLID_NONE);
	SetEntityMoveType(iClient, MOVETYPE_NOCLIP);
	TeleportEntity(iClient, fOrigin, NULL_VECTOR, Float:{0.0, 0.0, 0.0});
}

public OnPreThinkPost(iClient)
{
	static Float:fCurTime;
	fCurTime = GetEngineTime();
	
	if(fCurTime < g_fNextDisplayBoxTime[iClient])
		return;
	
	g_fNextDisplayBoxTime[iClient] = fCurTime + DISPLAY_BOX_DELAY;
	
	ShowBox(iClient, BOX_BEAM_WIDTH, BOX_BEAM_COLOR);
}

ShowBox(iClient, Float:fBeamWidth, const iColor[4])
{
	if(!IsValidEntity(g_iStartEnt[iClient]))
		return;
	
	static iEnt;
	iEnt = g_iStartEnt[iClient];
	if(iEnt == INVALID_ENT_REFERENCE)
		return;
	
	static Float:fOrigin[3], Float:fMins[3], Float:fMaxs[3], i;
	GetEntPropVector(iEnt, Prop_Data, "m_vecOrigin", fOrigin);
	GetEntPropVector(iEnt, Prop_Send, "m_vecMins", fMins);
	GetEntPropVector(iEnt, Prop_Send, "m_vecMaxs", fMaxs);
	
	// Make sure we can see the box if it's too small.
	if(FloatAbs(fMins[0]) + FloatAbs(fMaxs[0]) < 2.0)
	{
		fMins[0] -= 7.0;
		fMaxs[0] += 7.0;
	}
	
	if(FloatAbs(fMins[1]) + FloatAbs(fMaxs[1]) < 2.0)
	{
		fMins[1] -= 7.0;
		fMaxs[1] += 7.0;
	}
	
	if(FloatAbs(fMins[2]) + FloatAbs(fMaxs[2]) < 2.0)
	{
		fMins[2] -= 7.0;
		fMaxs[2] += 7.0;
	}
	
	new Float:fVertices[8][3];
	
	// Add the entities origin to all the vertices.
	for(i=0; i<8; i++)
	{
		fVertices[i][0] += fOrigin[0];
		fVertices[i][1] += fOrigin[1];
		fVertices[i][2] += fOrigin[2];
	}
	
	// Set the vertices origins.
	fVertices[0][2] += fMins[2];
	fVertices[1][2] += fMins[2];
	fVertices[2][2] += fMins[2];
	fVertices[3][2] += fMins[2];
	
	fVertices[4][2] += fMaxs[2];
	fVertices[5][2] += fMaxs[2];
	fVertices[6][2] += fMaxs[2];
	fVertices[7][2] += fMaxs[2];
	
	fVertices[0][0] += fMins[0];
	fVertices[0][1] += fMins[1];
	fVertices[1][0] += fMins[0];
	fVertices[1][1] += fMaxs[1];
	fVertices[2][0] += fMaxs[0];
	fVertices[2][1] += fMaxs[1];
	fVertices[3][0] += fMaxs[0];
	fVertices[3][1] += fMins[1];
	
	fVertices[4][0] += fMins[0];
	fVertices[4][1] += fMins[1];
	fVertices[5][0] += fMins[0];
	fVertices[5][1] += fMaxs[1];
	fVertices[6][0] += fMaxs[0];
	fVertices[6][1] += fMaxs[1];
	fVertices[7][0] += fMaxs[0];
	fVertices[7][1] += fMins[1];
	
	// Draw the horizontal beams.
	for(i=0; i<4; i++)
	{
		if(i != 3)
			TE_SetupBeamPoints(fVertices[i], fVertices[i+1], g_iBeamIndex, 0, 1, 1, DISPLAY_BOX_DELAY+0.1, fBeamWidth, fBeamWidth, 0, 0.0, iColor, 10);
		else
			TE_SetupBeamPoints(fVertices[i], fVertices[0], g_iBeamIndex, 0, 1, 1, DISPLAY_BOX_DELAY+0.1, fBeamWidth, fBeamWidth, 0, 0.0, iColor, 10);
		
		TE_SendToClient(iClient);
	}
	
	for(i=4; i<8; i++)
	{
		if(i != 7)
			TE_SetupBeamPoints(fVertices[i], fVertices[i+1], g_iBeamIndex, 0, 1, 1, DISPLAY_BOX_DELAY+0.1, fBeamWidth, fBeamWidth, 0, 0.0, iColor, 10);
		else
			TE_SetupBeamPoints(fVertices[i], fVertices[4], g_iBeamIndex, 0, 1, 1, DISPLAY_BOX_DELAY+0.1, fBeamWidth, fBeamWidth, 0, 0.0, iColor, 10);
		
		TE_SendToClient(iClient);
	}
	
	// Draw the vertical beams.
	for(i=0; i<4; i++)
	{
		TE_SetupBeamPoints(fVertices[i], fVertices[i+4], g_iBeamIndex, 0, 1, 1, DISPLAY_BOX_DELAY+0.1, fBeamWidth, fBeamWidth, 0, 0.0, iColor, 10);
		TE_SendToClient(iClient);
	}
}