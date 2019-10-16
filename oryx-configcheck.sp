/*  Oryx AC: collects and analyzes statistics to find some cheaters in CS:S, CS:GO, and TF2 bunnyhop.
 *  Copyright (C) 2018  Nolan O.
 *  Copyright (C) 2018  shavit.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include <sourcemod>
#include <oryx>

#undef REQUIRE_PLUGIN
#include <shavit>

#pragma newdecls required
#pragma semicolon 1

#define DESC1 "Movement config"
#define DESC2 "+klook usage"

// Minimum delay in ticks from last detection until a new one triggers.
#define KLOOK_DELAY 1000

ConVar gCV_KLookDetection = null;
bool gB_KLookUsed[MAXPLAYERS+1];
int gI_LastDetection[MAXPLAYERS+1];

int gI_PerfectConfigStreak[MAXPLAYERS+1];
int gI_PerfectConfigStreakW[MAXPLAYERS+1];
int gI_PerfectConfigStreakA[MAXPLAYERS+1];
int gI_PerfectConfigStreakS[MAXPLAYERS+1];
int gI_PerfectConfigStreakD[MAXPLAYERS+1];
int gI_PerfectConfigStreakWA[MAXPLAYERS+1];
int gI_PerfectConfigStreakWD[MAXPLAYERS+1];
int gI_PerfectConfigStreakSA[MAXPLAYERS+1];
int gI_PerfectConfigStreakSD[MAXPLAYERS+1];
int gI_PreviousButtons[MAXPLAYERS+1];
int gI_JumpsFromZone[MAXPLAYERS+1];

bool gB_Shavit = false;

public Plugin myinfo = 
{
	name = "ORYX movement config module",
	author = "Rusty, shavit",
	description = "Detects movement configs (null binds, \"k120 syndrome\", +klook LJ binds).",
	version = ORYX_VERSION,
	url = "https://github.com/shavitush/Oryx-AC"
}

public void OnPluginStart()
{
	RegAdminCmd("config_streak", Command_ConfigStreak, ADMFLAG_BAN, "Print the config stat buffer for a given player.");

	gCV_KLookDetection = CreateConVar("oryx-configcheck_klook", "1", "How to treat +klook usage?\n-1 - do not.\n0 - disable +klook.\n1 - disable + alert admins and log.\n2 - kick player.", 0, true, -1.0, true, 2.0);
	AutoExecConfig();

	LoadTranslations("common.phrases");

	gB_Shavit = LibraryExists("shavit");
}

public void OnClientPutInServer(int client)
{
	gB_KLookUsed[client] = false;
	gI_LastDetection[client] = 0;

	gI_PerfectConfigStreak[client] = 0;
	gI_PerfectConfigStreakW[client] = 0;
	gI_PerfectConfigStreakA[client] = 0;
	gI_PerfectConfigStreakS[client] = 0;
	gI_PerfectConfigStreakD[client] = 0;
	gI_PerfectConfigStreakWA[client] = 0;
	gI_PerfectConfigStreakWD[client] = 0;
	gI_PerfectConfigStreakSA[client] = 0;
	gI_PerfectConfigStreakSD[client] = 0;
	gI_JumpsFromZone[client] = 0;
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "shavit"))
	{
		gB_Shavit = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if(StrEqual(name, "shavit"))
	{
		gB_Shavit = false;
	}
}

public Action Command_ConfigStreak(int client, int args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "Usage: config_streak <target>");

		return Plugin_Handled;
	}
	
	char[] sArgs = new char[MAX_TARGET_LENGTH];
	GetCmdArgString(sArgs, MAX_TARGET_LENGTH);

	int target = FindTarget(client, sArgs);

	if(target == -1)
	{
		return Plugin_Handled;
	}

	char[] sAuth = new char[32];
	
	if(!GetClientAuthId(target, AuthId_Steam3, sAuth, 32))
	{
		strcopy(sAuth, 32, "ERR_GETTING_ID");
	}
		
	ReplyToCommand(client, "User \x03%N\x01 (\x05%s\x01) is on a total config streak of \x04%d\x01., W: \x04%d\x01 A: \x04%d\x01 S: \x04%d\x01 D: \x04%d\x01", target, sAuth, gI_PerfectConfigStreak[target], gI_PerfectConfigStreakW[target], gI_PerfectConfigStreakA[target], gI_PerfectConfigStreakS[target], gI_PerfectConfigStreakD[target]);
	
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3])
{
	if(gB_Shavit || !IsPlayerAlive(client) || IsFakeClient(client) || !ShouldCheck(client))
	{
		return Plugin_Continue;
	}

	return SetupMove(client, buttons, vel);
}

public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style)
{
	return SetupMove(client, buttons, vel);
}

Action SetupMove(int client, int &buttons, float vel[3])
{
	if(Oryx_CanBypass(client))
	{
		return Plugin_Continue;
	}

	int iFlags = GetEntityFlags(client);
	int iDetect = gCV_KLookDetection.IntValue;

	if(iDetect > -1)
	{
		if((iFlags & FL_ONGROUND) == 0)
		{
			int iLR = (buttons & (IN_MOVELEFT | IN_MOVERIGHT));
			int iFB = (buttons & (IN_FORWARD | IN_BACK));

			if((vel[0] == 0.0 && iFB != 0 && iFB != (IN_FORWARD | IN_BACK)) ||
				(vel[1] == 0.0 && iLR != 0 && iLR != (IN_MOVELEFT | IN_MOVERIGHT)))
			{
				// Disable movement for the whole jump
				gB_KLookUsed[client] = true;
			}
		}

		else
		{
			gB_KLookUsed[client] = false;
		}

		if(gB_KLookUsed[client])
		{
			vel[0] = 0.0;
			vel[1] = 0.0;

			if(iDetect > 0)
			{
				int iTicks = GetGameTickCount();

				if(iTicks - gI_LastDetection[client] >= KLOOK_DELAY)
				{
					Oryx_Trigger(client, (iDetect == 1)? TRIGGER_HIGH_NOKICK:TRIGGER_DEFINITIVE, DESC2);
					gI_LastDetection[client] = iTicks;
				}
			}

			return Plugin_Changed;
		}
	}
	
	if(gB_Shavit)
	{
		if(Shavit_InsideZone(client, Zone_Start, -1))
		{
			gI_JumpsFromZone[client] = 0;

			return Plugin_Continue;
		}
		
		if((iFlags & FL_ONGROUND) > 0 && (buttons & IN_JUMP) > 0)
		{
			gI_JumpsFromZone[client]++;
		}
			
		if(gI_JumpsFromZone[client] < 2)
		{
			return Plugin_Continue;
		}
	}
	
	if(((iFlags & FL_ONGROUND) == 0) || (buttons & IN_JUMP) > 0)
	{
		// Check for perfect transitions in W/A/S/D.

		// Check D
		if((buttons & IN_MOVELEFT) == 0 && (buttons & IN_MOVERIGHT) > 0 && (gI_PreviousButtons[client] & IN_MOVERIGHT) == 0 && (gI_PreviousButtons[client] & IN_MOVELEFT) > 0)
		{
			PerfectTransition(client);
			gI_PerfectConfigStreakD[client]++;
		}
		// Check A
		if ((buttons & IN_MOVERIGHT) == 0 && (buttons & IN_MOVELEFT) > 0 && (gI_PreviousButtons[client] & IN_MOVELEFT) == 0 && (gI_PreviousButtons[client] & IN_MOVERIGHT) > 0)
		{
			PerfectTransition(client);
			gI_PerfectConfigStreakA[client]++;
		}
		// Check S
		if((buttons & IN_FORWARD) == 0 && (buttons & IN_BACK) > 0 && (gI_PreviousButtons[client] & IN_BACK) == 0 && (gI_PreviousButtons[client] & IN_FORWARD) > 0)
		{
			PerfectTransition(client);
			gI_PerfectConfigStreakS[client]++;
		}
		// Check W
		if((buttons & IN_BACK) == 0 && (buttons & IN_MOVELEFT) > 0 && (gI_PreviousButtons[client] & IN_FORWARD) == 0 && (gI_PreviousButtons[client] & IN_BACK) > 0)
		{
			PerfectTransition(client);
			gI_PerfectConfigStreakW[client]++;
		}
		// Are both moveleft/moveright pressed?
		else if((buttons & (IN_MOVELEFT | IN_MOVERIGHT) == (IN_MOVELEFT | IN_MOVERIGHT)) || (buttons & (IN_BACK | IN_FORWARD) == (IN_BACK | IN_FORWARD)))
		{
			gI_PerfectConfigStreak[client] = 0;
			gI_PerfectConfigStreakW[client] = 0;
			gI_PerfectConfigStreakA[client] = 0;
			gI_PerfectConfigStreakS[client] = 0;
			gI_PerfectConfigStreakD[client] = 0;
		}

		// Check WD
		if((buttons & IN_FORWARD) > 0 && (buttons & IN_MOVERIGHT) > 0 && (gI_PreviousButtons[client] & IN_FORWARD) == 0 && (gI_PreviousButtons[client] & IN_MOVERIGHT) == 0)
		{
			PerfectTransition(client);
			gI_PerfectConfigStreakWD[client]++;
		}
		// Check WA
		if((buttons & IN_FORWARD) > 0 && (buttons & IN_MOVELEFT) > 0 && (gI_PreviousButtons[client] & IN_FORWARD) == 0 && (gI_PreviousButtons[client] & IN_MOVELEFT) == 0)
		{
			PerfectTransition(client);
			gI_PerfectConfigStreakWA[client]++;
		}
		// Check SA
		if((buttons & IN_BACK) > 0 && (buttons & IN_MOVELEFT) > 0 && (gI_PreviousButtons[client] & IN_BACK) == 0 && (gI_PreviousButtons[client] & IN_MOVELEFT) == 0)
		{
			PerfectTransition(client);
			gI_PerfectConfigStreakSA[client]++;
		}
		// Check SD
		if((buttons & IN_BACK) > 0 && (buttons & IN_MOVERIGHT) > 0 && (gI_PreviousButtons[client] & IN_BACK) == 0 && (gI_PreviousButtons[client] & IN_MOVERIGHT) == 0)
		{
			PerfectTransition(client);
			gI_PerfectConfigStreakSD[client]++;
		}
		// I hopefully shouldn't need to check previous key presses to reset. and the config doesn't do any "nulling"
		// Reset WD
		// Pressed W without D
		if((buttons & IN_FORWARD) > 0 && (buttons & IN_MOVERIGHT) == 0)
		{
			gI_PerfectConfigStreakWD[client] = 0;
		}
		// Reset WA
		if((buttons & IN_FORWARD) > 0 && (buttons & IN_MOVELEFT) == 0)
		{
			gI_PerfectConfigStreakWA[client] = 0;
		}
		// Reset SA
		if((buttons & IN_BACK) > 0 && (buttons & IN_MOVELEFT) == 0)
		{
			gI_PerfectConfigStreakSA[client] = 0;
		}
		// Reset SD
		if((buttons & IN_BACK) > 0 && (buttons & IN_MOVERIGHT) == 0)
		{
			gI_PerfectConfigStreakSD[client] = 0;
		}
	}

	gI_PreviousButtons[client] = buttons;

	return Plugin_Continue;
}

void PerfectTransition(int client)
{
	if((gI_PerfectConfigStreakW[client] == 75) || (gI_PerfectConfigStreakA[client] == 75) || (gI_PerfectConfigStreakS[client] == 75) || (gI_PerfectConfigStreakD[client] == 75))
	{
		Oryx_Trigger(client, TRIGGER_HIGH, DESC1);
	}
	if((gI_PerfectConfigStreakWD[client] == 75) || (gI_PerfectConfigStreakWA[client] == 75) || (gI_PerfectConfigStreakSD[client] == 75) || (gI_PerfectConfigStreakSA[client] == 75))
	{
		Oryx_Trigger(client, TRIGGER_HIGH, DESC1);
	}
}

stock bool ShouldCheck(int client)
{
	if(Shavit_IsPracticeMode(client))
	{
		return false;
	}
	return true;
}

/* 
//-----------------------------------------------------------------------------
// Check if the player has held both A/D or W/S together for a period of time.
//-----------------------------------------------------------------------------
void checkIfSHSW(int client, int buttons)
{
	static int s_LastKeys[MAXPLAYERS + 1];
	static bool s_bStartedHolding[MAXPLAYERS+1][keyPair];
	static int s_StartHoldTick[MAXPLAYERS+1][keyPair];
	static int s_LastReleased[MAXPLAYERS+1][keyPair];
	int flags = GetEntityFlags(client);
	if(flags & FL_ONGROUND == 0 || buttons & IN_JUMP > 0)
	{
		// Check WD
		if((buttons & IN_FORWARD) > 0 && (buttons & IN_MOVERIGHT) > 0 && (gI_PreviousButtons[client] & IN_FORWARD) == 0 && (gI_PreviousButtons[client] & IN_MOVERIGHT) == 0)
		{
			PerfectTransition(client);
			fwdKeys(client, ForwardRight, ASHHook_OnPerfectKeyChange, (IN_FORWARD + IN_MOVERIGHT), g_Data[client][Current][Tick] - s_LastReleased[client][pair][0]);
		}
		// Check WA
		if((buttons & IN_FORWARD) > 0 && (buttons & IN_MOVELEFT) > 0 && (gI_PreviousButtons[client] & IN_FORWARD) == 0 && (gI_PreviousButtons[client] & IN_MOVELEFT) == 0)
		{
			PerfectTransition(client);
			fwdKeys(client, ForwardLeft, ASHHook_OnPerfectKeyChange, (IN_FORWARD + IN_MOVELEFT), g_Data[client][Current][Tick] - s_LastReleased[client][pair][0]);
		}
		// Check SA
		if((buttons & IN_BACK) > 0 && (buttons & IN_MOVELEFT) > 0 && (gI_PreviousButtons[client] & IN_BACK) == 0 && (gI_PreviousButtons[client] & IN_MOVELEFT) == 0)
		{
			PerfectTransition(client);
			fwdKeys(client, BackLeft, ASHHook_OnPerfectKeyChange, (IN_BACK + IN_MOVELEFT), g_Data[client][Current][Tick] - s_LastReleased[client][pair][0]);
		}
		// Check SD
		if((buttons & IN_BACK) > 0 && (buttons & IN_MOVERIGHT) > 0 && (gI_PreviousButtons[client] & IN_BACK) == 0 && (gI_PreviousButtons[client] & IN_MOVERIGHT) == 0)
		{
			PerfectTransition(client);
			fwdKeys(client, BackRight, ASHHook_OnPerfectKeyChange, (IN_BACK + IN_MOVERIGHT), g_Data[client][Current][Tick] - s_LastReleased[client][pair][0]);
		}
		// I hopefully shouldn't need to check previous key presses to reset. and the config doesn't do any "nulling"
		// Reset WD
		// Pressed W without D
		if((buttons & IN_FORWARD) > 0 && (buttons & IN_MOVERIGHT) == 0)
		{
			gI_PerfectConfigStreakWD[client] = 0;
		}
		// Reset WA
		if((buttons & IN_FORWARD) > 0 && (buttons & IN_MOVELEFT) == 0)
		{
			gI_PerfectConfigStreakWA[client] = 0;
		}
		// Reset SA
		if((buttons & IN_BACK) > 0 && (buttons & IN_MOVELEFT) == 0)
		{
			gI_PerfectConfigStreakSA[client] = 0;
		}
		// Reset SD
		if((buttons & IN_BACK) > 0 && (buttons & IN_MOVERIGHT) == 0)
		{
			gI_PerfectConfigStreakSD[client] = 0;
		}
	}
}
 */