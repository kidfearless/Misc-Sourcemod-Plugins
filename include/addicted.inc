#if defined _ADDICTINCLUDE_included
 #endinput
#endif
#define _ADDICTINCLUDE_included

#include <colors_csgo>
#include <cstrike>

#define CHAT_TAG "[{blue}∂G{default}] "

#define LoopValidPlayers(%1) for(int %1; %1 < MaxClients; %1++)\
								if(IsValidClient(%1))

#define LoopAlivePlayers(%1) for(int %1; %1 < MaxClients; %1++)\
								if(IsValidClient(%1) && IsPlayerAlive(%1))

#define STRING(%1) %1, sizeof(%1)

stock bool IsValidClient(int client)
{
	if (client < 1 || client > MaxClients)
		return false;
	if (!IsClientConnected(client))
		return false;
	if (!IsClientInGame(client))
		return false;
	if (IsFakeClient(client))
		return false;
	if (IsClientSourceTV(client))
		return false;

	return true;
}

stock int GetClientFromSteam(char[] steamid)
{
	char client_steamid[32];
	
	LoopValidPlayers(i)
	{
		GetClientAuthId(i, AuthId_Engine, STRING(client_steamid));

		if (StrEqual(steamid, authid))
			return i;
	}

	return 0;
}

stock int GetClientFromIP(char[] ip)
{
	char client_ip[16];
	
	LoopValidPlayers(i)
	{
		GetClientIP(i, STRING(client_steamid));
		
		if (StrEqual(ip, client_ip))
			return i;
	}

	return 0;
}

stock bool ClientHasFlag(client, flag)
{
	int flags = GetUserFlagBits(client);

	if(flag == 0 || flags & flag || flags & ADMFLAG_ROOT)
		return true;

	return false;
}

public void CreateCountdown(int client, int seconds, char[] format)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, GetClientUserId(client));
	WritePackCell(pack, seconds);
	WritePackString(pack, format);
	ResetPack(pack);

	CreateTimer(0.0, Timer_Countdown, pack);
}

public void CreateCountdownAll(int seconds, char[] format)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, 0);
	WritePackCell(pack, seconds);
	WritePackString(pack, format);
	ResetPack(pack);

	CreateTimer(0.0, Timer_Countdown, pack);
}

public Action Timer_Countdown(Handle timer, any pack)
{
	int userid = ReadPackCell(pack), client;
	
	if(userid != 0)
		if(!IsValidClient(GetClientOfUserId(userid)))
		{
			CloseHandle(pack);
			return Plugin_Stop;
		}

	int seconds = ReadPackCell(pack);
	char format[192];
	ReadPackString(pack, format, sizeof(format));

	if(userid != 0)
		PrintCenterText(client, "%i seconds until %s", seconds, format);
	else
		PrintCenterTextAll("%i seconds until %s", seconds, format);

	if(seconds != 1)
	{
		ResetPack(pack);
		ReadPackCell(pack);
		WritePackCell(pack, seconds-1);
		ResetPack(pack);

		CreateTimer(1.0, Timer_Countdown, pack);
	}
	else
		CloseHandle(pack);

	return Plugin_Stop;
}

stock void ConvertSteamID(char[] steamid, int len)
{
	ReplaceString(steamid, len, "STEAM_1:", "STEAM_0:", false);
}

stock void PrintToChatAndConsole(int client, const char[] szFormat, any ...)
{
	char szBuffer[256];
	VFormat(STRING(szBuffer), szFormat, 3);
	
	CPrintToChat(client, szBuffer);
	
	CRemoveTags(STRING(szBuffer)); // Remove color tags for console print
	PrintToConsole(client, szBuffer);
}

stock void PrintToChatAndConsoleAll(const char[] szFormat, any ...)
{
	char szBuffer[256];
	VFormat(STRING(szBuffer), szFormat, 3);
	
	LoopValidPlayers(i)
	{
		CPrintToChat(i, szBuffer);
		
		CRemoveTags(STRING(szBuffer)); // Remove color tags for console print
		PrintToConsole(i, szBuffer);
	}
}