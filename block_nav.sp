#include <sourcemod>

public Plugin myinfo =
{
	name = "Block Nav Mesh",
	author = "KiD Fearless",
	description = "Blocks Nav Meshes From Being Generated",
	version = "1.0",
	url = "https://steamcommunity.com/id/kidfearless/"
}

public void OnPluginStart()
{
	HookEvent("nav_generate", OnNavGeneratePre, EventHookMode_Pre);
}

public Action OnNavGeneratePre(Event event, const char[] name, bool dontBroadcast)
{
	return Plugin_Handled;
}