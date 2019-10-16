#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.2"

#pragma newdecls required

public Plugin myinfo = 
{
	name = "bspconvarwhitelist fix",
	author = "kid fearless",
	description = "deletes the bspconvarwhitelist.txt file when the server updates",
	version = PLUGIN_VERSION
}

public void OnPluginStart()
{
	if(FileExists("bspconvar_whitelist.txt"))
	{
		DeleteFile("bspconvar_whitelist.txt");
	}
}