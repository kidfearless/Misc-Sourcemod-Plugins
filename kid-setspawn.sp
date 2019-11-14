#include <sourcemod>
#include <sdktools>

#undef REQUIRE_PLUGIN
#include <shavit>

#pragma newdecls required
#pragma semicolon 1

bool gB_UseSpawnPosition[MAXPLAYERS + 1];
float gF_PlayerOrigin[MAXPLAYERS + 1][3];
float gF_PlayerAngles[MAXPLAYERS + 1][3];
int gI_SavedTrack[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "[shavit] SetSpawn",
	author = "Nickelony",
	description = "Allows players to set their own spawn position.",
	version = "1.0",
	url = "steamcommunity.com/id/nickelony"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_setspawn", Command_SetSpawn);
	RegConsoleCmd("sm_ssp", Command_SetSpawn);
	RegConsoleCmd("sm_setstart", Command_SetSpawn);
	RegConsoleCmd("sm_removestart", Command_ClearSpawn);
	RegConsoleCmd("sm_removespawn", Command_ClearSpawn);
	RegConsoleCmd("sm_clearspawn", Command_ClearSpawn);
	RegConsoleCmd("sm_clearstart", Command_ClearSpawn);
}

public void OnClientPutInServer(int client)
{
	gB_UseSpawnPosition[client] = false;
}

public Action Command_SetSpawn(int client, int args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "This command may be only performed in-game.");
		return Plugin_Handled;
	}
	
	if(!IsValidClient(client))
	{
		return Plugin_Handled;
	}
	
	SetSpawn(client);
	return Plugin_Handled;
}

public Action Command_ClearSpawn(int client, int args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "This command may be only performed in-game.");
		return Plugin_Handled;
	}
	
	if(!IsValidClient(client))
	{
		return Plugin_Handled;
	}
	
	ClearSpawn(client);
	return Plugin_Handled;
}

public void Shavit_OnRestart(int client, int track)
{
	if(gB_UseSpawnPosition[client])
	{	
		if(track == gI_SavedTrack[client])
		{
			Shavit_StopTimer(client);
			RequestFrame(OnPostRestart, GetClientSerial(client));
			// since the callbacks have been broken and calling out of place we're going to teleport them for 2 ticks.
			// one for when it works, one for when it doesn't. both so that the angles don't flicker.
			TeleportEntity(client, gF_PlayerOrigin[client], gF_PlayerAngles[client], NULL_VECTOR);
		}
	}
}

public void OnPostRestart(int serial)
{
	int client = GetClientFromSerial(serial);
	if(client > 0)
	{
		TeleportEntity(client, gF_PlayerOrigin[client], gF_PlayerAngles[client], NULL_VECTOR);
	}
}

public void ClearSpawn(int client)
{
	gB_UseSpawnPosition[client] = false;
	Shavit_PrintToChat(client, "Spawn deleted.");
}

public void SetSpawn(int client)
{
	if(Shavit_InsideZone(client, Zone_Start, -1))
	{
		if((GetClientButtons(client) & IN_DUCK) == IN_DUCK)
		{
			Shavit_PrintToChat(client, "You cannot duck while using this command");
			return;
		}
		
		float origin[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", origin);
		
		float angles[3];
		GetClientEyeAngles(client, angles);
		
		gI_SavedTrack[client] = Shavit_GetClientTrack(client);

		gF_PlayerOrigin[client] = origin;
		gF_PlayerAngles[client] = angles;
		
		gB_UseSpawnPosition[client] = true;
		Shavit_PrintToChat(client, "Spawn saved.");
	}
	else
	{
		Shavit_PrintToChat(client, "You have to be in the start zone to use this command!");
	}
}