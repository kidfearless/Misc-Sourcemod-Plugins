// includes
#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#undef REQUIRE_PLUGIN
#include <shavit>


bool gB_Noclipped[MAXPLAYERS+1];
bool gB_RestartBonus[MAXPLAYERS+1];

int gI_Style[MAXPLAYERS+1];

//convars
ConVar gCV_PrespeedLimit = null;

// in OnPluginStart()
public void OnPluginStart()
{
	gCV_PrespeedLimit = CreateConVar("shavit_misc_prespeedlimit", "276.00", "Prespeed limitation in startzone.", 0, true, 10.0, false);

	AddCommandListener(CommandListener_Restart, "sm_r");
	AddCommandListener(CommandListener_Restart, "sm_restart");
	
	
	LoadTranslations("shavit-core.phrases");
	LoadTranslations("shavit-misc.phrases");
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
    if(reason == CSRoundEnd_GameStart)
    {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}
 

public void OnClientConnected(int client)
{
	gB_Noclipped[client] = false;
	gB_RestartBonus[client] = false;
}

public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle)
{
	gI_Style[client] = newstyle;
	gB_Noclipped[client] = false;
}

public void Shavit_OnRestart(int client, int track)
{
	gB_Noclipped[client] = false;
}

public Action Shavit_OnStart(int client, int track)
{
	if (gB_Noclipped[client])
	{
		gB_Noclipped[client] = false;
		Shavit_RestartTimer(client, track);
	}
}

public void Shavit_OnLeaveZone(int client, int type, int track, int id, int entity)
{
	if(type == Zone_Start)
	{
		gB_RestartBonus[client] = (track >= 1);

		if (gB_Noclipped[client])
		{
			Shavit_RestartTimer(client, track);
		}
	}
}

public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style, stylesettings_t stylesettings, int mouse[2])
{
	gB_Noclipped[client] = (view_as<MoveType>(GetEntProp(client, Prop_Data, "m_MoveType")) == MOVETYPE_NOCLIP);
	int flags = GetEntityFlags(client);

	if(gB_Noclipped[client] && stylesettings.bPrespeed)
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
	}

	if(Shavit_InsideZone(client, Zone_Start, track))
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
	
	// prespeed
	if(!gB_Noclipped[client] && !stylesettings.bPrespeed && Shavit_InsideZone(client, Zone_Start, track))
	{
		float speed[3];
		float speed2;
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", speed);
		float speed_New = (SquareRoot(Pow(speed[0], 2.0) + Pow(speed[1], 2.0)));

		if(speed_New < (260.0 +  50.0) || (flags & FL_ONGROUND == FL_ONGROUND))
		{
			float fScale = (gCV_PrespeedLimit.FloatValue / speed_New);

			speed2 = speed[2];
			speed[2] = 0.0;
			if(fScale < 1.0)
			{
				ScaleVector(speed, fScale);
			}
			speed[2] = speed2;
			if(gB_Noclipped[client])
			{
				speed[2] = 0.0;
			}
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, speed);
		}
	}

	return Plugin_Continue;
}

public Action CommandListener_Restart(int client, const char[] command, int args)
{
	if(!IsValidClient(client, true))
	{
		return Plugin_Handled;
	}
	
	if(gB_RestartBonus[client])
	{
		Shavit_RestartTimer(client, Track_Bonus);
		
		return Plugin_Stop;
	}

	return Plugin_Handled;
}

public Action Shavit_OnSave(int client)
{
	stylesettings_t stylesettings;
	Shavit_GetStyleSettings(gI_Style[client], stylesettings);

	if (stylesettings.bPrespeed)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}