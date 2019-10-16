#include <sourcemod>
#include <sdktools_functions>
#include <shavit>


#define PRE_VELMOD_MAX 1.10769230769 // Calculated 276/250
#define PRE_VELMOD_INCREMENT 0.0024 // Per tick when prestrafing
#define PRE_VELMOD_DECREMENT 0.0021 // Per tick when not prestrafing

float preVelMod[MAXPLAYERS+1] = {1.0, ...};



public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style, stylesettings_t stylesettings, int mouse[2])
{
	if (GetEntityFlags(client) & FL_ONGROUND == FL_ONGROUND)
		CalcPrestrafeVelMod(client, buttons, mouse);
	else
		preVelMod[client] = 1.0;
	return Plugin_Continue;
}

void CalcPrestrafeVelMod(int client, int &buttons, int mouse[2])
{
	if ((mouse[0] != 0)
		&& ((buttons & IN_FORWARD && !(buttons & IN_BACK)) || (!(buttons & IN_FORWARD) && buttons & IN_BACK))
		&& ((buttons & IN_MOVELEFT && !(buttons & IN_MOVERIGHT)) || (!(buttons & IN_MOVELEFT) && buttons & IN_MOVERIGHT)))
	{
		preVelMod[client] += PRE_VELMOD_INCREMENT;
	}
	else
	{
		preVelMod[client] -= PRE_VELMOD_DECREMENT;
	}
	
	// Keep prestrafe velocity modifier within range
	if (preVelMod[client] < 1.0)
	{
		preVelMod[client] = 1.0;
	}
	else if (preVelMod[client] > PRE_VELMOD_MAX)
	{
		preVelMod[client] = PRE_VELMOD_MAX;
	}
	
	SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", preVelMod[client]);
}
