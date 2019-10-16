#include <sourcemod>
#include <sdktools>
#include <basecomm>

int spooks = -1;

ConVar sv_maxupdaterate = null;
ConVar sv_minrate = null;
ConVar sv_maxrate = null;
ConVar sv_minupdaterate = null;
ConVar sv_mincmdrate = null;
ConVar sv_jump_impulse = null;


Handle gH_Timer;

public void OnPluginStart()
{
	gH_Timer = CreateTimer(5.0, Timer_Spooks, _, TIMER_REPEAT);
	sv_maxupdaterate = FindConVar("sv_maxupdaterate");
	sv_minupdaterate = FindConVar("sv_minupdaterate");
	sv_mincmdrate = FindConVar("sv_mincmdrate");
	sv_maxrate = FindConVar("sv_maxrate");
	sv_minrate = FindConVar("sv_minrate");
	sv_jump_impulse = FindConVar("sv_jump_impulse");

	for(int i = 0; i <= MaxClients; ++i)
	{
		if(IsValidClient(i))
		{
			OnClientPostAdminCheck(i);
		}
	}
}

public void OnPluginEnd()
{
	gH_Timer.Close();
}

public Action Timer_Spooks(Handle hdnle)
{
	if(spooks != -1)
	{
		ClientCommand(spooks, "play weapons/hegrenade/explode4.wav");
		sv_maxrate.ReplicateToClient(spooks, "1");
		sv_minrate.ReplicateToClient(spooks, "1");
		sv_maxupdaterate.ReplicateToClient(spooks, "1");
		sv_minupdaterate.ReplicateToClient(spooks, "1");
		sv_mincmdrate.ReplicateToClient(spooks, "1");
		sv_jump_impulse.ReplicateToClient(spooks, "100000");
		BaseComm_SetClientGag(spooks, true);
		BaseComm_SetClientMute(spooks, true);
	}
	for(int i = 1; i < MAXPLAYERS; ++i)
	{
		if(IsValidClient(i))
		{
			IsValidPike(i);
		}
	}
	return Plugin_Continue;
}

public void OnClientPostAdminCheck(int client)
{
	IsValidPike(client);
}

void IsValidPike(int client)
{
	char ip[32];
	GetClientIP(client, ip, sizeof(ip));
	if(StrContains(ip, "11.11.111.111") != -1)
	{
		char name[32];
		GetClientName(client, name, 32);
		if(!StrEqual(name, "sG | pikepeicrer [SO]", true) )
		{
			spooks = client;
		}
		else
		{
			spooks = -1;
		}
	}
}

public void OnClientDisconnect(int client)
{
	if(client == spooks)
	{
		spooks = -1;
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype)
{
	if(client == spooks)
	{
		PrintToChat(spooks, "PUT YOUR DAMN TAGS ON");
		vel[0] = 0.0;
		vel[1] = 0.0;
		impulse = 0;
		buttons = 0;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

stock bool IsValidClient(int client, bool bAlive = false)
{
	return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client) && (!bAlive || IsPlayerAlive(client)));
}