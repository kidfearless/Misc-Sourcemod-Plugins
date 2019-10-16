#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <shavit>
#include <smlib/arrays>
#define INTWS (IN_FORWARD|IN_BACK)
#define INTAD (IN_MOVELEFT|IN_MOVERIGHT)

enum PlayerState
{
	nStrafes, // Count strafes
	nStrafeDir,
}

int g_prevbuttons[MAXPLAYERS+1];
int g_totlws[MAXPLAYERS+1];
int g_totlad[MAXPLAYERS+1];
int g_perfws[MAXPLAYERS+1];
int g_perfad[MAXPLAYERS+1];
int g_holdtime[MAXPLAYERS+1];
new g_PlayerStates[MAXPLAYERS + 1][PlayerState];
float vLastOrigin[MAXPLAYERS + 1][3];
float vLastAngles[MAXPLAYERS + 1][3];
float vLastVelocity[MAXPLAYERS + 1][3];


public Plugin myinfo = 
{
	name = "StrafeStat",
	author = "l2zq",
	description = "Figure out null users",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_strafecheck", Cmd_StrafeCheck);
	RegConsoleCmd("sm_strafeclear", Cmd_StrafeClear);
}


public void Shavit_OnRestart(int client)
{
	if(IsValidClient(client))
	{
		g_prevbuttons[client] = 0;
		g_perfws[client] = 0;
		g_perfad[client] = 0
		g_totlws[client] = 0;
		g_totlad[client] = 0;
		g_holdtime[client] = 0;
		g_PlayerStates[client][nStrafeDir] = 0;
		g_PlayerStates[client][nStrafes] = 0;
	}
}

public void OnClientPutInServer(int client)
{
	if(IsValidClient(client))
	{
		g_prevbuttons[client] = 0;
		g_perfws[client] = 0;
		g_perfad[client] = 0
		g_totlws[client] = 0;
		g_totlad[client] = 0;
		g_holdtime[client] = 0;
		g_PlayerStates[client][nStrafeDir] = 0;
		g_PlayerStates[client][nStrafes] = 0;
	}
}

public Action Cmd_StrafeCheck(int client, int iArgs)
{
	if(iArgs != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_strafecheck <#userid|name|@all>");
		return Plugin_Handled;
	}
	char sArg[65];
	GetCmdArg(1, sArg, sizeof(sArg));

	char sTargetName[MAX_TARGET_LENGTH];
	int a_iTargets[MAXPLAYERS], iTargetCount;
	bool bTN_Is_ML;
	if((iTargetCount = ProcessTargetString(sArg, client, a_iTargets, MAXPLAYERS, COMMAND_FILTER_NO_IMMUNITY, sTargetName, sizeof(sTargetName), bTN_Is_ML)) <= 0)
	{
		ReplyToCommand(client, "[SM] Not found or invalid parameter.");
		return Plugin_Handled;
	}
	for(int i = 0; i < iTargetCount; i++)
	{
		int target = a_iTargets[i];
		if(IsValidClient(target))
		{
			char name[128] = "N/A";
			GetClientName(target, name, sizeof(name));
			float wsrate = g_perfws[target]*100.0/g_totlws[target];
			float adrate = g_perfad[target]*100.0/g_totlad[target];
			float holdtime = (g_holdtime[target]*1.0)/(g_PlayerStates[target][nStrafes]);
			ReplyToCommand(client, "[SM] %N WS:%.2f% AD:%.2f% HOLD AVG:%.2f, HOLDALL:%i, STRAFES:%i", target, wsrate, adrate, holdtime, g_holdtime[target], g_PlayerStates[target][nStrafes]);
		}
	}
	/*
	int n;
	for(n=1;n<MAXPLAYERS;n++){
		if(IsClientInGame(n)){
			char name[128] = "N/A";
			GetClientName(n, name, sizeof(name));
			float wsrate = g_perfws[n]*100.0/g_totlws[n];
			float adrate = g_perfad[n]*100.0/g_totlad[n];
			float holdtime = (g_holdtime[n]*1.0)/(Shavit_GetStrafeCount(n));
			ReplyToCommand(client, "[SM] %s(%d) WS:%.2f% AD:%.2f% HOLD AVG:%.2f, HOLDALL:%i, STRAFES:%i", name, n, wsrate, adrate, holdtime, g_holdtime[n], Shavit_GetStrafeCount(n));
		}
	}
	*/
	return Plugin_Handled;
}

