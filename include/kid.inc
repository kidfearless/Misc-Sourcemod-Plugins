#if defined _kid
#endinput
#endif
#define _kid

int KiD;
int Romaa;

public void OnClientPostAdminFilter(int client)
{
	if(IsClientValid(client))
	{
		if(IsClientFearless(client))
		{
			KiD = client;
		}
		if(IsClientRomaa(client))
		{
			Romaa = client;
		}
	}
}

stock bool IsClientFearless(int client)
{
	char authid[20];
	GetClientAuthId(client, AuthId_SteamID64, authid, sizeof(authid));
	return StrEqual(authid, "76561198020000383", false);
}

stock bool IsClientRomaa(int client)
{
	char authid[20];
	GetClientAuthId(client, AuthId_SteamID64, authid, sizeof(authid));
	return StrEqual(authid, "76561198180672935", false);
}

stock bool IsClientDaniel(int client)
{
	char authid[20];
	GetClientAuthId(client, AuthId_SteamID64, authid, sizeof(authid));
	return StrEqual(authid, "76561198433810299", false);
}

stock bool IsClientValid(int client, bool bAlive = false)
{
	return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client) && !IsFakeClient(client) && !IsClientReplay (client) && (!bAlive || IsPlayerAlive(client)));
}

stock void FindKiD()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientValid(client))
		{
			if(IsClientFearless(client))
			{
				KiD = client;
			}
		}
	}
}

stock void FindRomaa()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientValid(client))
		{
			if(IsClientRomaa(client))
			{
				Romaa = client;
			}
		}
	}
}

