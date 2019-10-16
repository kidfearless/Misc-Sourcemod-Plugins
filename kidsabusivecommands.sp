#include <sourcemod>
#include <sdktools>
#include <sendproxy>

ConVar sv_maxupdaterate = null;
ConVar sv_minrate = null;
ConVar sv_maxrate = null;
ConVar sv_minupdaterate = null;
ConVar sv_mincmdrate = null;

char gS_LoopTarget[20];
bool gB_DisablePredict[MAXPLAYERS+1];
bool gB_LoopedTarget[MAXPLAYERS+1];

public Plugin myinfo = 
{
	name = "KiDs Abusive Admin Commands",
	author = "KiD Fearless",
	description = "Collection of abusive admin commands that i've made",
	version = "1.0",
	url = "http://steamcommunity.com/id/kidfearless"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_lag", Command_Lag, ADMFLAG_RCON, "");
	RegAdminCmd("sm_loop", Command_Loop, ADMFLAG_RCON, "");
	RegAdminCmd("sm_deoptimze", Command_ClientSidePredict, ADMFLAG_ROOT, "");
	
	for(int client = 1; client < MAXPLAYERS; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientPostAdminCheck(client);
		}
	}
	
	sv_maxupdaterate = FindConVar("sv_maxupdaterate");
	sv_minupdaterate = FindConVar("sv_minupdaterate");
	sv_mincmdrate = FindConVar("sv_mincmdrate");
	sv_maxrate = FindConVar("sv_maxrate");
	sv_minrate = FindConVar("sv_minrate");
	
}

public void OnClientPostAdminCheck(int client)
{
	gB_LoopedTarget[client] = false;
	gB_DisablePredict[client] = false;
	
	char authid[20];
	GetClientAuthId(client, AuthId_SteamID64, authid, sizeof(authid));
	
	if (StrEqual(authid, gS_LoopTarget, false))
	{
		gB_LoopedTarget[client] =  true;
	}
	
	PrintToServer("authid: %s, gS_LoopTarget: %s, stringequal?: %b", authid, gS_LoopTarget, (StrEqual(authid, gS_LoopTarget, false)));
}

public Action Command_ClientSidePredict(int client, int args)
{
	char arg[128];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target = FindTarget(client, arg, true, true);
	
	//gB_DisablePredict[target] = !gB_DisablePredict[target];
	Handle 
}
public Action Command_Loop(int client, int args)
{
	char arg[128];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target = FindTarget(client, arg, true, true);
	
	GetClientAuthId(target, AuthId_SteamID64, gS_LoopTarget, sizeof(gS_LoopTarget));
	
	InactivateClient(target);
	
	ReplyToCommand(client, "[SM] %s has been trapped in purgatory", gS_LoopTarget);
	
	return Plugin_Handled;
}

public Action Command_Lag(int client, int args)
{
	char arg[128];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target = FindTarget(client, arg, true, true);
	
	sv_maxrate.ReplicateToClient(target, "1");
	sv_minrate.ReplicateToClient(target, "1");
	sv_maxupdaterate.ReplicateToClient(target, "1");
	sv_minupdaterate.ReplicateToClient(target, "1");
	sv_mincmdrate.ReplicateToClient(target, "1");
	
	ReplyToCommand(client, "[SM] %L is now lagging.", target);
	
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(gB_LoopedTarget[client])
	{
		InactivateClient(client);
	}
	return Plugin_Continue;
}


public Action ProxyCallback(int entity, const[] char[] propname, int &iValue, element)
{
    //Set iValue to whatever you want to send to clients
    iValue = 3;
    return Plugin_Changed;
}  