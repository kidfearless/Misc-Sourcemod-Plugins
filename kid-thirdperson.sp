#include <sourcemod>
#include <sdktools_functions>
#include <shavit>

#pragma newdecls required
#pragma semicolon 1

bool gB_ThirdPerson[MAXPLAYERS + 1];
bool gB_Ignore[MAXPLAYERS + 1];
public Plugin myinfo = 
{
	name = "Thirdperson",
	author = "KiD Fearless",
	description = "https://steamcommunity.com/id/kidfearless/",
	version = "",
	url = "www.joinsg.net"
}

public void OnPluginStart()
{
	HookEvent("player_jump", Event_PlayerJump);
}

public void Event_PlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!gB_Ignore[client])
	{
		if(gB_ThirdPerson[client] == true)
		{
			ClientCommand(client, "thirdperson");
		}
		else
		{
			ClientCommand(client, "firstperson");
		}
	}
}

public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle)
{
	char sSpecial[128];
	Shavit_GetStyleStrings(newstyle, sSpecialString, sSpecial, 128);

	
	if(StrContains(sSpecial, "thirdperson", false) == -1)
	{
		gB_ThirdPerson[client] = false;
		ClientCommand(client, "firstperson");
	}
	else
	{
		gB_ThirdPerson[client] = true;
		ClientCommand(client, "thirdperson");
	}
	if(StrContains(sSpecial, "tas", false) != -1)
	{
		gB_Ignore[client] = true;
	}
	else
	{
		gB_Ignore[client] = false;
	}
}


