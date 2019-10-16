#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <clientprefs_stocks>

#pragma newdecls required


EngineVersion g_Game;

float gF_LastAngle[MAXPLAYERS + 1][3];
int gI_ClientTickCount[MAXPLAYERS + 1];
float gF_ClientPercentages[MAXPLAYERS + 1][129];

Handle gH_StrafeTrainerCookie;
Handle gH_StrafeTrainerCookieTicks;
bool gB_StrafeTrainer[MAXPLAYERS + 1] = {false, ...};
int gI_StrafeTrainerTicks[MAXPLAYERS + 1] = {10, ...};
float gF_FrameTime;
ConVar sv_air_max_wishspeed = null;


public Plugin myinfo = 
{
	name = "BHOP Strafe Trainer",
	author = "PaxPlay",
	description = "Bhop Strafe Trainer, stuff by kid fearless",
	version = "0.2",
	url = "https://github.com/PaxPlay/bhop-strafe-trainer"
};

public void OnPluginStart()
{	
	sv_air_max_wishspeed = FindConVar("sv_air_max_wishspeed");
	sv_air_max_wishspeed.Flags &= ~(FCVAR_REPLICATED);
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	
	RegConsoleCmd("sm_strafetrainer", Command_StrafeTrainer, "Toggles the Strafe trainer.");

	gH_StrafeTrainerCookie = RegClientCookie("strafetrainer_enabled", "strafetrainer_enabled", CookieAccess_Protected);
	gH_StrafeTrainerCookieTicks = RegClientCookie("strafetrainer_ticks", "strafetrainer_ticks", CookieAccess_Protected);

	// Late loading
	for(int i = 1; i <= MaxClients; i++)
	{
		if(AreClientCookiesCached(i))
		{
			OnClientCookiesCached(i);
		}
	}
	
	gF_FrameTime = GetTickInterval();
}


public void OnClientDisconnect(int client)
{
	gB_StrafeTrainer[client] = false;
}

public void OnClientCookiesCached(int client)
{
	if(GetClientCookieInt(client, gH_StrafeTrainerCookieTicks) == 0)
	{
		SetClientCookieInt(client, gH_StrafeTrainerCookieTicks, 10);
	}
	
	gB_StrafeTrainer[client] = GetClientCookieBool(client, gH_StrafeTrainerCookie);
	gI_StrafeTrainerTicks[client] = GetClientCookieInt(client, gH_StrafeTrainerCookieTicks);
}

