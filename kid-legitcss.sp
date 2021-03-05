#include <sourcemod>
#include <sdktools>
#include <autoexecconfig>
#include <shavit>
#pragma semicolon 1
#pragma newdecls required

bool gB_Toggled[MAXPLAYERS];
int gI_Style = -1;

ConVar gC_Forgiveness;
ConVar gC_Scale;

bool gB_Late;

public Plugin myinfo = 
{
	name = "Legit CSS Style",
	author = "KiD Fearless",
	description = "",
	version = "1.0",
	url = ""
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	gB_Late = late;

	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");

	gC_Forgiveness = CreateConVar("css_forgiveness", "0.1", "How forgiving should legit css be for missing a bhop, lower = more forgiving");
	gC_Scale = CreateConVar("css_scale", "2.0", "scale factor for landing to leaving speed. 2.0 = halfway point");
	
	// RegAdminCmd("sm_css", Command_LegitCSS, ADMFLAG_BAN, "toggle legit css");
	RegConsoleCmd("sm_css", Command_LegitCSS, "toggle legit css");

	if(gB_Late)
	{
		gI_Style = FindCSSStyle();
		if(gI_Style == -1)
		{
			SetFailState("Could Not Find kid-css style on server... Unloading");
		}
	}
}

public void Shavit_OnStyleConfigLoaded(int styles)
{
	gI_Style = FindCSSStyle(styles);
}

int FindCSSStyle(int styles = -1)
{
	if(styles == -1)
	{
		styles = Shavit_GetStyleCount();
	}

	int style = -1;
	for(int i = 0; i < styles; ++i)
	{
		char buffer[128];
		Shavit_GetStyleStrings(i, sSpecialString, buffer, 128);

		
		if(StringContains(buffer, "css"))
		{
			style = i;
			break;
		}
	}
	return style;
}

public void OnClientConnected(int client)
{
	gB_Toggled[client] = false;
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
	static bool sB_PrevGround[MAXPLAYERS];
	static int sI_LandingTick[MAXPLAYERS];
	static float sF_LandingVelocity[MAXPLAYERS];


	if(!gB_Toggled[client] || !IsPlayerAlive(client))
	{
		return Plugin_Continue;
	}

	bool bOnGround = ((GetEntityFlags(client) & FL_ONGROUND) == FL_ONGROUND);

	if(bOnGround)//on the ground now
	{
		if(!sB_PrevGround[client])//not on the ground before
		{
			sI_LandingTick[client] = 0;//start the counter
			sF_LandingVelocity[client] = GetClientVelocity(client);//get the landing velocity
		}
		else//were on the ground before
		{
			++sI_LandingTick[client];
		}
	}
	else
	{
		if(sB_PrevGround[client])
		{
			if(sI_LandingTick[client] != 0 && sI_LandingTick[client] < 10)
			{
				float speed = GetClientVelocity(client);
				if(speed > 10.0)
				{
					float desiredSpeed = (speed + sF_LandingVelocity[client]) / OneNotZero(gC_Scale.FloatValue + (sI_LandingTick[client] * gC_Forgiveness.FloatValue));
					float scale = desiredSpeed / speed;
				
					float velocity[3];
					GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity);

					float temp = velocity[2];
					velocity[2] = 0.0;
					ScaleVector(velocity, scale);
					velocity[2] = temp;
					PrintToChat(client, "land: %f, leave: %f, scale: %f", sF_LandingVelocity[client], speed * scale, scale);
					SetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity);
				}
			}
		}
	}

	sB_PrevGround[client] = bOnGround;

	return Plugin_Continue;
}

public Action Command_LegitCSS(int client, int args)
{
	if(Shavit_ChangeClientStyle(client, gI_Style))
	{
		Shavit_RestartTimer(client, Shavit_GetClientTrack(client));
		gB_Toggled[client] = true;
	}
	else
	{
		gB_Toggled[client] = false;
	}

	return Plugin_Handled;
}

stock float GetClientVelocity(int client)
{
	float vVel[3];
	
	vVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	vVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	
	
	return GetVectorLength(vVel);
}

float OneNotZero(float input)
{
	if(input == 0.0)
	{
		return 1.0;
	}

	return input;
}

stock bool StringContains(const char[] str, const char[] sub, bool caseSense = false)
{
	return (StrContains(str, sub, caseSense) != -1);
}