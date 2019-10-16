#pragma semicolon 1
#pragma newdecls required

#include <cstrike>
#include <sdkhooks>
#include <sdktools>


int PrimaryChoice[MAXPLAYERS+1],
	SecondaryChoice[MAXPLAYERS+1],
	iSizePrimaryMenu,
	iSizeSecondaryMenu;
Menu g_PrimaryMenu,
	g_SecondaryMenu;

char sPrimaryWeapons[][] = {
		"",
		"weapon_awp",
		"weapon_negev",
		"weapon_m249",
		"weapon_ssg08",
		"weapon_ak47",
		"weapon_m4a1",
		"weapon_m4a1_silencer",
		"weapon_sg556",
		"weapon_aug",
		"weapon_galilar",
		"weapon_famas",
		"weapon_mac10",
		"weapon_mp9",
		"weapon_mp7",
		"weapon_ump45",
		"weapon_bizon",
		"weapon_p90"},
	sPrimaryWeaponNames[][] = {
		"None",
		"AWP",
		"Negev",
		"M249",
		"SSG 08",
		"AK-47",
		"M4A4",
		"M4A1-S",
		"Sig 553",
		"Aug",
		"Galil AR",
		"Famas",
		"Mac-10",
		"MP9",
		"MP7",
		"UMP-45",
		"Bizon",
		"P90"},
	sSecondaryWeapons[][] = {
		"",
		"weapon_glock",
		"weapon_usp_silencer",
		"weapon_hkp2000",
		"weapon_p250",
		"weapon_deagle",
		"weapon_fiveseven",
		"weapon_elite",
		"weapon_tec9",
		"weapon_cz75a",
		"weapon_revolver"},
	sSecondaryWeaponNames[][] = {
		"None",
		"Glock-18",
		"USP-S",
		"P2000",
		"P250",
		"Desert Eagle",
		"Five-SeveN",
		"Dual Berettas",
		"Tec-9",
		"CZ75-Auto",
		"R8 Revolver"};

public Plugin myinfo =
{
	name		= "Gun Menu",
	author		= "Potatoz (rewritten by Grey83)",
	description	= "Gun Menu for gamemodes such as Retake, Deathmatch etc.",
	version		= "1.0.3",
	url			= "https://forums.alliedmods.net/showthread.php?t=294225"
};

public void OnPluginStart()
{
	int iWeapons = sizeof(sPrimaryWeapons);
	int iNames = sizeof(sPrimaryWeaponNames);
	iSizePrimaryMenu = iWeapons > iNames ? iNames : iWeapons;
	iWeapons = sizeof(sSecondaryWeapons);
	iNames = sizeof(sSecondaryWeaponNames);
	iSizeSecondaryMenu = iWeapons > iNames ? iNames : iWeapons;

	g_PrimaryMenu	= BuildPrimaryMenu();
	g_SecondaryMenu	= BuildSecondaryMenu();

	RegConsoleCmd("sm_guns", Menu_PrimaryWeapon);

}

Menu BuildPrimaryMenu()
{
	char buffer[PLATFORM_MAX_PATH];
	Menu menu = new Menu(MenuHandler1);

	menu.SetTitle("Choose Primary Weapon:");
	for(int i; i < iSizePrimaryMenu; i++)
	{
		IntToString(i, buffer, sizeof(buffer));
		menu.AddItem(buffer, sPrimaryWeaponNames[i]);
	}

	return menu;
}

public Action Menu_PrimaryWeapon(int client, int args)
{
	if(!CheckCommandAccess(client, "shavit_chat", ADMFLAG_CHAT))
	{
		return Plugin_Handled;
	}
	
	g_PrimaryMenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int MenuHandler1(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select)
	{
		char item[4];
		menu.GetItem(param2, item, sizeof(item));
		PrimaryChoice[param1] = StringToInt(item);

		g_SecondaryMenu.Display(param1, MENU_TIME_FOREVER);
	}
}

Menu BuildSecondaryMenu()
{
	char buffer[PLATFORM_MAX_PATH];
	Menu menu = new Menu(MenuHandler2);

	menu.SetTitle("Choose Secondary Weapon:");
	for(int i; i < iSizeSecondaryMenu; i++)
	{
		IntToString(i, buffer, sizeof(buffer));
		menu.AddItem(buffer, sSecondaryWeaponNames[i]);
	}

	return menu;
}

public Action Menu_SecondaryWeapon(int client, int args)
{
	g_SecondaryMenu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public int MenuHandler2(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select) 
	{
		char item[4];
		menu.GetItem(param2, item, sizeof(item));
		SecondaryChoice[param1] = StringToInt(item);
		GiveEquipment(param1);
	}
	else
	{
		GiveEquipment(param1);
	}
}

public void OnClientPutInServer(int client)
{
	PrimaryChoice[client] = SecondaryChoice[client] = 0;
	SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
}

public void Hook_PostThinkPost(int entity)
{
	SetEntProp(entity, Prop_Send, "m_bInBuyZone", 0);
}

public void GiveEquipment(int client)
{
	if(IsValidClient(client))
	{
		int iWeapon;
		RemoveAllWeapons(client);
		iWeapon = PrimaryChoice[client];

		GivePlayerItem(client, sPrimaryWeapons[iWeapon]);
		FakeClientCommand(client, "use %s", sPrimaryWeapons[iWeapon]);

		iWeapon = SecondaryChoice[client];
		GivePlayerItem(client, sSecondaryWeapons[iWeapon]);
		FakeClientCommand(client, "use %s", sSecondaryWeapons[iWeapon]);
	}
}

void RemoveAllWeapons(int client)
{
	if(IsValidClient(client))
	{
		int ent;
		for(int i; i < 4; i++)
		{
			if((ent = GetPlayerWeaponSlot(client, i)) != -1)
			{
				RemovePlayerItem(client, ent);
				RemoveEdict(ent);
			}
		}
	}
}

bool IsValidClient(int client)
{
	return (0 < client <= MaxClients && IsPlayerAlive(client));
}