public Action Command_StrafeTrainer(int client, int args)
{
	if (args < 1)
	{
		gB_StrafeTrainer[client] = !gB_StrafeTrainer[client];
		SetClientCookieBool(client, gH_StrafeTrainerCookie, gB_StrafeTrainer[client]);
		ReplyToCommand(client, "[SM] Strafe Trainer %s!", gB_StrafeTrainer[client] ? "enabled" : "disabled");
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	int ticks = StringToInt(arg);
	
	if(ticks > 128 || ticks < 1)
	{
		ReplyToCommand(client, "[SM] Please enter a value between 1 and 128");
		return Plugin_Handled;
	}
	else
	{
		gB_StrafeTrainer[client] = true;
		SetClientCookieBool(client, gH_StrafeTrainerCookie, gB_StrafeTrainer[client]);
		gI_StrafeTrainerTicks[client] = ticks;
		SetClientCookieInt(client, gH_StrafeTrainerCookieTicks, ticks);
		ReplyToCommand(client, "[SM] Strafe Trainer set to %i", ticks);
		return Plugin_Handled;
	}
}


float NormalizeAngle(float angle)
{
	float newAngle = angle;
	while (newAngle <= -180.0) newAngle += 360.0;
	while (newAngle > 180.0) newAngle -= 360.0;
	return newAngle;
}

float GetClientVelocity(int client)
{
	float vVel[3];
	
	vVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	vVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	
	
	return GetVectorLength(vVel);
}

float PerfStrafeAngle(float speed)
{
	return RadToDeg(ArcTangent(sv_air_max_wishspeed.FloatValue / speed));
}

void VisualisationString(char[] buffer, int maxlength, float percentage)
{
	
	if (0.5 <= percentage <= 1.5)
	{
		int Spaces = RoundFloat((percentage - 0.5) / 0.05);
		for (int i = 0; i <= Spaces + 1; i++)
		{
			FormatEx(buffer, maxlength, "%s ", buffer);
		}
		
		FormatEx(buffer, maxlength, "%s|", buffer);
		
		for (int i = 0; i <= (21 - Spaces); i++)
		{
			FormatEx(buffer, maxlength, "%s ", buffer);
		}
	}
	else
		Format(buffer, maxlength, "%s", percentage < 1.0 ? "|                   " : "                    |");
}

void GetPercentageColor(float percentage, int &r, int &g, int &b)
{
	int percent = RoundFloat(percentage * 100);
	
	if((percent > 80) && (percent < 120))
	{
		r = 0;
		g = 255;
		b = 0;
	}
	else if((percent >= 120) && (percent <= 150))
	{
		r = 128;
		g = 255;
		b = 0;
	}
	else if((percent >= 150) && (percent <= 180))
	{
		r = 255;
		g = 128;
		b = 0;
	}
	else if(percent >= 180)
	{
		r = 255;
		g = 0;
		b = 0;
	}
	else if((percent >= 50) && (percent <= 80))
	{
		r = 0;
		g = 255;
		b = 128;
	}
	else if((percent >= 25) && (percent <= 50))
	{
		r = 0;
		g = 128;
		b = 255;
	}
	else if(percent <= 25)
	{
		r = 0;
		g = 0;
		b = 255;
	}

}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!gB_StrafeTrainer[client])
	{
		return Plugin_Continue; // dont run when disabled.
	}
	if ((GetEntityFlags( client ) & FL_ONGROUND) && (buttons & IN_JUMP) == 0)
	{
		return Plugin_Continue;
	}
	
	// calculate differences
	float AngDiff;
	AngDiff = NormalizeAngle(gF_LastAngle[client][1] - angles[1]);
	
	//PrintToConsole(client, "%f", sv_air_max_wishspeed.FloatValue);
	// get the perfect angle
	float PerfAngle = PerfStrafeAngle(GetClientVelocity(client));
	
	// get the absolute value of AngDiff
	
	AngDiff = FloatAbs(AngDiff);
	
	// calculate the current percentage
	float Percentage = AngDiff / PerfAngle;
	
	
	if (gI_ClientTickCount[client] >= gI_StrafeTrainerTicks[client]) // only every 10th tick, not really usable otherwise
	{
		float AveragePercentage = 0.0;
		
		int strafetrainerticks = gI_StrafeTrainerTicks[client];
		
		for (int i = 0; i < strafetrainerticks; i++) // calculate average from the last ticks
		{
			AveragePercentage += gF_ClientPercentages[client][i];
			gF_ClientPercentages[client][i] = 0.0;
		}
		AveragePercentage /= strafetrainerticks;
		
		char sVisualisation[32]; // get the visualisation string
		VisualisationString(sVisualisation, sizeof(sVisualisation), AveragePercentage);
		
		// format the message
		char sMessage[256];
		Format(sMessage, sizeof(sMessage), "%d\%", RoundFloat(AveragePercentage * 100));
		
		Format(sMessage, sizeof(sMessage), "%s\n══════^══════", sMessage);
		Format(sMessage, sizeof(sMessage), "%s\n %s ", sMessage, sVisualisation);
		Format(sMessage, sizeof(sMessage), "%s\n══════^══════", sMessage);
		
		
		// get the text color
		int r, g, b;
		GetPercentageColor(AveragePercentage, r, g, b);
		
		// print the text
		Handle hText = CreateHudSynchronizer();
		if(hText != INVALID_HANDLE)
		{
			SetHudTextParams(-1.0, 0.2, (gF_FrameTime*strafetrainerticks), r, g, b, 255, 0, 0.0, 0.0, 0.1);
			//SetHudTextParams(float x, float y, float holdTime, int r, int g, int b, int a, int effect, float fxTime, float fadeIn, float fadeOut)
			ShowSyncHudText(client, hText, sMessage);
			CloseHandle(hText);
		}
		
		gI_ClientTickCount[client] = 0;
	}
	else
	{
		// save the percentage to an array to calculate the average later
		gF_ClientPercentages[client][gI_ClientTickCount[client]] = Percentage;
		gI_ClientTickCount[client]++;
	}
	
	// save the angles to a variable used in the next tick
	gF_LastAngle[client] = angles;
	
	return Plugin_Continue;
}

/* 
stock bool GetClientCookieBool(int client, Handle cookie)
{
	char sValue[8];
	GetClientCookie(client, gH_StrafeTrainerCookie, sValue, sizeof(sValue));
	
	return (sValue[0] != '\0' && StringToInt(sValue));
}

stock void SetClientCookieBool(int client, Handle cookie, bool value)
{
	char sValue[8];
	IntToString(value, sValue, sizeof(sValue));
	
	SetClientCookie(client, cookie, sValue);
}

   SetClientCookieInt(client, cookieHandle, int)
    GetClientCookieInt(client, cookieHandle)

    SetClientCookieFloat(client, cooieHandle, float)
    GetClientCookieFloat(client, cookieHandle)

    SetClientCookieBool(client, cookieHandle, bool)
    GetClientCookieBool(client, cookieHandle)
*/