#include <sourcemod>
#include <shavit>
#pragma semicolon 1

float gF_LastAngle[MAXPLAYERS];

enum Strafe_t
{
    STRF_INVALID = 0,
    STRF_LEFT,
    STRF_RIGHT
};

public Plugin myinfo =
{
	name = "Shavit-Backwards",
	author = "KiD Fearless",
	description = "Backwards only style",
	version = "1.0",
	url = "https://github.com/kidfearless"
}

bool gB_Activated[MAXPLAYERS+1];

public void OnClientConnected(iClient)
{
	gB_Activated[iClient] = false;
}

public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle)
{
	char specialString[64];
	Shavit_GetStyleStrings(newstyle, sSpecialString, specialString, sizeof(specialString));
	if(StrContains(specialString, "back", false) == -1)
	{
		gB_Activated[client] = false;
	}
	else
	{
		gB_Activated[client] = true;
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3])
{
	if(gB_Activated[client])
	{
		if(IsPlayerAlive(client))
		{
			Strafe_t dir = GetStrafe(angles[1], gF_LastAngle[client], 1.0);
			if((dir == STRF_RIGHT) && (vel[1] > 0.0))
			{
				vel[1] = 0.0;
			}
			else if((dir == STRF_LEFT) && (vel[1] < 0.0))
			{
				vel[1] = 0.0;
			}
		}
	}
	gF_LastAngle[client] = angles[1];
}


stock Strafe_t GetStrafe( float yaw, float prevyaw, float grace = 5.0 )
{
	float delta = yaw - prevyaw;
	
	if ( delta == 0.0 ) return STRF_INVALID;
	
	
	float min = -180.0 + grace;
	float max = 180.0 - grace;
	
	
	if ( delta > 0.0 )
	{
		return ( yaw > max && prevyaw < min ) ? STRF_RIGHT : STRF_LEFT;
	}
	else
	{
		return ( yaw < min && prevyaw > max ) ? STRF_LEFT : STRF_RIGHT;
	}
}
