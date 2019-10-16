#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <smlib/arrays>

#undef REQUIRE_PLUGIN
#include <shavit>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "SSJ: Advanced",
	author = "AlkATraZ",
	description = "Strafe gains/efficiency etc.",
	version = SHAVIT_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=287039"
}

#define BHOP_FRAMES 10

#define USAGE_SIXTH 0
#define USAGE_EVERY 1
#define USAGE_EVERY_SIXTH 2

Handle gH_CookieEnabled = null;
Handle gH_CookieUsageMode = null;
Handle gH_CookieUsageRepeat = null;
Handle gH_CookieCurrentSpeed = null;
Handle gH_CookieFirstJump = null;
Handle gH_CookieHeightDiff = null;
Handle gH_CookieSpeedDiff = null;
Handle gH_CookieGainStats = null;
Handle gH_CookieEfficiency = null;
Handle gH_CookieStrafeSync = null;
Handle gH_CookieStrafeCount = null;
Handle gH_CookieTimerStatus = null;
Handle gH_CookieSpeedLoss = null;
Handle gH_CookieDefaultsSet = null;


int gI_UsageMode[MAXPLAYERS+1];
bool gB_UsageRepeat[MAXPLAYERS+1];
bool gB_Enabled[MAXPLAYERS+1] = {true, ...};
bool gB_CurrentSpeed[MAXPLAYERS+1] = {true, ...};
bool gB_FirstJump[MAXPLAYERS+1] = {true, ...};
bool gB_SpeedDiff[MAXPLAYERS+1];
bool gB_HeightDiff[MAXPLAYERS+1];
bool gB_GainStats[MAXPLAYERS+1] = {true, ...};
bool gB_Efficiency[MAXPLAYERS+1];
bool gB_StrafeSync[MAXPLAYERS+1];
bool gB_StrafeCount[MAXPLAYERS+1];
bool gB_TouchesWall[MAXPLAYERS+1];
bool gB_TimerStatus[MAXPLAYERS+1] = {false, ...};
bool gB_SpeedLoss[MAXPLAYERS+1] = {false, ...};
bool gB_PrintConsole[MAXPLAYERS+1] = {false, ...};

int gI_TicksOnGround[MAXPLAYERS+1];
int gI_TouchTicks[MAXPLAYERS+1];
int gI_StrafeTick[MAXPLAYERS+1];
int gI_SyncedTick[MAXPLAYERS+1];
int gI_Jump[MAXPLAYERS+1];
int gI_StrafeCount[MAXPLAYERS+1];
int gI_ButtonCache[MAXPLAYERS+1];

float gF_InitialSpeed[MAXPLAYERS+1];
float gF_InitialHeight[MAXPLAYERS+1];
float gF_OldHeight[MAXPLAYERS+1];
float gF_OldSpeed[MAXPLAYERS+1];
float gF_RawGain[MAXPLAYERS+1];
float gF_Trajectory[MAXPLAYERS+1];
float gF_TraveledDistance[MAXPLAYERS+1][3];
float gF_SpeedLoss[MAXPLAYERS+1];
float gF_OldVelocity[MAXPLAYERS+1];


float gF_Tickrate = 0.01;

// chat settings
bool gB_Late = false;
bool gB_Shavit = false;
EngineVersion gEV_Type = Engine_Unknown;

