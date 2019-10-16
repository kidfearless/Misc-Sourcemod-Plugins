#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

/* CVars */

ConVar gCV_PluginEnabled = null;
ConVar gCV_AllowHSW = null;
ConVar gCV_SimulatedTR = null;

/* Cached CVars */

bool gB_PluginEnabled = true;
bool gB_AllowHSW = false;
float gF_SimulatedTR = 102.4;

float gF_LastSpeed[MAXPLAYERS + 1];
bool gB_TouchingTrigger[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "StrafeBooster",
	author = "Nickelony, Credits: Zipcore",
	description = "Boosts your strafing gain to simulate a higher tickrate (1.6 FPS categories as well).",
	version = "0.36"
};

public void OnPluginStart()
{
	HookEvent("round_start", OnRoundStart);
	
	gCV_PluginEnabled = CreateConVar("sm_strafing_enable", "1", "Enable or Disable all features of the plugin.", 0, true, 0.0, true, 1.0);
	gCV_AllowHSW = CreateConVar("sm_strafing_hsw", "0", "Allow HSW strafing.\nWARNING: Do not use this on 'forward' styles because you will gain an unfair amount of speed while strafing like that!", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_SimulatedTR = CreateConVar("sm_strafing_tickrate", "102.4", "Simulated strafing tickrate.", FCVAR_NOTIFY, true, 0.0);
	
	gCV_PluginEnabled.AddChangeHook(OnConVarChanged);
	gCV_AllowHSW.AddChangeHook(OnConVarChanged);
	gCV_SimulatedTR.AddChangeHook(OnConVarChanged);
	
	AutoExecConfig();
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gB_PluginEnabled = gCV_PluginEnabled.BoolValue;
	gB_AllowHSW = gCV_AllowHSW.BoolValue;
	gF_SimulatedTR = gCV_SimulatedTR.FloatValue;
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	HookEntityOutput("trigger_push", "OnStartTouch", StartTouchTrigger);
	HookEntityOutput("trigger_push", "OnEndTouch", EndTouchTrigger);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3])
{
	if(!gB_PluginEnabled)
	{
		return Plugin_Continue;
	}
	
	float fAbsVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);
	
	float fCurrentSpeed = SquareRoot(Pow(fAbsVelocity[0], 2.0) + Pow(fAbsVelocity[1], 2.0));
	float fGain = GetVelocityGain(client, fCurrentSpeed); // Velocity gain from strafing.
	// Just multiplying 'fGain' is a very bad idea.
	
	// We need to use the eye angles to create a new "Gain" definition.
	float fAngleDiff = GetAngleDifference(client, angles); // Angle difference between ticks.
	bool bPlayerStrafing = ((vel[0] != 0.0 || vel[1] != 0.0) && fAngleDiff != 0.0);
	
	if(!bPlayerStrafing || gB_TouchingTrigger[client] || (GetEntityFlags(client) & FL_ONGROUND) || GetEntityMoveType(client) != MOVETYPE_WALK)
	{
		return Plugin_Continue;
	}
	
	if(!gB_AllowHSW)
	{
		if((buttons & IN_FORWARD && buttons & IN_MOVELEFT) || (buttons & IN_FORWARD && buttons & IN_MOVERIGHT) || (buttons & IN_BACK && buttons & IN_MOVELEFT) || (buttons & IN_BACK && buttons & IN_MOVERIGHT))
		{
			return Plugin_Continue;
		}
	}
	
	float fTickrate = 1.0 / GetTickInterval();
	float fTickDiff = 100.0 / fTickrate;
	
	// 100.0 / 64.0 = 1.5625
	// 100.0 / 102.4 = 0.9765625
	// 100.0 / 128.0 = 0.78125
	
	float fStrafingAngle = GetStrafingAngle(fAngleDiff, fTickDiff);
	PrintHintText(client, "%.2f", fStrafingAngle);
	
	SimulateStrafingTickrate(client, fAbsVelocity, fCurrentSpeed, fGain, fStrafingAngle, fTickrate, fTickDiff);
	
	return Plugin_Continue;
}

