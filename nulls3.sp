#include <sourcemod>
#include <shavit>
#include <cstrike>
#pragma semicolon 1
#pragma newdecls required

bool gB_Null[MAXPLAYERS+1];
bool gB_LJ[MAXPLAYERS+1];
bool gB_Blocked[MAXPLAYERS+1];
int gI_PrevButtons[MAXPLAYERS+1];
int gI_UseKey[MAXPLAYERS+1];

bool gB_Late = false;

enum
{
	In_None = 0,
	In_A = 1,
	In_D = 2
}

public Plugin myinfo =
{
	name = "nulls",
	author = "KiD Fearless",
	description = "Server Sided Movement Config",
	version = "1.0",
	url = ""
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	gB_Late = late;

	return APLRes_Success;
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_null", Command_Null, "Toggles Nulls.");
	RegConsoleCmd("sm_nulls", Command_Null, "Toggles Nulls.");
	RegConsoleCmd("-lj", Command_Lj, "LongJump Bind.");
	RegConsoleCmd("+lj", Command_Lj, "LongJump Bind.");

	if(gB_Late)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				OnClientConnected(i);
			}
		}
	}
}

public void OnClientConnected(int client)
{
	gB_Null[client] = false;
	gB_LJ[client] = false;
	gB_Blocked[client] = false;
	gI_UseKey[client] = In_None;
}

public Action Command_Null(int client, int args)
{
	gB_Null[client] = !gB_Null[client];
	ReplyToCommand(client, "Nulls: %s", gB_Null[client] ? "Enabled" : "Disabled");
	return Plugin_Handled;
}

public Action Command_Lj(int client, int args)
{
	gB_LJ[client] = !gB_LJ[client];
	return Plugin_Handled;
}

public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style, stylesettings_t stylesettings, int mouse[2])
{
	if(stylesettings.bBlockW || stylesettings.bBlockA || stylesettings.bBlockD || !!stylesettings.iForceHSW|| stylesettings.bBlockS)
	{
		gB_Blocked[client] = true;
		gI_UseKey[client] = In_None;
		return Plugin_Continue;
	}
	else
	{
		gB_Blocked[client] = false;
	}
	if( (buttons & IN_MOVELEFT == IN_MOVELEFT) && (gI_PrevButtons[client] & IN_MOVELEFT == IN_MOVELEFT) && (gI_PrevButtons[client] & IN_MOVERIGHT != IN_MOVERIGHT) && (buttons & IN_MOVERIGHT == IN_MOVERIGHT))
	{
		gI_UseKey[client] = In_D;
	}
	if(((buttons & IN_MOVELEFT == IN_MOVELEFT) && (gI_PrevButtons[client] & IN_MOVELEFT == IN_MOVELEFT) && (gI_PrevButtons[client] & IN_MOVERIGHT != IN_MOVERIGHT) && (buttons & IN_MOVERIGHT != IN_MOVERIGHT)))
	{
		gI_UseKey[client] = In_A;
	}
	if( (buttons & IN_MOVERIGHT == IN_MOVERIGHT) && (gI_PrevButtons[client] & IN_MOVERIGHT == IN_MOVERIGHT) && (gI_PrevButtons[client] & IN_MOVELEFT != IN_MOVELEFT) && (buttons & IN_MOVELEFT == IN_MOVELEFT))
	{
		gI_UseKey[client] = In_A;
	}
	if( (buttons & IN_MOVERIGHT == IN_MOVERIGHT) && (gI_PrevButtons[client] & IN_MOVERIGHT == IN_MOVERIGHT) && (gI_PrevButtons[client] & IN_MOVELEFT != IN_MOVELEFT) && (buttons & IN_MOVELEFT != IN_MOVELEFT))
	{
		gI_UseKey[client] = In_D;
	}
	if((buttons & IN_MOVERIGHT != IN_MOVERIGHT) && (buttons & IN_MOVELEFT != IN_MOVELEFT))
	{
		gI_UseKey[client] = In_None;
	}
	//Too Op

	gI_PrevButtons[client] = buttons;

	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{	
	if(gB_Blocked[client])
	{
		return Plugin_Continue;
	}
	if(gB_LJ[client])
	{
		vel[0] = 0.0;
		buttons &= ~IN_FORWARD;
		buttons |= IN_JUMP;
	}

	if( !gB_Null[client] )
	{
		return Plugin_Continue;
	}
	
	if(gI_UseKey[client] == In_D)
	{
		buttons &= ~IN_MOVELEFT;
		vel[1] = 450.0;
		buttons |= IN_MOVERIGHT;
	}
	else if(gI_UseKey[client] == In_A)
	{
		buttons &= ~IN_MOVERIGHT;
		vel[1] = -450.0;
		buttons |= IN_MOVELEFT;
	}
	
	return Plugin_Continue;
}

stock void Void_Strafe_Left(int client, int &buttons, float vel[3])
{
	vel[1] = -450.0;
	buttons |= IN_MOVELEFT;
}

stock void Void_Strafe_Right(int client, int &buttons, float vel[3])
{
	vel[1] = 450.0;
	buttons |= IN_MOVERIGHT;
}

stock void Void_Release_Right(int client, int &buttons)
{
	buttons &= ~IN_MOVERIGHT;
}

stock void Void_Release_Left(int client, int &buttons)
{
	buttons &= ~IN_MOVELEFT;
}














