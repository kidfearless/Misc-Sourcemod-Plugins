#include <sourcemod>

public Plugin myinfo =
{
	name = "Plugin Name",
	author = "KiD Fearless",
	description = "Plugin Description",
	version = "1.0",
	url = "https://steamcommunity.com/id/kidfearless/"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_command", Command_Callback);
}

public Action Command_Callback(int client, int args)
{
	return Plugin_Handled;
}