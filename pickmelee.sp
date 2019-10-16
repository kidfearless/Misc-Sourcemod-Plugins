#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME           "PickAll"
#define PLUGIN_VERSION        "1.0"

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "Hexah",
	description = "Allows player to pickup new melee weapons",
	version = PLUGIN_VERSION,
	url = "github.com/Hexer10"
};

public void OnPluginStart()
{
	//Lateload
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) OnClientPutInServer(i);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, Hook_WeaponCanUse);
}

public Action Hook_WeaponCanUse(int client, int weapon)
{
	char classname[64];
	GetEntityClassname(weapon, classname, sizeof classname);
	
	if (StrEqual(classname, "weapon_melee") && !(HasWeapon(client, "weapon_melee") || HasWeapon(client, "weapon_knife")))
		EquipPlayerWeapon(client, weapon);
}

stock bool HasWeapon(int client, const char[] classname)
{
	int index;
	int weapon;
	char sName[64];
	
	while((weapon = GetNextWeapon(client, index)) != -1)
	{
		GetEdictClassname(weapon, sName, sizeof(sName));
		if (StrEqual(sName, classname))
			return true;
	}
	return false;
}

stock int GetNextWeapon(int client, int &weaponIndex)
{
	static int weaponsOffset = -1;
	if (weaponsOffset == -1)
		weaponsOffset = FindDataMapInfo(client, "m_hMyWeapons");
	
	int offset = weaponsOffset + (weaponIndex * 4);
	
	int weapon;
	while (weaponIndex < 48) 
	{
		weaponIndex++;
		
		weapon = GetEntDataEnt2(client, offset);
		
		if (IsValidEdict(weapon)) 
			return weapon;
		
		offset += 4;
	}
	
	return -1;
}