char gS_ChatStrings[CHATSETTINGS_SIZE][128] =
{
	"\x04[SSJ]",
	"\x01",
	"\x02",
	"\x04",
	"\x05",
	"\x03"
}; 

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	gB_Late = late;

	return APLRes_Success;
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_ssj", Command_SSJ, "Open the Speed @ Sixth Jump menu.");
	RegConsoleCmd("sm_console", Command_Console, "prints ssj to console");
	
	gH_CookieEnabled = RegClientCookie("ssj_enabled", "ssj_enabled", CookieAccess_Public);
	gH_CookieUsageMode = RegClientCookie("ssj_displaymode", "ssj_displaymode", CookieAccess_Public);
	gH_CookieUsageRepeat = RegClientCookie("ssj_displayrepeat", "ssj_displayrepeat", CookieAccess_Public);
	gH_CookieCurrentSpeed = RegClientCookie("ssj_currentspeed", "ssj_currentspeed", CookieAccess_Public);
	gH_CookieFirstJump = RegClientCookie("ssj_firstjump", "ssj_firstjump", CookieAccess_Public);
	gH_CookieSpeedDiff = RegClientCookie("ssj_speeddiff", "ssj_speeddiff", CookieAccess_Public);
	gH_CookieHeightDiff = RegClientCookie("ssj_heightdiff", "ssj_heightdiff", CookieAccess_Public);
	gH_CookieGainStats = RegClientCookie("ssj_gainstats", "ssj_gainstats", CookieAccess_Public);
	gH_CookieEfficiency = RegClientCookie("ssj_efficiency", "ssj_efficiency", CookieAccess_Public);
	gH_CookieStrafeSync = RegClientCookie("ssj_strafesync", "ssj_strafesync", CookieAccess_Public);
	gH_CookieStrafeCount = RegClientCookie("ssj_strafecount", "ssj_strafecount", CookieAccess_Public);
	gH_CookieTimerStatus = RegClientCookie("ssj_timerstatus", "ssj_timerstatus", CookieAccess_Public);
	gH_CookieSpeedLoss = RegClientCookie("ssj_speedloss", "ssj_speedloss", CookieAccess_Public);
	gH_CookieDefaultsSet = RegClientCookie("ssj_defaults", "ssj_defaults", CookieAccess_Public);

	HookEvent("player_jump", Player_Jump);
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
			OnClientCookiesCached(i);
		}
	}

	if(gB_Late)
	{
		Shavit_OnChatConfigLoaded();
	}

	gB_Shavit = LibraryExists("shavit");
	gEV_Type = GetEngineVersion();
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

public void OnMapStart()
{
	gF_Tickrate = GetTickInterval();
}

public void Shavit_OnChatConfigLoaded()
{
	for(int i = 0; i < CHATSETTINGS_SIZE; i++)
	{
		Shavit_GetChatStrings(i, gS_ChatStrings[i], 128);
	}
}

public void OnClientCookiesCached(int client)
{
	char[] sCookie = new char[8];
	
	GetClientCookie(client, gH_CookieDefaultsSet, sCookie, 8);
	
	if(StringToInt(sCookie) == 0)
	{
		SetCookie(client, gH_CookieEnabled, true);
		SetCookie(client, gH_CookieUsageMode, 6);
		SetCookie(client, gH_CookieUsageRepeat, false);
		SetCookie(client, gH_CookieCurrentSpeed, true);
		SetCookie(client, gH_CookieFirstJump, true);
		SetCookie(client, gH_CookieSpeedDiff, false);
		SetCookie(client, gH_CookieHeightDiff, false);
		SetCookie(client, gH_CookieGainStats, true);
		SetCookie(client, gH_CookieEfficiency, false);
		SetCookie(client, gH_CookieStrafeSync, false);
		SetCookie(client, gH_CookieStrafeCount, true);
		SetCookie(client, gH_CookieTimerStatus, false);
		SetCookie(client, gH_CookieSpeedLoss, false);
		
		SetCookie(client, gH_CookieDefaultsSet, true);
	}
	
	GetClientCookie(client, gH_CookieEnabled, sCookie, 8);
	gB_Enabled[client] = view_as<bool>(StringToInt(sCookie));
	
	GetClientCookie(client, gH_CookieUsageMode, sCookie, 8);
	gI_UsageMode[client] = StringToInt(sCookie);

	GetClientCookie(client, gH_CookieUsageRepeat, sCookie, 8);
	gB_UsageRepeat[client] = view_as<bool>(StringToInt(sCookie));
	
	GetClientCookie(client, gH_CookieCurrentSpeed, sCookie, 8);
	gB_CurrentSpeed[client] = view_as<bool>(StringToInt(sCookie));

	GetClientCookie(client, gH_CookieFirstJump, sCookie, 8);
	gB_FirstJump[client] = view_as<bool>(StringToInt(sCookie));
	
	GetClientCookie(client, gH_CookieSpeedDiff, sCookie, 8);
	gB_SpeedDiff[client] = view_as<bool>(StringToInt(sCookie));
	
	GetClientCookie(client, gH_CookieHeightDiff, sCookie, 8);
	gB_HeightDiff[client] = view_as<bool>(StringToInt(sCookie));
	
	GetClientCookie(client, gH_CookieGainStats, sCookie, 8);
	gB_GainStats[client] = view_as<bool>(StringToInt(sCookie));
	
	GetClientCookie(client, gH_CookieEfficiency, sCookie, 8);
	gB_Efficiency[client] = view_as<bool>(StringToInt(sCookie));
	
	GetClientCookie(client, gH_CookieStrafeSync, sCookie, 8);
	gB_StrafeSync[client] = view_as<bool>(StringToInt(sCookie));
	
	GetClientCookie(client, gH_CookieTimerStatus, sCookie, 9);
	gB_TimerStatus[client] = view_as<bool>(StringToInt(sCookie));
	
	GetClientCookie(client, gH_CookieSpeedLoss, sCookie, 9);
	gB_SpeedLoss[client] = view_as<bool>(StringToInt(sCookie));
	
	GetClientCookie(client, gH_CookieStrafeCount, sCookie, 9);
	gB_StrafeCount[client] = view_as<bool>(StringToInt(sCookie));
}

