#pragma semicolon 1
#define PLUGIN_VERSION "1.9.3.1"
#define TAG "[TOGs Jump Stats] "
#define CSGO_RED "\x07"

#include <sourcemod>
#include <morecolors>
#include <sdktools>
#include <autoexecconfig>
#include <sourcebans>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Simple Jump Stats",
	author = "That One Guy (based on code from Inami)",
	description = "Player bhop method analysis.",
	version = PLUGIN_VERSION,
	url = "http://www.togcoding.com"
}

ConVar g_hHacksPerf = null;

float ga_fAvgJumps[MAXPLAYERS + 1] = {1.0, ...};
float ga_fAvgPerfJumps[MAXPLAYERS + 1] = {0.3333, ...};

bool ga_bFlagged[MAXPLAYERS + 1];

char g_sHacksPath[PLATFORM_MAX_PATH];

int ga_iJumps[MAXPLAYERS + 1] = {0, ...};
int ga_iLastPos[MAXPLAYERS + 1] = {0, ...};
int gaa_iLastJumps[MAXPLAYERS + 1][30];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	
	AutoExecConfig_SetFile("togsjumpstats");
	AutoExecConfig_CreateConVar("tjs_version", PLUGIN_VERSION, "TOGs Jump Stats Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	g_hHacksPerf = AutoExecConfig_CreateConVar("tjs_hacks_perf", "0.9", "Above this perf ratio (ratios range between 0.0 - 1.0), players will be flagged for hacks.", FCVAR_NONE, true, 0.0, true, 1.0);

	HookEvent("player_jump", Event_PlayerJump, EventHookMode_Post);
	
	RegConsoleCmd("sm_jumps", Command_Jumps, "Gives statistics for player jumps.");
	RegAdminCmd("sm_resetjumps", Command_ResetJumps, ADMFLAG_BAN, "Reset statistics for a player.");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	for(int i = 1; i <= MaxClients; i++)	//late load handler
	{
		if(IsValidClient(i))
		{
			ResetJumps(i);
		}
	}
	
	char sBuffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "logs/togsjumpstats/");
	if(!DirExists(sBuffer))
	{
		CreateDirectory(sBuffer, 511);
	}

	BuildPath(Path_SM, g_sHacksPath, sizeof(g_sHacksPath), "logs/togsjumpstats/hacks.log");
}

public void OnClientConnected(int client)
{
	ResetJumps(client);
}

public void OnClientPostAdminCheck(int client)
{
	if(CheckCommandAccess(client, "sm_kick", ADMFLAG_KICK, false))
	{
		CreateTimer(30.0, Timer_PrintFlaggedPlayers, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_PrintFlaggedPlayers(Handle hTimer, any iUserID)
{
	int client = GetClientOfUserId(iUserID);
	int iCount = 0;
	if(IsValidClient(client))
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i))
			{
				if(ga_bFlagged[i])
				{
					iCount++;
				}
			}
		}
		if(iCount > 0)
		{
			PrintToChat(client, "%s%s%i players have been flagged for jump stats! Please check everyone's stats!", TAG, CSGO_RED, iCount);
		}
	}
}

public void Event_PlayerJump(Handle hEvent, const char[] sName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if(!IsValidClient(client))
	{
		return;
	}
	
	ga_fAvgJumps[client] = (ga_fAvgJumps[client] * 9.0 + float(ga_iJumps[client])) / 10.0;
	
	gaa_iLastJumps[client][ga_iLastPos[client]] = ga_iJumps[client];
	ga_iLastPos[client]++;
	if(ga_iLastPos[client] == 30)
	{
		ga_iLastPos[client] = 0;
	}

	ga_iJumps[client] = 0;
	
	if(ga_fAvgPerfJumps[client] >= g_hHacksPerf.FloatValue)
	{
		NotifyAdmins(client, "Hacks");
		LogFlag(client, "hacks", ga_bFlagged[client]);
	}
}

void NotifyAdmins(int client, char[] sFlagType)
{
	if(IsValidClient(client))
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i) && CheckCommandAccess(i, "sm_kick", ADMFLAG_KICK, true))
			{
				CPrintToChat(i, "%s%s'%N' has been flagged for '%s'! Please check their jump stats!", TAG, CSGO_RED, client, sFlagType);
				PerformStats(i, client);
			}
		}
	}
}