void SimulateStrafingTickrate(int client, float fAbsVelocity[3], float fCurrentSpeed, float fGain, float fStrafingAngle, float fTickrate, float fTickDiff)
{
	float fMultiplier = gF_SimulatedTR / 100.0; // 102.4 -> 1.024 as a multiplier.
	
	if(fMultiplier == (fTickrate / 100.0)) // If the simulated tickrate equals the server tickrate.
	{
		return;
	}
	
	else if(fMultiplier < (fTickrate / 100.0)) // If you want to have a lower strafing tickrate.
	{
		float fNewGain = fCurrentSpeed / (fCurrentSpeed + (fGain * ((fMultiplier * fTickDiff) - 1.0)));
		
		fAbsVelocity[0] /= fNewGain;
		fAbsVelocity[1] /= fNewGain;
		gF_LastSpeed[client] = SquareRoot(Pow(fAbsVelocity[0], 2.0) + Pow(fAbsVelocity[1], 2.0)); // Prevent unintended boost.
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fAbsVelocity);
	}
	
	else // If you want to have a higher strafing tickrate.
	{
		float fNewGain = fCurrentSpeed / (fCurrentSpeed + (fMultiplier * (fStrafingAngle * 0.1) * fTickDiff));
		
		// Explanation:
		// (0.64 * (15.625 * 0.1) * 1.5625) * [Tickrate 64.0] = 100.0
		// (1.024 * (9.765625 * 0.1) * 0.9765625) * [Tickrate 102.4] = 100.0
		// (1.28 * (7.8125 * 0.1) * 0.78125) * [Tickrate 128.0] = 100.0
		
		// If fStrafingAngle equals fTickDiff, then the player's strafing efficiency equals 100%
		
		fAbsVelocity[0] /= fNewGain;
		fAbsVelocity[1] /= fNewGain;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fAbsVelocity);
	}
}

float GetVelocityGain(int client, float fCurrentSpeed)
{
	float fGain = fCurrentSpeed - gF_LastSpeed[client];
	gF_LastSpeed[client] = fCurrentSpeed;
	
	return fGain;
}

float GetAngleDifference(int client, float angles[3])
{
	float fTempAngle = angles[1];
	
	float fAngles[3];
	GetClientEyeAngles(client, fAngles);
	float fAngleDiff = (fTempAngle - fAngles[1]);
	
	if(fAngleDiff < 0.0)
	{
		fAngleDiff = -fAngleDiff;
	}
	
	return fAngleDiff;
}

float GetStrafingAngle(float fAngleDiff, float fTickDiff)
{
	if(fAngleDiff > (fTickDiff * 10.0))
	{
		fAngleDiff = ((fTickDiff * 10.0) * 2.0) - fAngleDiff;
		
		if(fAngleDiff < 0.0)
		{
			fAngleDiff = 0.0;
		}
	}
	
	return fAngleDiff;
}

/* Pause the plugin while being inside trigger_push */

public int StartTouchTrigger(const char[] output, int entity, int client, float delay)
{
	if(client < 1 || client > MaxClients)
	{
		return;
	}
	
	if(!gB_PluginEnabled || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return;
	}
	
	RequestFrame(StopPlugin, GetClientSerial(client));
}

void StopPlugin(int data)
{
	int client = GetClientFromSerial(data);
	gB_TouchingTrigger[client] = true;
}

public int EndTouchTrigger(const char[] output, int entity, int client, float delay)
{
	if(client < 1 || client > MaxClients)
	{
		return;
	}
	
	if(!gB_PluginEnabled || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return;
	}
	
	RequestFrame(ResumePlugin, GetClientSerial(client));
}

void ResumePlugin(int data)
{
	int client = GetClientFromSerial(data);
	gB_TouchingTrigger[client] = false;
}
