#include <sourcemod>

Handle sv_cheats = null;

public void OnPluginStart()
{
	sv_cheats = FindConVar("sv_cheats");
	SetCommandFlags("endround", FCVAR_NONE);
	SetCommandFlags("ent_remove", FCVAR_NONE);
	SetCommandFlags("air_density", FCVAR_NONE);
	
	HookEvent("player_spawn", Event_Player_Spawn, EventHookMode_Post);
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			SendConVarValue(i, sv_cheats, "2");
		}
	}
}

public void OnClientPutInServer(int client)
{
	if(!IsFakeClient(client))
	{
		SendConVarValue(client, sv_cheats, "2");
	}
}

public void Event_Player_Spawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(!IsFakeClient(client))
	{
		SendConVarValue(client, sv_cheats, "2");
	}
}

//public void OnClientPostAdminCheck(int client)
//{
//	if(IsValidClient(client))
//	{
//		SendConVarValue(client, sv_cheats, "1");
//	}
//}
//
//stock bool IsValidClient(int client, bool bAlive = false)
//{
//	return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client) && !IsFakeClient(client) && (!bAlive || IsPlayerAlive(client)));
//}