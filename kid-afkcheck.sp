#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <smlib>
#include <shavit>
#include <kid>
#pragma newdecls required
#pragma semicolon 1
//#define DEBUG

public Plugin myinfo = 
{
	name = "BHop AFK Manager",
	author = "Face",
	description = "Face is never AFK"
};

Handle hAFKTimer = null;
float AFKInterval = 1.0;
int LastActionTime[MAXPLAYERS+1];
float LastActionLoc[MAXPLAYERS+1][3];
//0 = not AFK, 1 = maybe AFK, 2 = AFK, 3 = spectator or kicked
int isAFK[MAXPLAYERS+1];

public bool InitNativesForwards()
{
	CreateNative("AFKCheck", Native_AFKCheck);
	return true;
}

public void OnPluginStart()
{
	RegConsoleCmd("say",saycmd);
	RegConsoleCmd("say_team",saycmd);
	HookEventEx("player_team", Event_TeamChange);
	HookEvent("weapon_fire", Event_WeaponFire);
	if(hAFKTimer == null)
	{
		hAFKTimer = CreateTimer(AFKInterval, AFKCheckTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientValid(i))
		{
			LastActionTime[i] = GetTime();
		}
	}
}

public void OnPluginEnd()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientValid(i))
		{
			NotAFK(i);
		}
	}
}

//0 = not AFK, 1 = maybe AFK, 2 = AFK, 3 = spectator or kicked
public int Native_AFKCheck(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return isAFK[client];
}

public void Event_TeamChange(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event,"userid"));
	int team = GetClientOfUserId(GetEventInt(event,"team"));
	if(team != CS_TEAM_SPECTATOR)
	{
		NotAFK(client);
		LastActionTime[client] = GetTime();
	}
}

public void OnMapEnd()
{
	if(hAFKTimer != null)
	{
		KillTimer(hAFKTimer);
		hAFKTimer = null;
	}
}

public void OnMapStart()
{
	if(hAFKTimer == null)
	{
		hAFKTimer = CreateTimer(AFKInterval, AFKCheckTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void OnClientConnected(int client)
{
	LastActionTime[client] = GetTime();
	isAFK[client] = 0;
}

public void Event_WeaponFire(Handle event, const char[] name, bool dontBroadcast)
{ 
	int client = GetClientOfUserId(GetEventInt(event,"userid"));
	LastActionTime[client] = GetTime();
}

public Action saycmd(int client, int args)
{
	char cmdstr[64];
	GetCmdArg(1, cmdstr, sizeof(cmdstr));

	LastActionTime[client] = GetTime();
	return Plugin_Continue;
}

public Action AFKCheckTimer(Handle t)
{
	int time = GetTime();
	#if defined DEBUG
	PrintToConsole(KiD, "timer ticked, time: %.2f", time);
	#endif
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientValid(i))
		{
			#if defined DEBUG
			PrintToConsole(KiD, "timer | Valid Client");
			#endif

			float iloc[3];
			GetClientAbsOrigin(i, iloc);
			if(GetVectorDistance(iloc, LastActionLoc[i]) < 75.0)
			{
				#if defined DEBUG
				PrintToConsole(KiD, "timer | Valid Client | Check Loc | didn't move");
				#endif
				if(time - LastActionTime[i] >= 30)
				{
					#if defined DEBUG
					PrintToConsole(KiD, "timer | Valid Client | Check Loc | didn't move | time - lastactiontime");
					#endif
					FlagAsAFK(i);
					LastActionTime[i] = GetTime();
				}
			}
			else
			{
				#if defined DEBUG
				PrintToConsole(KiD, "timer | Valid Client | Check Loc | else");
				#endif
				NotAFK(i);
				LastActionTime[i] = time;
				LastActionLoc[i] = iloc;
			}
			float Vel[3];
			GetEntPropVector(i, Prop_Data, "m_vecVelocity", Vel);
			if(Vel[0] != 0.0 || Vel[1] != 0.0 || Vel[2] != 0.0)
			{
				LastActionTime[i] = time;
			}
		}
	}
	return Plugin_Continue;
}

public void Shavit_OnRestart(int client, int track)
{
	GetClientAbsOrigin(client, LastActionLoc[client]);
	LastActionTime[client] = GetTime();
	#if defined DEBUG
	PrintToConsole(KiD, "Shavit_OnRestart, LastActionTime: %0.2f", LastActionTime[KiD]);
	#endif
}

void NotAFK(int client)
{
	if(IsClientValid(client))
	{
		if(isAFK[client] > 0)
		{
			isAFK[client] = 0;
		}
	}
}

void FlagAsAFK(int client)
{
	if(IsClientValid(client))
	{
		isAFK[client]++;
		if(isAFK[client]==1)
		{
		//	PrintToChat(client, " \x07[AFKChecker] \x0AYou \x07are flagged as AFK!");
		}
		if(isAFK[client]==2)
		{
			PrintToChat(client, " \x07[AFKChecker] You will be swapped/kicked for being AFK!");
		}
		if(isAFK[client]==3)
		{
			ChangeClientTeam(client, CS_TEAM_SPECTATOR);
		}
	}
}