public void OnClientPutInServer(int client)
{
	gI_Jump[client] = 0;
	gI_StrafeTick[client] = 0;
	gI_SyncedTick[client] = 0;
	gF_RawGain[client] = 0.0;
	gF_InitialHeight[client] = 0.0;
	gF_InitialSpeed[client] = 0.0;
	gF_OldHeight[client] = 0.0;
	gF_OldSpeed[client] = 0.0;
	gF_Trajectory[client] = 0.0;
	gF_TraveledDistance[client] = NULL_VECTOR;
	gI_TicksOnGround[client] = 0;
	gI_StrafeCount[client] = 0;
	gF_SpeedLoss[client] = 0.0;

	SDKHook(client, SDKHook_Touch, OnTouch);
}

public Action OnTouch(int client, int entity)
{
	if((GetEntProp(entity, Prop_Data, "m_usSolidFlags") & 12) == 0)
	{
		gB_TouchesWall[client] = true;
	}
}

int GetHUDTarget(int client)
{
	int target = client;

	if(IsClientObserver(client))
	{
		int iObserverMode = GetEntProp(client, Prop_Send, "m_iObserverMode");

		if(iObserverMode >= 3 && iObserverMode <= 5)
		{
			int iTarget = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

			if(IsValidClient(iTarget, true))
			{
				target = iTarget;
			}
		}
	}

	return target;
}

public void Player_Jump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(IsFakeClient(client))
	{
		return;
	}
	
	if(gI_Jump[client] > 0 && gI_StrafeTick[client] <= 0)
	{
		return;
	}
	
	gI_Jump[client]++;

	float velocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity);

	float origin[3];
	GetClientAbsOrigin(client, origin);

	velocity[2] = 0.0;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && ((!IsPlayerAlive(i) && GetEntPropEnt(i, Prop_Data, "m_hObserverTarget") == client && GetEntProp(i, Prop_Data, "m_iObserverMode") != 7 && gB_Enabled[i]) || ((i == client && gB_Enabled[i] && ((gI_Jump[i] == 6 && gI_UsageMode[i] == USAGE_SIXTH) || gI_UsageMode[i] == USAGE_EVERY ||  (gI_UsageMode[i] == USAGE_EVERY_SIXTH && (gI_Jump[i] % 6) == 0))))))
		{
			SSJ_PrintStats(i, client);
		}
	}

	if((gI_Jump[client] >= 6 && gI_UsageMode[client] == USAGE_SIXTH) || gI_UsageMode[client] == USAGE_EVERY || (gI_Jump[client] % 6) == 0 && gI_UsageMode[client] == USAGE_EVERY_SIXTH)
	{
		gF_RawGain[client] = 0.0;
		gI_StrafeTick[client] = 0;
		gI_SyncedTick[client] = 0;	
		gI_StrafeCount[client] = 0;
		gF_SpeedLoss[client] = 0.0;
		gF_OldHeight[client] = origin[2];
		gF_OldSpeed[client] = GetVectorLength(velocity);
		gF_Trajectory[client] = 0.0;
		gF_TraveledDistance[client] = NULL_VECTOR;
	}
	
	if((gI_Jump[client] == 1 && gI_UsageMode[client] == USAGE_SIXTH) || (gI_Jump[client] % 6 == 1 && gI_UsageMode[client] == USAGE_EVERY_SIXTH))
	{
		gF_InitialHeight[client] = origin[2];
		gF_InitialSpeed[client] = GetVectorLength(velocity);
		gF_TraveledDistance[client] = NULL_VECTOR;
	}
}

