#include <sourcemod>

bool gB_Enabled[MAXPLAYERS + 1];

Handle Hud = null;

public Plugin myinfo =
{
	name = "Plugin Name",
	author = "KiD Fearless",
	description = "Plugin Description",
	version = "1.0",
	url = "https://steamcommunity.com/id/kidfearless/"
}

public void OnPluginStart()
{
	Hud = CreateHudSynchronizer();
	RegConsoleCmd("sm_tashud", Command_Callback);
}

public void OnPluginEnd()
{
	Hud.Close();
}

public Action Command_Callback(int client, int args)
{
	gB_Enabled[client] = !gB_Enabled[client];
	ReplyToCommand(client, "[SM] TAS HUD %s.", BoolToString(gB_Enabled[client]));
	return Plugin_Handled;
}


public void OnClientDisconnect(int client)
{
	gB_Enabled[client] = false
}


public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(gB_Enabled[client])
	{
		CreateHudText();
		int target = GetClientObserverTarget(client);
		int flags = GetEntityFlags(target);

		/*			Bools				 */

		bool ducked = 			IntToBool(GetEntProp(target, Prop_Send, "m_bDucked"));//fully ducked
		bool ducking =			IntToBool(GetEntProp(target, Prop_Send, "m_bDucking"));//in the process of ducking
		bool duckJump = 		IntToBool(GetEntProp(target, Prop_Send, "m_bInDuckJump"));//N/A
		bool in_duck = 			(GetClientButtons(target) & IN_DUCK == IN_DUCK);//buttons of ducking
		bool flagduck = 		(flags & FL_DUCKING == FL_DUCKING);//same as fully ducked, but works in spectate
		//			Floats				//

		float lastDuck = GetEntPropFloat(target, Prop_Send, "m_flLastDuckTime");//server time since the last duck
		float duckAmount = GetEntPropFloat(target, Prop_Send, "m_flDuckAmount");// 0.0 - 1.0 on duck posistion
		float fallspeed = GetEntPropFloat(target, Prop_Send, "m_flFallVelocity");//falling speed
		float gravity = GetEntityGravity(target);
		/*		Strings					*/
	
		char classname[128];
		GetEntityClassname(target, classname, sizeof(classname));

		char targetname[128];
		GetEntPropString(target, Prop_Data, "m_iName", targetname, sizeof(targetname));

		char starget[128];
		GetEntPropString(target, Prop_Data, "m_target", starget, sizeof(starget));//N/A

		char message[512];
		Format(message, sizeof(message),"|ducked: %s\tducking: %s\tduckjump: %s|\n" ...
										"|in_duck: %s\tflagduck:%s|\n|lastduck:%0.1f\tduckamount:%0.1f|\n" ...
										"|fall:%.1f\ttargetname:%s\tclassname:%s|\n" ...
										"|target:%s\tgravity:%.1f|",
										 BoolToString(ducked), BoolToString(ducking),BoolToString(duckJump),
										 BoolToString(in_duck), BoolToString(flagduck), lastDuck, duckAmount,
										 fallspeed, targetname, classname,
										 target, gravity);
		
		ShowSyncHudText(client, Hud, message);
	}
	return Plugin_Continue;
}

void CreateHudText()
{
	const float	posx =		-1.0;
	const float	posy =		0.2;
	const float	time =		0.1;
	const float	fxtime =	0.0;
	const float	fadein =	0.0;
	const float	fadeout =	0.0;

	const int r = 				255;
	const int g = 				255;
	const int b = 				255;
	const int a = 				255;
	const int effect = 			0;
	SetHudTextParams(posx, posy, time, r, g, b, a, effect, fxtime, fadein, fadeout);
}

bool IntToBool(int x)
{
	return (x == 0? false : true);
}

char[] BoolToString(bool b)
{
	char output[6];
	if(b)
	{
		output = "True";
	}
	else
	{
		output = "False";
	}

	return output;
}

stock int GetClientObserverTarget( int client )
{
	int target = client;

	if( IsClientObserver( client ) )
	{
		int specmode = GetEntProp( client, Prop_Send, "m_iObserverMode" );

		if( specmode >= 3 && specmode <= 5 )
		{
			target = GetEntPropEnt( client, Prop_Send, "m_hObserverTarget" );
		}
	}
	
	return target;
}