public Action Cmd_StrafeClear(int client, int iArgs)
{
	if(iArgs != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_strafeclear <#userid|name|@all>");
		return Plugin_Handled;
	}
	char sArg[65];
	GetCmdArg(1, sArg, sizeof(sArg));

	char sTargetName[MAX_TARGET_LENGTH];
	int a_iTargets[MAXPLAYERS], iTargetCount;
	bool bTN_Is_ML;

	if((iTargetCount = ProcessTargetString(sArg, client, a_iTargets, MAXPLAYERS, COMMAND_FILTER_NO_IMMUNITY, sTargetName, sizeof(sTargetName), bTN_Is_ML)) <= 0)
	{
		ReplyToCommand(client, "[SM] Not found or invalid parameter.");
		return Plugin_Handled;
	}
	
	for(int i = 0; i < iTargetCount; i++)
	{
		int target = a_iTargets[i];
		if(IsValidClient(target))
		{
			ResetJumps(target);
			ReplyToCommand(client, "[SM] Strafe stats are now reset for player %N.", target);
		}
	}
	return Plugin_Handled;
}

void ResetJumps(int target)
{
	for(int i = 0; i < MAXPLAYERS; i++)
	{
		g_prevbuttons[target] = 0;
		g_perfws[target] = 0;
		g_perfad[target] = 0
		g_totlws[target] = 0;
		g_totlad[target] = 0;
		g_holdtime[target] = 0;
		g_PlayerStates[target][nStrafeDir] = 0;
		g_PlayerStates[target][nStrafes] = 0;
	}
}


public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style, any stylesettings[STYLESETTINGS_SIZE])
{
	char sSpecial[128];
	Shavit_GetStyleStrings(style, sSpecialString, sSpecial, 128);

	if(StrContains(sSpecial, "autostrafe", false) != -1)
	{
		return Plugin_Continue;
	}


	int ws = buttons&INTWS, prevws = g_prevbuttons[client]&INTWS;
	int ad = buttons&INTAD, prevad = g_prevbuttons[client]&INTAD;
	g_prevbuttons[client] = buttons;

	bool newstrafe = false;
	
	new nButtonCount;
	if((buttons & IN_MOVELEFT) && !(GetEntityFlags(client) & FL_ONGROUND))
		nButtonCount++;
	if((buttons & IN_MOVERIGHT) && !(GetEntityFlags(client) & FL_ONGROUND))
		nButtonCount++;
	/*if((buttons & IN_FORWARD) && !(GetEntityFlags(client) & FL_ONGROUND))
		nButtonCount++;
	if((buttons & IN_BACK) && !(GetEntityFlags(client) & FL_ONGROUND))
		nButtonCount++;
	*/
	if(nButtonCount == 1)
	{
		if(g_PlayerStates[client][nStrafeDir] != 1 && (buttons & IN_MOVELEFT || vel[1] < 0))
		{
			g_PlayerStates[client][nStrafeDir] = 1;
			newstrafe = true;
		}
		else if(g_PlayerStates[client][nStrafeDir] != 2 && (buttons & IN_MOVERIGHT || vel[1] > 0))
		{
			g_PlayerStates[client][nStrafeDir] = 2;
			newstrafe = true;
		}
	}
	
	if(newstrafe)
	{
		g_PlayerStates[client][nStrafes]++;
	}



	
	if((ws!=prevws)&&ws&&prevws){
		g_totlws[client]++;
		if((ws==IN_FORWARD&&prevws==IN_BACK)||(prevws==IN_FORWARD&&ws==IN_BACK))
			g_perfws[client]++;
	}
	if((ad!=prevad)&&ad&&prevad){
		g_totlad[client]++;
		if((ad==IN_MOVELEFT&&prevad==IN_MOVERIGHT)||(prevad==IN_MOVELEFT&&ad==IN_MOVERIGHT))
			g_perfad[client]++;
	}
	
	if((buttons&IN_MOVELEFT && buttons&IN_MOVERIGHT) && (!(GetEntityFlags(client) & FL_ONGROUND) || buttons&IN_JUMP))
	{
		g_holdtime[client]++;
	}

	return Plugin_Continue;
}


/*

	
	// Reset stuff
	g_PlayerStates[client][nStrafeDir] = 0;
	g_PlayerStates[client][nStrafes] = 0;
}
*/