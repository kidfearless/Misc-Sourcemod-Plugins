#include <sourcemod>
#include <sdktools_functions>
#include <shavit>

#pragma newdecls required
#pragma semicolon 1

bool gB_MoonShoes[MAXPLAYERS + 1];

#define BOOST (1.49 * 301.993377)

public Plugin myinfo = 
{
	name = "MoonShoes",
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
	if(gB_MoonShoes[client])
	{
		RequestFrame(Frame_JumpPost, client);
	}
}

public void Frame_JumpPost(int client)
{
	float fAbsVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);
	fAbsVelocity[2] += 147.97675473;

	SetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);
	
}

public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle)
{
	char sSpecial[128];
	Shavit_GetStyleStrings(newstyle, sSpecialString, sSpecial, 128);

	if(StrContains(sSpecial, "moon", false) == -1)
	{
		gB_MoonShoes[client] = false;
	}
	else
	{
		gB_MoonShoes[client] = true;
	}
}

