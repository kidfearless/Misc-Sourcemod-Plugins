#include <sourcemod>
#include <sdktools>

#include <shavit>

#include <msharedutil/arrayvec>
#include <msharedutil/ents>

#pragma newdecls required
#pragma semicolon 1


#define TRACEDIF 8.0
#define WALLJUMP_BOOST 500.0
#define BOOST 100.0

bool gB_Enabled[MAXPLAYERS + 1];

public Plugin myinfo =
{
	author = "Super Parkour",
	author = "KiD Fearless",
	description = "super duper fast parkour",
	version = "1.0",
	url = "https://steamcommunity.com/id/kidfearless/"
};

public void OnClientDisconnect(int client)
{
	gB_Enabled[client] = false;
}

public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle)
{
	char[] sSpecial = new char[128];
	Shavit_GetStyleStrings(newstyle, sSpecialString, sSpecial, 128);

	if(StrContains(sSpecial, "ws", false) == -1)
	{
		gB_Enabled[client] = false;
	}
	else
	{
		gB_Enabled[client] = true;
	}
}

public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style)
{
	if(!gB_Enabled[client])
	{
		return Plugin_Continue;
	}
	if (!IsPlayerAlive(client))
	{
		return Plugin_Continue;
	}
	
	if(buttons & IN_ATTACK2 == IN_ATTACK2)
	{
		float pos[3];
		float normal[3];
		
		GetClientAbsOrigin(client, pos);
		
		if (FindWall(pos, normal))
		{
			float velocity[3];
			GetEntityVelocity(client, velocity);
			
			for (int i = 0; i < 3; i++)
			{
				velocity[i] += normal[i] * WALLJUMP_BOOST;
			}
			
			if (velocity[2] < WALLJUMP_BOOST)
			{
				velocity[2] = WALLJUMP_BOOST;
			}
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		}
	}
	
	if (buttons & IN_ATTACK == IN_ATTACK)
	{
		float vec[3];
		GetClientEyeAngles(client, vec);
		GetAngleVectors(vec, vec, NULL_VECTOR, NULL_VECTOR);
		float velocity[3];
		GetEntityVelocity(client, velocity);
		for (int i = 0; i < 3; i++)
		{
			velocity[i] += vec[i] * BOOST;
		}
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	
	return Plugin_Continue;
}

stock bool FindWall( const float pos[3], float normal[3])
{
	float end[3];
	
	end = pos; end[0] += TRACEDIF;
	if (GetTraceNormal(pos, end, normal)) return true;
	
	end = pos; end[0] -= TRACEDIF;
	if (GetTraceNormal(pos, end, normal)) return true;
	
	end = pos; end[1] += TRACEDIF;
	if (GetTraceNormal(pos, end, normal)) return true;
	
	end = pos; end[1] -= TRACEDIF;
	if (GetTraceNormal(pos, end, normal)) return true;
	
	end = pos; end[2] += TRACEDIF;
	if (GetTraceNormal(pos, end, normal)) return true;
	
	end = pos; end[2] -= TRACEDIF;
	if (GetTraceNormal(pos, end, normal)) return true;
	
	
	return false;
}

stock bool GetTraceNormal(const float pos[3], const float end[3], float normal[3])
{
	TR_TraceHullFilter(pos, end, PLYHULL_MINS, PLYHULL_MAXS, MASK_PLAYERSOLID, TrcFltr_AnythingButThoseFilthyScrubs);
	
	if (TR_GetFraction() != 1.0)
	{
		TR_GetPlaneNormal(null, normal);
		return true;
	}
	
	return false;
}

public bool TrcFltr_AnythingButThoseFilthyScrubs(int ent, int mask, any data)
{
	return (ent == 0 || ent > MaxClients);
}
