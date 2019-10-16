#include <sourcemod>
#include <shavit>

public Plugin myinfo =
{
	name = "Classname Fix",
	author = "KiD Fearless",
	description = "Sets classname on restart",
	version = "1.0",
	url = "https://steamcommunity.com/id/kidfearless/"
}

public void Shavit_OnRestart(int client, int track)
{
	SetEntPropString(client, Prop_Data, "m_iClassname", "player");
}