public void OnClientDisconnect(int client)
{
	ResetJumps(client);
}

void LogFlag(int client, const char[] sType, bool bAlreadyFlagged = false)
{
	if(IsValidClient(client))
	{
		char sStats[256];
		GetClientStats(client, sStats, sizeof(sStats));

		if(StrEqual(sType, "hacks", false))
		{
			LogToFileEx(g_sHacksPath, "%s %s%s", sStats, sType, (bAlreadyFlagged ? " (already flagged this map)" : ""));
		}
		
		ga_bFlagged[client] = true;
		SBBanPlayer(0, client, 0, "BhopHacks");
	}
}

public Action Command_Jumps(int client, int iArgs)
{
	if(iArgs != 1)
	{
		ReplyToCommand(client, "%sUsage: sm_jumps <#userid|name|@all>", TAG);
		return Plugin_Handled;
	}
	
	char sArg[65];
	GetCmdArg(1, sArg, sizeof(sArg));

	char sTargetName[MAX_TARGET_LENGTH];
	int a_iTargets[MAXPLAYERS], iTargetCount;
	bool bTN_Is_ML;

	if((iTargetCount = ProcessTargetString(sArg, client, a_iTargets, MAXPLAYERS, COMMAND_FILTER_NO_IMMUNITY, sTargetName, sizeof(sTargetName), bTN_Is_ML)) <= 0)
	{
		ReplyToCommand(client, "Not found or invalid parameter.");
		return Plugin_Handled;
	}

	SortedStats(client, a_iTargets, iTargetCount);
	
	if(IsValidClient(client))
	{
		ReplyToCommand(client, "%sCheck console for output!", TAG);
	}

	return Plugin_Handled;
}

public Action Command_ResetJumps(int client, int iArgs)
{
	if(iArgs != 1)
	{
		ReplyToCommand(client, "%sUsage: sm_resetjumps <#userid|name|@all>", TAG);
		return Plugin_Handled;
	}
	
	char sArg[65];
	GetCmdArg(1, sArg, sizeof(sArg));

	char sTargetName[MAX_TARGET_LENGTH];
	int a_iTargets[MAXPLAYERS], iTargetCount;
	bool bTN_Is_ML;

	if((iTargetCount = ProcessTargetString(sArg, client, a_iTargets, MAXPLAYERS, COMMAND_FILTER_NO_IMMUNITY, sTargetName, sizeof(sTargetName), bTN_Is_ML)) <= 0)
	{
		ReplyToCommand(client, "Not found or invalid parameter.");
		return Plugin_Handled;
	}
	
	for(int i = 0; i < iTargetCount; i++)
	{
		int target = a_iTargets[i];
		if(IsValidClient(target))
		{
			ResetJumps(target);
			ReplyToCommand(client, "%sStats are now reset for player %N.", TAG, target);
		}
	}

	return Plugin_Handled;
}

void ResetJumps(int target)
{
	ga_iJumps[target] = 0;
	ga_fAvgJumps[target] = 5.0;
	ga_fAvgPerfJumps[target] = 0.3333;
	ga_bFlagged[target] = false;
	int i;
	while(i < 30)
	{
		gaa_iLastJumps[target][i] = 0;
		i++;
	}
}

void PerformStats(int client, int target)
{
	char sStats[300];
	GetClientStats(target, sStats, sizeof(sStats));
	if(IsValidClient(client))
	{
		PrintToConsole(client, "Flagged: %i || %s", ga_bFlagged[target], sStats);
	}
	else
	{
		PrintToServer("Flagged: %i || %s", ga_bFlagged[target], sStats);
	}
}

