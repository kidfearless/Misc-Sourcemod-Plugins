// base grab code taken from http://forums.alliedmods.net/showthread.php?t=157075

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <shavit>
#pragma newdecls required

#define FLING_FORCE 1000.0
#define GRAB_DISTANCE 150.0


public Plugin myinfo =
{
	name = "Grab Style",
	author = "KiD Fearless",
	description = "Grab yourself to the finish.",
	version = "1.0",
};

int gB_grabbed[MAXPLAYERS + 1];              // track client's grabbed object
float gF_Distance[MAXPLAYERS + 1];        // track distance of grabbed object

public void OnPluginStart()
{
	RegAdminCmd("sm_grab", Command_Grab_Toggle, ADMFLAG_SLAY, "Grab an Object");

	HookEvent("player_death", OnPlayerSpawn);
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_team", OnPlayerSpawn);

	for (int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			SDKHook(client, SDKHook_PreThink, OnPreThink);
		}
	}
}

public void OnMapStart()
{
	for (int client=1; client<=MaxClients; client++)
	{
		gB_grabbed[client] = INVALID_ENT_REFERENCE;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_PreThink, OnPreThink);
}

public void OnClientPutInServer(int client)
{
	gB_grabbed[client] = INVALID_ENT_REFERENCE;
}

public Action Command_Grab_Toggle(int client, int args)
{
	if(IsValidClient(client))
	{
		int grabbed = EntRefToEntIndex(gB_grabbed[client]);
		if(grabbed != INVALID_ENT_REFERENCE)
		{
			GrabObject(client);
		}
	}

	return Plugin_Handled;
}
void GrabObject(int client)
{
	int grabbed = client;		// -1 for no collision, 0 for world

	if (grabbed > 0)
	{
		SetEntityMoveType(grabbed, MOVETYPE_WALK);

		gF_Distance[client] = GRAB_DISTANCE;				// Use prefab distance

		TeleportEntity(grabbed, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);

		gB_grabbed[client] = EntIndexToEntRef(grabbed);
	}
}

public void OnPreThink(int client)
{
	int grabbed = EntRefToEntIndex(gB_grabbed[client]);
	if (grabbed != INVALID_ENT_REFERENCE)
	{
		float vecView[3];
		float vecFwd[3];
		float vecPos[3];
		float vecVel[3];

		GetClientEyeAngles(client, vecView);
		GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
		GetClientEyePosition(client, vecPos);

		vecPos[0]+=vecFwd[0]*gF_Distance[client];
		vecPos[1]+=vecFwd[1]*gF_Distance[client];
		vecPos[2]+=vecFwd[2]*gF_Distance[client];

		GetEntPropVector(grabbed, Prop_Send, "m_vecOrigin", vecFwd);

		SubtractVectors(vecPos, vecFwd, vecVel);
		ScaleVector(vecVel, 10.0);

		TeleportEntity(grabbed, NULL_VECTOR, NULL_VECTOR, vecVel);
	}
}

public void OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(client)
	{
		int grabbed = EntRefToEntIndex(gB_grabbed[client]);
		if(grabbed != INVALID_ENT_REFERENCE && grabbed > MaxClients)
		{
			char classname[13];
			GetEntityClassname(grabbed, classname, 13);
			if(StrEqual(classname, "prop_physics"))
			{
				SetEntPropEnt(grabbed, Prop_Data, "m_hPhysicsAttacker", 0);
			}
		}
		gB_grabbed[client] = INVALID_ENT_REFERENCE;				// Clear their grabs

		for(int i=1; i<=MaxClients; i++)
		{
			if(EntRefToEntIndex(gB_grabbed[i]) == client)
			{
				gB_grabbed[i] = INVALID_ENT_REFERENCE;				// Clear grabs on them
			}
		}
	}

	return;
}