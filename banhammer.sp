#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <sourcebans>

public Plugin myinfo =
{
	name = "BanHammer",
	author = "KiD Fearless",
	description = "Gives admins the all mighty ban hammer!",
	version = "1.0",
	url = "https://steamcommunity.com/id/kidfearless/"
}

int g_iBanHammer = -1;
int g_iBanLength[MAXPLAYERS + 1] = 0;

public void OnPluginStart()
{
	RegAdminCmd("sm_banhammer", Command_BanHammer, ADMFLAG_RCON, "Equip the ban hammer.");
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_TraceAttack, OnPlayerHurtPre);
}

public Action OnPlayerHurtPre(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	if(g_iBanHammer == -1)
	{
		return Plugin_Continue;
	}
	if(Weapon_GetOwner(g_iBanHammer) != attacker)
	{
		PrintToConsole(attacker, "You are not worthy to hold such power.");
		return Plugin_Continue;
	}

	char weaponName[32];
	GetClientWeapon(attacker, weaponName, sizeof(weaponName));

	if(StrContains(weaponName, "hammer", false) != -1)
	{
		for(int i = 1; i <=MaxClients; ++i)
		{
			if(IsValidClient(i))
			{
				ClientCommand(i, "play weapons/flashbang/flashbang_explode1.wav");
				PrintToChat(i, "THE BAN HAMMER STRIKES AGAIN!");
			}
			ForcePlayerSuicide(victim);
		}
		DataPack data = new DataPack();
		data.WriteCell(attacker);
		data.WriteCell(victim);
		CreateTimer(2.0, DelayedBan, data);
	}
	else
	{
		PrintToConsole(attacker, "Wrong hammer buddy.");
	}

	return Plugin_Continue;
}

public Action DelayedBan(Handle timer, DataPack data)
{
	data.Reset();
	int attacker = data.ReadCell();
	int victim = data.ReadCell();
	delete data;
	SBBanPlayer(attacker, victim, g_iBanLength[attacker], "Ban Hammer Strikes Again!");
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_WeaponDrop, OnWeaponDrop);
	g_iBanLength[client] = 0;
}

public void OnMapEnd()
{
	g_iBanHammer = -1;
}

public Action Command_BanHammer(int client, int args)
{
	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
	g_iBanHammer = GivePlayerItem(client, "weapon_hammer");
	EquipPlayerWeapon(client, g_iBanHammer);
	if(args > 1)
	{
		char arg[32];
		GetCmdArg(1, arg, sizeof(arg));
		g_iBanLength[client] = StringToInt(arg);
	}

	return Plugin_Handled;
}

public void OnWeaponDrop(int client, int weapon)
{
	if(weapon == g_iBanHammer)
	{
		g_iBanHammer = -1;
		SDKUnhook(client, SDKHook_WeaponDrop, OnWeaponDrop);
	}
}

stock int Weapon_GetOwner(int weapon)
{
	return GetEntPropEnt(weapon, Prop_Data, "m_hOwner");
}

stock bool IsValidClient(int client, bool bAlive = false)
{
	return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client) && (!bAlive || IsPlayerAlive(client)));
}

stock bool Client_RemoveWeapon(int client, const char[] className, bool firstOnly=true)
{
	int offset = Client_GetWeaponsOffset(client) - 4;

	for (int i=0; i < 48; i++)
	{
		offset += 4;

		int weapon = GetEntDataEnt2(client, offset);

		if (!IsValidEdict(weapon))
		{
			continue;
		}

		RemovePlayerItem(client, weapon);
	}

	return false;
}