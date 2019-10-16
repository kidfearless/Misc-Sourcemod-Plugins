#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <shavit>

#pragma semicolon 1
float gF_TimeSinceLastJump[MAXPLAYERS];
bool gB_GiveJump[MAXPLAYERS];

public void OnPluginStart()
{
	HookEvent("player_jump", OnPlayerJump);
}

public void OnPlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	gF_TimeSinceLastJump[client] = 0.0;
}

public void OnClientPutInServer(int client)
{
	gF_TimeSinceLastJump[client] = 0.0;
	gB_GiveJump[client] = false;
}

public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style, stylesettings_t stylesettings, int mouse[2])
{
	if(stylesettings.bAutobhop)
	{
		if(GetEntityMoveType(client) != 0)
		{
			if(buttons & IN_JUMP == IN_JUMP)
			{
				if((GetEntityFlags(client) & FL_ONGROUND) != 0)
				{
					gF_TimeSinceLastJump[client] = GetEngineTime();
					buttons &= ~IN_JUMP;
					return Plugin_Changed;
				}
			}
			else if(GetEngineTime() - gF_TimeSinceLastJump[client] < 0.05)
			{
				if(GetEntityFlags(client) & FL_ONGROUND > 0)
				{
					buttons |= IN_JUMP;
				}
			}
		}
	}
	return Plugin_Continue;
}

stock float GetClientSpeedSq( int client )
{	
	float x = GetEntPropFloat( client, Prop_Send, "m_vecVelocity[0]" );
	float y = GetEntPropFloat( client, Prop_Send, "m_vecVelocity[1]" );
	
	return x*x + y*y;
}

stock float GetClientSpeed( int client )
{
	float speed = SquareRoot( x*x + y*y; );
	if(IsFakeClient(client))
	{
		speed -= 15.0;
	}
	return speed;
}