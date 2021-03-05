#include <sourcemod>
#include <sdktools>

#include <shavit>

#include <msharedutil/arrayvec>
#include <msharedutil/ents>

#pragma newdecls required
#pragma semicolon 1


#define TRACEDIF 8.0

#define WALLJUMP_BOOST 500.0

#define BOOST 500.0

enum
{
    Tag_int,
    Tag_bool,
    Tag_char,
    Tag_float,
    Tag_Handle
}

typedef ForInLoop = function Action (any data, int tagType);

enum struct foobar_t
{
	int iBar;
	float fBar;
	Handle hBar;

	Action ForIn(ForInLoop loop)
	{
		Action result;
		Call_StartFunction(INVALID_HANDLE, loop);
		Call_PushCell(this.iBar);
		Call_PushCell(Tag_int);
		Call_Finish(result);
		if(result == Plugin_Stop)
		{
			return result;
		}
	}
}


float g_flNextWallJump[MAXPLAYERS+1];
float g_flNextBoost[MAXPLAYERS+1];

public Plugin myinfo =
{
	author = "",
	url = "",
	name = "parkour",
	description = "KiD Fearless",
	version = "",
};


public void OnClientPutInServer( int client )
{
	g_flNextWallJump[client] = 0.0;
	g_flNextBoost[client] = 0.0;
}

public Action Shavit_OnStart(int client, int track)
{
	g_flNextWallJump[client] = 0.0;
	g_flNextBoost[client] = 0.0;
}

public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style)
{
	if ( !IsPlayerAlive( client ) )
	{
		return Plugin_Continue;
	}
	
	char[] sSpecial = new char[32];
	Shavit_GetStyleStrings(style, sSpecialString, sSpecial, 32);

	if(StrContains(sSpecial, "parkour", false) == -1)
	{
		return Plugin_Continue;
	}

	if (( buttons & IN_ATTACK2 && (Shavit_GetClientTime(client) > g_flNextWallJump[client])) && status == Timer_Running)
	{
		float pos[3];
		float normal[3];
		
		GetClientAbsOrigin( client, pos );
		
		if ( FindWall( pos, normal ) )
		{
			float velocity[3];
			GetEntityVelocity( client, velocity );
			
			for ( int i = 0; i < 3; i++ )
			{
				velocity[i] += normal[i] * WALLJUMP_BOOST;
			}
			
			if ( velocity[2] < WALLJUMP_BOOST )
			{
				velocity[2] = WALLJUMP_BOOST;
			}
			
			
			TeleportEntity( client, NULL_VECTOR, NULL_VECTOR, velocity );
			
			
			g_flNextWallJump[client] = Shavit_GetClientTime(client) + 0.5;
		}
	}
	
	if (( buttons & IN_ATTACK && (Shavit_GetClientTime(client) > g_flNextBoost[client])) && status == Timer_Running)
	{
		float vec[3];
		GetClientEyeAngles( client, vec );
		
		GetAngleVectors( vec, vec, NULL_VECTOR, NULL_VECTOR );
		
		
		float velocity[3];
		GetEntityVelocity( client, velocity );
		
		for ( int i = 0; i < 3; i++ )
		{
			velocity[i] += vec[i] * BOOST;
		}
		
		TeleportEntity( client, NULL_VECTOR, NULL_VECTOR, velocity );
		
		
		g_flNextBoost[client] = Shavit_GetClientTime(client) + 3.0;
	}
	
	return Plugin_Continue;
}

stock bool FindWall(  const float pos[3], float normal[3] )
{
	float end[3];
	
	
	end = pos; end[0] += TRACEDIF;
	if ( GetTraceNormal( pos, end, normal ) ) return true;
	
	end = pos; end[0] -= TRACEDIF;
	if ( GetTraceNormal( pos, end, normal ) ) return true;
	
	end = pos; end[1] += TRACEDIF;
	if ( GetTraceNormal( pos, end, normal ) ) return true;
	
	end = pos; end[1] -= TRACEDIF;
	if ( GetTraceNormal( pos, end, normal ) ) return true;
	
	end = pos; end[2] += TRACEDIF;
	if ( GetTraceNormal( pos, end, normal ) ) return true;
	
	end = pos; end[2] -= TRACEDIF;
	if ( GetTraceNormal( pos, end, normal ) ) return true;
	
	
	return false;
}

stock bool GetTraceNormal( const float pos[3], const float end[3], float normal[3] )
{
	TR_TraceHullFilter( pos, end, PLYHULL_MINS, PLYHULL_MAXS, MASK_PLAYERSOLID, TrcFltr_AnythingButThoseFilthyScrubs );
	
	if ( TR_GetFraction() != 1.0 )
	{
		TR_GetPlaneNormal( null, normal );
		return true;
	}
	
	return false;
}

public bool TrcFltr_AnythingButThoseFilthyScrubs( int ent, int mask, any data )
{
	return ( ent == 0 || ent > MaxClients );
}
