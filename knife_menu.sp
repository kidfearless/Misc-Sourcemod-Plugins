#include <sourcemod>
#include <cstrike>
#include <smlib>

Menu KnifeMenu = null;

public Plugin myinfo =
{
	name = "Knife Menu",
	author = "KiD Fearless",
	description = "Knife Menu For Donators",
	version = "1.0",
	url = "https://steamcommunity.com/id/kidfearless/"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_knifes", Command_Knives, ADMFLAG_CUSTOM6);
	RegAdminCmd("sm_knives", Command_Knives, ADMFLAG_CUSTOM6);
	RegAdminCmd("sm_knifemenu", Command_Knives, ADMFLAG_CUSTOM6);

	KnifeMenu = new Menu(KnifeMenuCallback);
	KnifeMenu.SetTitle("Knife Menu");

	KnifeMenu.AddItem("weapon_fists","weapon_fists");
	KnifeMenu.AddItem("weapon_axe","weapon_axe");
	KnifeMenu.AddItem("weapon_spanner","weapon_spanner");
	KnifeMenu.AddItem("weapon_hammer","weapon_hammer");
	KnifeMenu.AddItem("weapon_melee","weapon_melee");
	KnifeMenu.AddItem("weapon_tablet","weapon_tablet");
}

public Action Command_Knives(int client, int args)
{
	KnifeMenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int KnifeMenuCallback(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select)
	{
		char weapon[32];
		menu.GetItem(param2, weapon, sizeof(weapon));

		Client_RemoveWeapon(param1, weapon);
		int index = GivePlayerItem(param1, weapon);
		EquipPlayerWeapon(param1, index);
	}
}