void SortedStats(int client, int[] a_iTargets, int iCount)
{
	float[][] a_fPerfs = new float[iCount][2];
	int iValidCount = 0;
	for(int i = 0; i < iCount; i++)
	{
		if(IsValidClient(a_iTargets[i]))
		{
			a_fPerfs[i][0] = ga_fAvgPerfJumps[a_iTargets[i]] * 1000;
			iValidCount++;
		}
		else
		{
			a_fPerfs[i][0] = -1.0;
		}
		a_fPerfs[i][1] = float(a_iTargets[i]);
	}
	
	SortCustom2D(a_fPerfs, iCount, SortPerfs); 
	
	char[][] a_sStats = new char[iValidCount][300];
	int k = 0;
	char sMsg[300];
	for(int j = 0; j < iCount; j++)
	{
		int target = RoundFloat(a_fPerfs[j][1]);
		if(IsValidClient(target) && (a_fPerfs[j][0] != -1.0))
		{
			//save to another array to display them in order, since the get stats takes time and therefor they can sometimes come out of order slightly
			char sStats[300];
			GetClientStats(target, sStats, sizeof(sStats));
			Format(sMsg, sizeof(sMsg), "Flagged: %d || %s", ga_bFlagged[target], sStats);
			strcopy(a_sStats[k], 300, sMsg);
			k++;
		}
	}
	
	if(IsValidClient(client))
	{
		for(int m = 0; m < iValidCount; m++)
		{
			PrintToConsole(client, a_sStats[m]);
		}
	}
	else
	{
		for(int m = 0; m < iValidCount; m++)
		{
			PrintToServer(a_sStats[m]);
		}
	}
	
}

public int SortPerfs(int[] x, int[] y, const int[][] aArray, Handle hHndl) 
{ 
    if(view_as<float>(x[0]) > view_as<float>(y[0])) 
	{
        return -1;
	}
    return view_as<float>(x[0]) < view_as<float>(y[0]); 
} 

void GetClientStats(int client, char[] sStats, int iLength)
{
	Format(sStats, iLength, "Perf: %4.1f%% || Avg: %-4.1f || %L || Last: ", ga_fAvgPerfJumps[client]*100.0, ga_fAvgJumps[client], client);

	Format(sStats, iLength, "%s%i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i", sStats, 
		gaa_iLastJumps[client][0], gaa_iLastJumps[client][1], gaa_iLastJumps[client][2], gaa_iLastJumps[client][3], gaa_iLastJumps[client][4], gaa_iLastJumps[client][5],
		gaa_iLastJumps[client][6], gaa_iLastJumps[client][7], gaa_iLastJumps[client][8], gaa_iLastJumps[client][9], gaa_iLastJumps[client][10], gaa_iLastJumps[client][11],
		gaa_iLastJumps[client][12], gaa_iLastJumps[client][13], gaa_iLastJumps[client][14], gaa_iLastJumps[client][15], gaa_iLastJumps[client][16], gaa_iLastJumps[client][17],
		gaa_iLastJumps[client][18], gaa_iLastJumps[client][19], gaa_iLastJumps[client][20], gaa_iLastJumps[client][21], gaa_iLastJumps[client][22], gaa_iLastJumps[client][23],
		gaa_iLastJumps[client][24], gaa_iLastJumps[client][25], gaa_iLastJumps[client][26], gaa_iLastJumps[client][27], gaa_iLastJumps[client][28], gaa_iLastJumps[client][29]);
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if(IsPlayerAlive(client))
	{
		static bool bHoldingJump[MAXPLAYERS + 1];
		static bLastOnGround[MAXPLAYERS + 1];
		bool bOnGround = ((GetEntityFlags(client) & FL_ONGROUND) == FL_ONGROUND);

		if(buttons & IN_JUMP == IN_JUMP)
		{
			if(!bHoldingJump[client])
			{
				bHoldingJump[client] = true;//started pressing +jump
				ga_iJumps[client]++;
				if(bLastOnGround[client] && bOnGround)
				{
					ga_fAvgPerfJumps[client] = (ga_fAvgPerfJumps[client] * 9.0 + 0) / 10.0;
				}
				else if(!bLastOnGround[client] && bOnGround)
				{
					ga_fAvgPerfJumps[client] = (ga_fAvgPerfJumps[client] * 9.0 + 1) / 10.0;
				}
			}
		}
		else if(bHoldingJump[client]) 
		{
			bHoldingJump[client] = false;//released (-jump)
		}
		bLastOnGround[client] = bOnGround;
	}
	
	return Plugin_Continue;
}

stock bool IsValidClient(int client, bool bAllowBots = false)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client))
	{
		return false;
	}
	return true;
}