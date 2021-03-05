#include <sdktools>
#include <sdkhooks>
#include <shavit>
#pragma semicolon 1
#pragma newdecls required

int replayBot = 1;
ConVar sv_clamp_unsafe_velocities = null;

public void OnPluginStart()
{
	sv_clamp_unsafe_velocities = FindConVar("sv_clamp_unsafe_velocities");
}

public void OnEntityCreated(int entity, const char[] classname) {
	if( (classname[0] == 't' ||  classname[0] == 'l') ? (StrEqual(classname, "trigger_teleport", false) || StrEqual(classname, "trigger_multiple", false) || StrEqual(classname, "trigger_once", false) || StrEqual(classname, "trigger_hurt", false) || StrEqual(classname, "logic_relay", false)) : false)
	{
		SDKHook(entity, SDKHook_Use, OnEntityUse);
		SDKHook(entity, SDKHook_StartTouch, OnEntityUse);
		SDKHook(entity, SDKHook_Touch, OnEntityUse);
		SDKHook(entity, SDKHook_EndTouch, OnEntityUse);
	}
}

public void Shavit_OnReplayStart(int client)
{
	replayBot = client;
	SDKHook(client, SDKHook_PreThink, OnPreThinkPost);
	SDKHook(client, SDKHook_PostThink, OnPostThinkPost);
}

public void OnPreThinkPost(int client)
{
	if(client == replayBot)
	{
		sv_clamp_unsafe_velocities.BoolValue = true;
	}
	else
	{
		sv_clamp_unsafe_velocities.BoolValue = false;
	}
}

public void OnPostThinkPost(int client)
{
	sv_clamp_unsafe_velocities.BoolValue = false;
}

public Action OnEntityUse(int entity, int client)
{
	if(client == replayBot)
	{
		return Plugin_Handled;
	}
	else
	{
		return Plugin_Continue;
	}
} 