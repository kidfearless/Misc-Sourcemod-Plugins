#include <sourcemod>
#include <sdkhooks>
#include <shavit>

#define DEFAULT_WISH 30.0

float gF_TickRate[MAXPLAYERS];
ConVar sv_air_max_wishspeed = null;
bool gB_Late = false;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	gB_Late = late;
	return APLRes_Success;
}


public void OnPluginStart()
{
	sv_air_max_wishspeed = FindConVar("sv_air_max_wishspeed");
	sv_air_max_wishspeed.Flags &= ~(FCVAR_REPLICATED);
	if(gB_Late)
	{
		for (int client = 1; client <= MaxClients; ++client) 
		{ 
		    if (IsClientInGame(client)) 
		    {
		        OnClientPutInServer(client);
		    }
		}
	}
}

public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle)
{
	char sSpecial[128];
	Shavit_GetStyleStrings(newstyle, sSpecialString, sSpecial, 128);
	char wish[8];
	if(StrContains(sSpecial, "256") != -1)
	{
		gF_TickRate[client] = 33.0;
	}
	else if(StrContains(sSpecial, "102") != -1)
	{
		gF_TickRate[client] = 26.4;
	}
	else
	{
		gF_TickRate[client] = 30.0;//reduce their strafing by the multiple of their timescale.
	}

	FormatEx(wish, sizeof(wish), "%f", gF_TickRate[client]);
	sv_air_max_wishspeed.ReplicateToClient(client, wish);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_PreThink, OnPreThinkPost);
	gF_TickRate[client] = 30.0;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_PreThink, OnPreThinkPost);
	gF_TickRate[client] = 30.0;
}

public void OnPreThinkPost(int client)
{
	if(IsValidClient(client) && !IsFakeClient(client))
	{
		sv_air_max_wishspeed.FloatValue = gF_TickRate[client];//reduce their strafing by the multiple of their timescale.
	}
}