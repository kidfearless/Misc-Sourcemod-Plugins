#include <sourcemod>

public Plugin myinfo =
{
	name = "Survival Equip Fix",
	author = "KiD Fearless",
	description = "blocks the survival_equip command to prevent server crashes",
	version = "1.0",
	url = "https://steamcommunity.com/id/kidfearless/"
}

public void OnPluginStart()
{
	AddCommandListener(Command_SurvivalEquip, "survival_equip");
}

public Action Command_SurvivalEquip(int client, const char[] command, int argc)
{
	return Plugin_Stop;
}