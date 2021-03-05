#include <sourcemod>
#include <sdktools_functions>
#include <shavit>


#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = 
{
	name = "Autostrafe",
	author = "KiD Fearless",
	description = "https://steamcommunity.com/id/kidfearless/",
	version = "1.0",
	url = "www.joinsg.net"
}

bool gB_MoveLeft[MAXPLAYERS+1];
bool gB_MoveRight[MAXPLAYERS+1];


public void OnClientConnected(int client)
{
	gB_MoveLeft[client] = false;
	gB_MoveRight[client] = false;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3])
{
	char sSpecial[128];
	Shavit_GetStyleStrings(style, sSpecialString, sSpecial, 128);

	if(StrContains(sSpecial, "autostrafe", false) == -1)
	{
		return Plugin_Continue;
	}
	
	if((GetEntityMoveType(client) == MOVETYPE_NOCLIP) || (GetEntityMoveType(client) & MOVETYPE_LADDER))
	{
		return Plugin_Continue;
	}
	
	if((buttons & IN_MOVELEFT) || (buttons & IN_MOVERIGHT) || (buttons & IN_BACK) || (buttons & IN_FORWARD))
	{
		return Plugin_Continue;
	}
		
	
	if(buttons & IN_JUMP)
	{
		if(mouse[0] > 3)
		{
			vel[1] = 450.0;
			buttons |= IN_MOVERIGHT;
			gB_MoveLeft[client] = false;
			gB_MoveRight[client] = true;
		}
		else if(mouse[0] < -3)
		{
			vel[1] = -450.0;
			buttons |= IN_MOVELEFT;
			gB_MoveLeft[client] = true;
			gB_MoveRight[client] = false;
		}
		
		else if(gB_MoveLeft[client])
		{
			vel[1] = -450.0;
			buttons |= IN_MOVELEFT;

		}
		else
		{
			vel[1] = 450.0;
			buttons |= IN_MOVERIGHT;
		}
	}
	
	
	return Plugin_Changed;
}

stock void Strafe_Left(int client, int &buttons, float vel[3])
{
	vel[1] = -450.0;
	buttons |= IN_MOVELEFT;
	gB_MoveLeft[client] = true;
	gB_MoveRight[client] = false;
}

stock void Strafe_Right(int client, int &buttons, float vel[3])
{
	vel[1] = 450.0;
	buttons |= IN_MOVERIGHT;
	gB_MoveLeft[client] = false;
	gB_MoveRight[client] = true;
}