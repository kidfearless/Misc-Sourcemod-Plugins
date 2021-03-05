#include <sourcemod>
#include <sdktools>
#include <shavit>
#include <sdkhooks>
#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
	author = "KiD Fearless",
	url = "https://www.steamcommunity.com/id/kidfearless",
	name = "High FOV Style",
	description = "",
	version = "1.0"
};

public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle, int track, bool manual)
{
	char[] sSpecial = new char[128];
	Shavit_GetStyleStrings(newstyle, sSpecialString, sSpecial, 128);

	if(StrContains(sSpecial, "ws", false) != -1)
	{
		SetEntProp(client, Prop_Send, "m_iFOV", 45);
		SetEntProp(client, Prop_Send, "m_iDefaultFOV", 45);
		SetEntProp(client, Prop_Send, "m_iFOVStart", 45);
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_iFOV", 90);
		SetEntProp(client, Prop_Send, "m_iDefaultFOV", 90);
		SetEntProp(client, Prop_Send, "m_iFOVStart", 90);
	}

}