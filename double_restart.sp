#include <shavit>
#include <sourcemod>
#include <clientprefs_stocks>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Double Restart Timer",
	author = "KiD Fearless",
	description = "Adds double click to restart client pref to the timer.",
	version = "1.1",
	url = "https://steamcommunity.com/id/kidfearless/"
}

bool gB_Clicked[MAXPLAYERS + 1];
float gF_LastTime[MAXPLAYERS + 1];

ConVar gC_RestartTime = null;

Cookie Cookie_Restart = null;

public void OnPluginStart()
{
	RegConsoleCmd("sm_double_restart", Command_DoubleRestart, "Toggles double restart cookie");
	AddCommandListener(RestartListener_Callback, "sm_r");
	AddCommandListener(RestartListener_Callback, "sm_restart");
	AddCommandListener(RestartListener_Callback, "sm_s");
	AddCommandListener(RestartListener_Callback, "sm_start");
	AddCommandListener(RestartListener_Callback, "sm_b");
	AddCommandListener(RestartListener_Callback, "sm_bonus");
	Cookie_Restart = new Cookie("double_restart", "When enabled players have to double tap restart after x seconds into a run", CookieAccess_Public);
	gC_RestartTime = CreateConVar("sm_double_restart_time", "2.0", "Time in seconds to double restart", _, true, 0.0);

	SetCookiePrefabMenu(Cookie_Restart.Ref, CookieMenu_YesNo_Int, "Double Restart");
	AutoExecConfig();
}

public void OnClientDisconnect(int client)
{
	gB_Clicked[client] = false;
	gF_LastTime[client] = 0.0;
}

public Action Command_DoubleRestart(int client, int args)
{
	Cookie_Restart.SetBool(client, !Cookie_Restart.GetBool(client));
	ReplyToCommand(client, "Double Tap to restart %s", (Cookie_Restart.GetBool(client)?"Enabled.":"Disabled."));
	return Plugin_Handled;
}

public Action RestartListener_Callback(int client, const char[] command, int argc)
{
	if (Cookie_Restart.GetBool(client) && !Shavit_InsideZone(client, Zone_Start, -1)) 
	{
		if (GetGameTime() - gF_LastTime[client] > gC_RestartTime.FloatValue)
		{
			gB_Clicked[client] = false;
		}
		if (!gB_Clicked[client])
		{
			gF_LastTime[client] = GetGameTime();
			gB_Clicked[client] = true;
			Shavit_PrintToChat(client, "Are you sure you want to restart?");
			return Plugin_Stop;
		}

		gB_Clicked[client] = false;
	}
	return Plugin_Continue;
}