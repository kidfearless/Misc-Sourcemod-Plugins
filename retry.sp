#include <sourcemod>
#include <sdktools>



public Plugin myinfo = 
{
	name = "InActivate",
	author = "KiD Fearless",
	description = "",
	version = "1.0",
	url = "http://steamcommunity.com/id/kidfearless"
}

public OnPluginStart()
{
	RegAdminCmd("sm_deactivate", Command_InAcivate, ADMFLAG_RCON, "inactives target");
	RegAdminCmd("sm_inactivate", Command_InAcivate, ADMFLAG_RCON, "inactives target");
	RegAdminCmd("sm_restartserver", Command_Restart_Server, ADMFLAG_RCON, "restarts the server");
	RegConsoleCmd("sm_retry", Command_Reconnect, "reconnects you to the server");
	RegConsoleCmd("sm_reconnect", Command_Reconnect, "reconnects you to the server");
}

public Action Command_InAcivate(int client, int args)
{
	if(IsClientFearless(client) == false)
	{
		PrintToConsole(client, "bad staff. no abuse.");
		InactivateClient(client);
		return Plugin_Handled;
	}

	if(GetCmdArgs() < 1) //only used sm_deactivate so it'll apply to whoever issued it/
	{
		ReplyToCommand(client, "[SM] You have inactivated yourself");
		InactivateClient(client);
		return Plugin_Handled;
	}

	char arg[128]; //character array to hold the commands arguments/
	GetCmdArg(1, arg, sizeof(arg)); //gets the first argument of the command and stores it to the character array/
	
	int target = FindTarget(client, arg, true, false); //trys to find a player in the game using the array we made earier. once found assigns it to int target.
	
	ReplyToCommand(client, "[SM] %L has been inactivated", target);
	InactivateClient(target);

	return Plugin_Handled;
}

public Action Command_Reconnect(int client, int args)
{
	ReplyToCommand(client, "reconnecting you to the server");
	ReconnectClient(client);
	
	return Plugin_Handled;
}

public Action Command_Restart_Server(int client, int args)
{
	PrintToChatAll("[SM] Restarting Server");
	
	for(int i = 1; i < MAXPLAYERS; i++)
	{
		if(!IsFakeClient(i) && !IsClientSourceTV(i) && IsClientInGame(i))
		{
			ReconnectClient(i);
		}
	}
	
	char restart[8];
	Format(restart, sizeof(restart), "_restart");
	ServerCommand(restart);
	
	return Plugin_Handled;
}

stock bool IsClientFearless(int client)
{
	char authid[20];
	GetClientAuthId(client, AuthId_SteamID64, authid, sizeof(authid));
	if(StrEqual(authid, "76561198020000383", false) )
	{
		return true;
	}
	else
	{
		return false;
	}

}