public Action Command_SSJ(int client, int args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "[SM] This command can only be used in-game.");

		return Plugin_Handled;
	}

	return ShowSSJMenu(client);
}

public Action Command_Console(int client, int args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "[SM] This command can only be used in-game.");

		return Plugin_Handled;
	}

	gB_PrintConsole[client] = !gB_PrintConsole[client];
	
	return Plugin_Handled;
}

public Action ShowSSJMenu(int client)
{
	Menu menu = new Menu(SSJ_MenuHandler);
	menu.SetTitle("Speed @ Sixth Jump\n ");
	
	menu.AddItem("usage", (gB_Enabled[client])? "[x] Enabled":"[ ] Enabled");

	char[] sMenu = new char[64];
	FormatEx(sMenu, 64, "[%d] Jump", gI_UsageMode[client]);
	menu.AddItem("mode", sMenu);

	menu.AddItem("repeat", (gB_UsageRepeat[client])? "[x] Repeat":"[ ] Repeat");
	menu.AddItem("curspeed", (gB_CurrentSpeed[client])? "[x] Current speed":"[ ] Current speed");
	menu.AddItem("firstjump", (gB_FirstJump[client])? "[x] First jump":"[ ] First jump");
	menu.AddItem("speed", (gB_SpeedDiff[client])? "[x] Speed difference":"[ ] Speed difference");
	menu.AddItem("height", (gB_HeightDiff[client])? "[x] Height difference":"[ ] Height difference");
	menu.AddItem("gain", (gB_GainStats[client])? "[x] Gain percentage":"[ ] Gain percentage");
	menu.AddItem("efficiency", (gB_Efficiency[client])? "[x] Strafe efficiency":"[ ] Strafe efficiency");
	menu.AddItem("sync", (gB_StrafeSync[client])? "[x] Synchronization":"[ ] Synchronization");
	menu.AddItem("strafes", (gB_StrafeCount[client])? "[x] Strafes":"[ ] Strafes");
	menu.AddItem("timer", (gB_TimerStatus[client])? "[x] Timer Status":"[ ] Timer Status");
	menu.AddItem("loss", (gB_SpeedLoss[client])? "[x] Speed Loss":"[ ] Speed Loss");
	
	menu.ExitButton = true;
	
	menu.Display(client, 0);

	return Plugin_Handled;
}

