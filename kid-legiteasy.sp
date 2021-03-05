#include <sourcemod>
#include <sdkhooks>
#include <shavit>

#define DEFAULT_FRICTION 4

ConVar sv_friction = null;

bool g_bTest[MAXPLAYERS + 1];
bool g_bApplyFriction[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "Style: Legit CSS",
	author = "KiD Fearless",
	description = "Tries to replicate css bhop style for csgo",
	version = "1.0",
	url = "https://steamcommunity.com/id/kidfearless/"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_css", Command_Callback);
	sv_friction = FindConVar("sv_friction");
	sv_friction.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);

	for(int i = 1; i <= MaxClients; ++i)
	{
		if(IsValidClient(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnPluginEnd()
{
	delete sv_friction;
}


public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	g_bTest[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	g_bTest[client] = false;
}

public void OnPreThinkPost(int client)
{
	if(g_bTest[client])
	{
		if(g_bApplyFriction[client])
		{
			sv_friction.IntValue = 20;
		}
		else
		{
			sv_friction.IntValue = DEFAULT_FRICTION;
		}
	}
	else
	{
		sv_friction.IntValue = DEFAULT_FRICTION;
	}
}

public Action Command_Callback(int client, int args)
{
	g_bTest[client] = !g_bTest[client];

	return Plugin_Handled;
}



public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	static int ticksOnGround[MAXPLAYERS + 1];

	if(GetEntityFlags(client) & FL_ONGROUND == FL_ONGROUND)
	{
		++ticksOnGround[client];
	}
	else
	{
		ticksOnGround[client] = 0;
	}

	g_bApplyFriction[client] = (ticksOnGround[client] < 4);
	
	return Plugin_Continue;
}
