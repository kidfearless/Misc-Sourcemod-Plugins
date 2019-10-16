/*  SM Barrearmas
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdktools>

#pragma semicolon 1

public Plugin myinfo = 
{
	name = "SM Barrearmas",
	author = "Franc1sco steam: franug",
	description = "Keeps the map clean of weapons lost",
	version = "1.0",
	url = "http://steamcommunity.com/id/franug"
}


int g_WeaponParent;
Handle Cvar_Timer;

public void OnPluginStart()
{
	g_WeaponParent = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");
}

public void OnMapStart()
{
	Cvar_Timer = CreateTimer(15.0, Timer_Repeat, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapEnd()
{
	delete Cvar_Timer;
}

public Action Timer_Repeat(Handle timer)
{
	int maxent = GetMaxEntities();
	char weapon[64];

	for (int i = MaxClients; i < maxent; i++)
	{
		if ( IsValidEdict(i) && IsValidEntity(i) )
		{
			GetEdictClassname(i, weapon, sizeof(weapon));
			if ( ( StrContains(weapon, "weapon_") != -1 || StrContains(weapon, "item_") != -1 ) && GetEntDataEnt2(i, g_WeaponParent) == -1 ) 
				RemoveEdict(i);
		}
	}

	return Plugin_Continue;
}