public int SSJ_MenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select)
	{
		switch(param2)
		{
			case 0:
			{
				gB_Enabled[param1] = !gB_Enabled[param1];
				SetCookie(param1, gH_CookieEnabled, gB_Enabled[param1]);
			}

			case 1:
			{
				gI_UsageMode[param1] = (gI_UsageMode[param1] % 9) + 1;
				SetCookie(param1, gH_CookieUsageMode, gI_UsageMode[param1]);
			}

			case 2:
			{
				gB_UsageRepeat[param1] = !gB_UsageRepeat[param1];
				SetCookie(param1, gH_CookieUsageRepeat, gB_UsageRepeat[param1]);
			}

			case 3:
			{
				gB_CurrentSpeed[param1] = !gB_CurrentSpeed[param1];
				SetCookie(param1, gH_CookieCurrentSpeed, gB_CurrentSpeed[param1]);
			}

			case 4:
			{
				gB_FirstJump[param1] = !gB_FirstJump[param1];
				SetCookie(param1, gH_CookieFirstJump, gB_FirstJump[param1]);
			}

			case 5:
			{
				gB_SpeedDiff[param1] = !gB_SpeedDiff[param1];
				SetCookie(param1, gH_CookieSpeedDiff, gB_SpeedDiff[param1]);
			}

			case 6:
			{
				gB_HeightDiff[param1] = !gB_HeightDiff[param1];
				SetCookie(param1, gH_CookieHeightDiff, gB_HeightDiff[param1]);
			}

			case 7:
			{
				gB_GainStats[param1] = !gB_GainStats[param1];
				SetCookie(param1, gH_CookieGainStats, gB_GainStats[param1]);
			}

			case 8:
			{
				gB_Efficiency[param1] = !gB_Efficiency[param1];
				SetCookie(param1, gH_CookieEfficiency, gB_Efficiency[param1]);
			}

			case 9:
			{
				gB_StrafeSync[param1] = !gB_StrafeSync[param1];
				SetCookie(param1, gH_CookieStrafeSync, gB_StrafeSync[param1]);
			}
			
			case 10:
			{
				gB_StrafeCount[param1] = !gB_StrafeCount[param1];
				SetCookie(param1, gH_CookieStrafeCount, gB_StrafeCount[param1]);
			}
			
			case 11:
			{
				gB_TimerStatus[param1] = !gB_TimerStatus[param1];
				SetCookie(param1, gH_CookieTimerStatus, gB_TimerStatus[param1]);
			}
			
			case 12:
			{
				gB_SpeedLoss[param1] = !gB_SpeedLoss[param1];
				SetCookie(param1, gH_CookieSpeedLoss, gB_SpeedLoss[param1]);
			}
		}		

		ShowSSJMenu(param1);
	}

	else if(action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

void SSJ_GetStats(int client, float vel[3], float angles[3])
{
	float velocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity);

	gI_StrafeTick[client]++;

	float speedmulti = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
	
	gF_TraveledDistance[client][0] += velocity[0] * gF_Tickrate * speedmulti;
	gF_TraveledDistance[client][1] += velocity[1] * gF_Tickrate * speedmulti;
	velocity[2] = 0.0;

	gF_Trajectory[client] += GetVectorLength(velocity) * gF_Tickrate * speedmulti;
	
	float fore[3];
	float side[3];
	GetAngleVectors(angles, fore, side, NULL_VECTOR);
	
	fore[2] = 0.0;
	NormalizeVector(fore, fore);

	side[2] = 0.0;
	NormalizeVector(side, side);

	float wishvel[3];
	float wishdir[3];
	
	for(int i = 0; i < 2; i++)
	{
		wishvel[i] = fore[i] * vel[0] + side[i] * vel[1];
	}

	float wishspeed = NormalizeVector(wishvel, wishdir);
	float maxspeed = GetEntPropFloat(client, Prop_Send, "m_flMaxspeed");

	if(maxspeed != 0.0 && wishspeed > maxspeed)
	{
		wishspeed = maxspeed;
	}
	
	if(wishspeed > 0.0)
	{
		float wishspd = (wishspeed > 30.0)? 30.0:wishspeed;
		float currentgain = GetVectorDotProduct(velocity, wishdir);
		float gaincoeff = 0.0;

		if(currentgain < 30.0)
		{
			gI_SyncedTick[client]++;
			gaincoeff = (wishspd - FloatAbs(currentgain)) / wishspd;
		}

		if(gB_TouchesWall[client] && gI_TouchTicks[client] && gaincoeff > 0.5)
		{
			gaincoeff -= 1.0;
			gaincoeff = FloatAbs(gaincoeff);
		}

		gF_RawGain[client] += gaincoeff;
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3])
{
	int flags = GetEntityFlags(client);
	float speed = GetClientVelocity(client);
	
	if(flags & FL_ONGROUND != FL_ONGROUND)
	{
		if((gI_ButtonCache[client] & IN_FORWARD) != IN_FORWARD && (buttons & IN_FORWARD) == IN_FORWARD)
		{
			gI_StrafeCount[client]++;
		}
	
		if((gI_ButtonCache[client] & IN_MOVELEFT) != IN_MOVELEFT && (buttons & IN_MOVELEFT) == IN_MOVELEFT)
		{
			gI_StrafeCount[client]++;
		}
	
		if((gI_ButtonCache[client] & IN_BACK) != IN_BACK && (buttons & IN_BACK) == IN_BACK)
		{
			gI_StrafeCount[client]++;
		}
	
		if((gI_ButtonCache[client] & IN_MOVERIGHT) != IN_MOVERIGHT && (buttons & IN_MOVERIGHT) == IN_MOVERIGHT)
		{
			gI_StrafeCount[client]++;
		}
	}
	
	if(gF_OldVelocity[client] > speed)
	{
		gF_SpeedLoss[client] += (FloatAbs(speed - gF_OldVelocity[client]));
	}
	
	
	if(flags & FL_ONGROUND == FL_ONGROUND)
	{
		if(gI_TicksOnGround[client]++ > BHOP_FRAMES)
		{
			gI_Jump[client] = 0;
			gI_StrafeTick[client] = 0;
			gI_SyncedTick[client] = 0;
			gF_RawGain[client] = 0.0;
			gF_Trajectory[client] = 0.0;
			gI_StrafeCount[client] = 0;
			gF_SpeedLoss[client] = 0.0;
			gF_TraveledDistance[client] = NULL_VECTOR;
		}
		
		if((buttons & IN_JUMP) > 0 && gI_TicksOnGround[client] == 1)
		{
			SSJ_GetStats(client, vel, angles);
			gI_TicksOnGround[client] = 0;
		}
	}

	else
	{
		MoveType movetype = GetEntityMoveType(client);

		if(movetype != MOVETYPE_NONE && movetype != MOVETYPE_NOCLIP && movetype != MOVETYPE_LADDER && GetEntProp(client, Prop_Data, "m_nWaterLevel") < 2)
		{
			SSJ_GetStats(client, vel, angles);
		}

		gI_TicksOnGround[client] = 0;
	}

	if(gB_TouchesWall[client])
	{
		gI_TouchTicks[client]++;
		gB_TouchesWall[client] = false;
	}

	else
	{
		gI_TouchTicks[client] = 0;
	}

	gI_ButtonCache[client] = buttons;
	gF_OldVelocity[client] = speed;
	return Plugin_Continue;
}

