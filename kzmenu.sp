#include <sourcemod>
#include <sdktools>
#undef REQUIRE_PLUGIN
#include <shavit>

// Constants
#define PLUGIN_VERSION	 "1.06"


// Global vars
float originSaves[MAXPLAYERS+1][3];
float angleSaves[MAXPLAYERS+1][3];
float pSpawnVel[3];


// ConVar-stuff
int gBS_Style[MAXPLAYERS+1];
any gA_StyleSettings[STYLE_LIMIT][STYLESETTINGS_SIZE];




public Plugin myinfo = 
{
	name = "SM_CheckpointSaver",
	author = "dataviruset",
	description = "A public checkpoint saving system for bhop/jump/etc servers",
	version = PLUGIN_VERSION,
	url = "http://www.dataviruset.com/"
};


public void OnPluginStart()
{
	// Console commands
	RegConsoleCmd("sm_kzsave", Command_Save, "save");
	RegConsoleCmd("sm_kzcheck", Command_Teleport, "teleport");
	RegConsoleCmd("sm_kzmenu", Command_CPmenu, "kzmenu");
}


public void Shavit_OnStyleConfigLoaded(int styles)
{
	if(styles == -1)
	{
		styles = Shavit_GetStyleCount();
	}

	for(int i = 0; i < styles; i++)
	{
		Shavit_GetStyleSettings(i, gA_StyleSettings[i]);
	}
}


public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle)
{
	gBS_Style[client] = newstyle;
	if (newstyle == 10)
	{
		CPmenu(client);
	}
}


public OnMapEnd()
{
	for(new i = 1; i <= MAXPLAYERS; i++)
	{
		ResetCpSaves(i);
	}
}

/*
public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(sm_cpsaver_enable) == 1)
	{
		new userid = GetEventInt(event, "userid");
	}
}
*/
public PanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


public Action Command_Save(client, args)
{
	if(gBS_Style[client] == 10)
	{
		Save(client);
	}
	return Plugin_Handled;
}

public Action Command_Teleport(client, args)
{
	if(gBS_Style[client] == 10)
	{
		Teleport(client);
	}
	return Plugin_Handled;
}

public Action Command_CPmenu(client, args)
{
	if(gBS_Style[client] == 10)
	{
		CPmenu(client);
	}
	return Plugin_Handled;
}

CPmenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler);
	SetMenuTitle(menu, ":: EXPERIMENTAL KZMENU ::", client);
	
	// Translation formatting
	decl String:CPmenuT1[64];
	Format(CPmenuT1, sizeof(CPmenuT1), "%Save location", client);
	decl String:CPmenuT2[64];
	Format(CPmenuT2, sizeof(CPmenuT2), "Teleport", client);
	AddMenuItem(menu, "cpsave", CPmenuT1);
	AddMenuItem(menu, "cptele", CPmenuT2);
	SetMenuExitButton(menu, true);
	SetMenuOptionFlags(menu, MENUFLAG_NO_SOUND|MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public MenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 0:
			{
				Save(param1);
			}

			case 1:
			{
				Teleport(param1);
			}
		}

		CPmenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

Save(client)
{
	bool bInStart = Shavit_InsideZone(client, Zone_Start, -1);
	bool bInEnd = Shavit_InsideZone(client, Zone_End, -1);
	
	if (gBS_Style[client] == 10)
	{
		if (!(bInStart) && !(bInEnd))
		{
			if (IsPlayerAlive(client))
			{
				if (GetEntityFlags(client)&FL_ONGROUND)
				{
					GetClientAbsOrigin(client, originSaves[client]);
					GetClientEyeAngles(client, angleSaves[client]);
					EmitSoundToClient(client, "buttons/blip1.wav");
				}
				else
				{
					EmitSoundToClient(client, "buttons/button8.wav");
					PrintToChat(client, "[SM] Not On Ground");
				}
			}
			else
			{
				EmitSoundToClient(client, "buttons/button8.wav");
				PrintToChat(client, "[SM] Must Be Alive");
			}
		}
	}
}

Teleport(client)
{
	bool bInStart = Shavit_InsideZone(client, Zone_Start, -1);
	bool bInEnd = Shavit_InsideZone(client, Zone_End, -1);
	
	pSpawnVel[0] = 0.0;
	pSpawnVel[1] = 0.0;
	pSpawnVel[2] = 0.0;	
	
	if (gBS_Style[client] == 10)
	{
		if (IsPlayerAlive(client))
		{
			if (!(bInStart) && !(bInEnd))
			{
				if ( (GetVectorDistance(originSaves[client], NULL_VECTOR) > 0.00) && (GetVectorDistance(angleSaves[client], NULL_VECTOR) > 0.00) )
				{
					TeleportEntity(client, originSaves[client], angleSaves[client], pSpawnVel);
					EmitSoundToClient(client, "buttons/blip1.wav");
				}
				else
				{
					PrintToChat(client, "[SM] No Location Saved");
				}
			}
		}
		else
		{
			EmitSoundToClient(client, "buttons/button8.wav");
			PrintToChat(client, "[SM] Must Be Alive");
		}
	}
}

ResetCpSaves(client)
{
	originSaves[client] = NULL_VECTOR;
	angleSaves[client] = NULL_VECTOR;
}


public void Shavit_OnEnterZone(int client, int type, int track, int id, int entity)
{
	bool bInStart = Shavit_InsideZone(client, Zone_Start, -1);
	bool bInEnd = Shavit_InsideZone(client, Zone_End, -1);
	if(bInStart || bInEnd)
	{
		ResetCpSaves(client);
	}
}



public Native_ClearCheckpoints(Handle:plugin, numParams)
{
	ResetCpSaves(GetNativeCell(1));
}

//(gA_StyleSettings[Shavit_GetBhopStyle(client)][fVelocityLimit] == 380.0)