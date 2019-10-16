#include <sourcemod>
#include <shavit>
#include <cstrike>
#pragma semicolon 1
#pragma newdecls required

bool gB_Opti[MAXPLAYERS+1];

float gF_HighestSpeed[MAXPLAYERS+1];
float gF_OldSpeed[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "Weekly Style - Surf Optimizer",
	author = "KiD Fearless",
	description = "Zero speed loss while on the style",
	version = "1.0",
	url = ""
}


public void OnClientConnected(int client)
{
	gB_Opti[client] = false;
}

public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle)
{
	char[] sSpecial = new char[128];
	Shavit_GetStyleStrings(newstyle, sSpecialString, sSpecial, 128);

	if(StrContains(sSpecial, "ws", false) == -1)
	{
		gB_Opti[client] = false;
	}
	else
	{
		gB_Opti[client] = true;
	}
	
}

public void Shavit_OnRestart(int client)
{
	gF_HighestSpeed[client] = 1.0;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{	
	if( ( !gB_Opti[client] ) || ( ( ( GetEntityFlags(client) & FL_ONGROUND ) == FL_ONGROUND ) && ((buttons & IN_JUMP) != IN_JUMP )) )
	{
		gF_HighestSpeed[client] = 1.0;
		return Plugin_Continue;
	}
	if( vel[0] != 0.0)
	{
		gF_HighestSpeed[client] = 1.0;
		return Plugin_Continue;
	} 
	if((GetEntityMoveType(client) == MOVETYPE_NOCLIP) || (GetEntityMoveType(client) & MOVETYPE_LADDER))
	{
		return Plugin_Continue;
	}

	float fAbsVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fAbsVelocity);

	float fSpeed = (SquareRoot(Pow(fAbsVelocity[0], 2.0) + Pow(fAbsVelocity[1], 2.0)));
	if (fSpeed > 10000.0)
	{
		gF_HighestSpeed[client] = 10000.0;
		return Plugin_Continue;
	}

	if(fSpeed > gF_HighestSpeed[client]) //if your speed increased
	{
		gF_HighestSpeed[client] = fSpeed; // then your new speed is that
	}
	else if(10000.0 > fSpeed > 1.0) // if your speed didn't increase
	{
		gF_HighestSpeed[client] = FloatAbs(gF_HighestSpeed[client] + ((gF_HighestSpeed[client] / fSpeed) / 10.0));// then your new speed is your old speed * speed value
	}

	float fMin = gF_HighestSpeed[client];

	if(fMin != 0.0 && fSpeed < fMin)
	{
		float x = (fSpeed / fMin);
		fAbsVelocity[0] /= x;
		fAbsVelocity[1] /= x;
	}

	SetEntPropVector(client, Prop_Data, "m_vecVelocity", fAbsVelocity);

	gF_OldSpeed[client] = fSpeed;
	return Plugin_Continue;
}