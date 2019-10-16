#include <sourcemod>
#include <shavit>

public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style, stylesettings_t stylesettings, int mouse[2])
{
	static int oldButtons[MAXPLAYERS+1];

	char buffer[128];
	Shavit_GetStyleStrings(style, sSpecialString, buffer, 128);
	if(StrContains(buffer, "swble") != -1)
	{
		return Plugin_Continue;
	}

	if(oldButtons[client] & IN_ATTACK && buttons & IN_ATTACK)
	{
		buttons &= ~IN_ATTACK;
	}
	
	oldButtons[client] = buttons;
	return Plugin_Continue;
}