void SSJ_PrintStats(int client, int target)
{
	if(gI_Jump[target] == 1)
	{
		if(!gB_FirstJump[client] && gI_UsageMode[client] != 1)
		{
			return;
		}
	}

	else if(gB_UsageRepeat[client])
	{
		if(gI_Jump[target] % gI_UsageMode[client] != 0)
		{
			return;
		}
	}

	else if(gI_Jump[target] != gI_UsageMode[client])
	{
		return;
	}
	
	float velocity[3];
	GetEntPropVector(target, Prop_Data, "m_vecAbsVelocity", velocity);
	velocity[2] = 0.0;

	float origin[3];
	GetClientAbsOrigin(target, origin);
	
	
	float coeffsum = gF_RawGain[target];
	coeffsum /= gI_StrafeTick[target];
	coeffsum *= 100.0;
	
	float distance = GetVectorLength(gF_TraveledDistance[target]);

	if(distance > gF_Trajectory[target])
	{
		distance = gF_Trajectory[target];
	}

	float efficiency = 0.0;

	if(distance > 0.0)
	{
		efficiency = coeffsum * (distance) / gF_Trajectory[target];
	}
	
	coeffsum = RoundToFloor(coeffsum * 100.0 + 0.5) / 100.0;
	efficiency = RoundToFloor(efficiency * 100.0 + 0.5) / 100.0;
	
	float time = Shavit_GetClientTime(target);
	
	char[] sTime = new char[32];
	FormatSeconds(time, sTime, 32, true);
	
	char[] sMessage = new char[192];
	FormatEx(sMessage, 192, "Jump: %s%i", gS_ChatStrings[sMessageVariable2], gI_Jump[target]);

	if((gI_UsageMode[client] == USAGE_SIXTH && gI_Jump[target] == 6) || (gI_UsageMode[client] == USAGE_EVERY_SIXTH && (gI_Jump[target] % 6) == 0))
	{
		if(gB_CurrentSpeed[client])
		{
			Format(sMessage, 192, "%s %s| Speed: %s%i", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], RoundToFloor(GetVectorLength(velocity)));
		}
		
		if(gB_TimerStatus[client])
		{
			Format(sMessage, 192, "%s %s| Time: %s%s", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], sTime);
		}
		
		if(gB_SpeedDiff[client])
		{
			Format(sMessage, 192, "%s %s| Speed Δ: %s%i", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], RoundToFloor(GetVectorLength(velocity)) - RoundToFloor(gF_InitialSpeed[target]));
		}

		if(gB_HeightDiff[client])
		{
			Format(sMessage, 192, "%s %s| Height Δ: %s%i", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], RoundToFloor(origin[2]) - RoundToFloor(gF_InitialHeight[target]));
		}

		if(gB_GainStats[client])
		{
			Format(sMessage, 192, "%s %s| Gain: %s%.2f%%", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], coeffsum);
		}

		if(gB_StrafeSync[client])
		{
			Format(sMessage, 192, "%s %s| Sync: %s%.2f%%", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], 100.0 * gI_SyncedTick[target] / gI_StrafeTick[target]);
		}

		if(gB_StrafeCount[client])
		{
			Format(sMessage, 192, "%s %s| Strafes: %s%i", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], gI_StrafeCount[target]);
		}
		
		if(gB_Efficiency[client])
		{
			Format(sMessage, 192, "%s %s| Efficiency: %s%.2f%%", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], efficiency);
		}

		if(gB_SpeedLoss[client])
		{
			Format(sMessage, 192, "%s %s| Loss: %s%.1f", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], gF_SpeedLoss[target]);
		}
		
		Shavit_StopChatSound();
		Shavit_PrintToChat(client, "%s", sMessage);
		if(gB_PrintConsole[client] == true)
		{
			Color_StripFromChatText(sMessage, sMessage, 192);
			PrintToConsole(client, "%s", sMessage);
		}
	}

	else if(gI_UsageMode[client] == USAGE_EVERY)
	{
		if(gB_CurrentSpeed[client])
		{
			Format(sMessage, 192, "%s %s| Speed: %s%i", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], RoundToFloor(GetVectorLength(velocity)));
		}
		
		if(gB_TimerStatus[client])
		{
			Format(sMessage, 192, "%s %s| Time: %s%s", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], sTime);
		}
		
		if(gI_Jump[target] > 1)
		{
			if(gB_SpeedDiff[client])
			{
				Format(sMessage, 192, "%s %s| Speed Δ: %s%i", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], RoundToFloor(GetVectorLength(velocity)) - RoundToFloor(gF_OldSpeed[target]));
			}

			if(gB_HeightDiff[client])
			{
				Format(sMessage, 192, "%s %s| Height Δ: %s%i", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], RoundToFloor(origin[2]) - RoundToFloor(gF_OldHeight[target]));
			}

			if(gB_GainStats[client])
			{
				Format(sMessage, 192, "%s %s| Gain: %s%.2f%%", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], coeffsum);
			}

			if(gB_StrafeSync[client])
			{
				Format(sMessage, 192, "%s %s| Sync: %s%.2f%%", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], 100.0 * gI_SyncedTick[target] / gI_StrafeTick[target]);
			}

			if(gB_StrafeCount[client])
			{
				Format(sMessage, 192, "%s %s| Strafes: %s%i", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], gI_StrafeCount[target]);
			}
		
			if(gB_Efficiency[client])
			{
				Format(sMessage, 192, "%s %s| Efficiency: %s%.2f%%", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], efficiency);
			}
			
			if(gB_SpeedLoss[client])
			{
				Format(sMessage, 192, "%s %s| Loss: %s%.1f", sMessage, gS_ChatStrings[sMessageText], gS_ChatStrings[sMessageVariable2], gF_SpeedLoss[target]);
			}
		}
		
		Shavit_StopChatSound();
		Shavit_PrintToChat(client, "%s", sMessage);
		if(gB_PrintConsole[client] == true)
		{
			Color_StripFromChatText(sMessage, sMessage, 192);
			PrintToConsole(client, "%s", sMessage);
		}
		
	}
}

void SetCookie(int client, Handle hCookie, int n)
{
	char[] sCookie = new char[8];
	IntToString(n, sCookie, 8);

	SetClientCookie(client, hCookie, sCookie);
}

float GetClientVelocity(int client)
{
	float vVel[3];
	
	vVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	vVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	
	
	return GetVectorLength(vVel);
}

void Color_StripFromChatText(const char[] input, char[] output, int size)
{
	int x = 0;
	for (int i = 0; input[i] != '\0'; i++) {
		
		if (x + 1 == size) {
			break;
		}
		
		int character = input[i];
		
		if (character > 0x08) {
			output[x++] = character;
		}
	}
	
	output[x] = '\0';
}