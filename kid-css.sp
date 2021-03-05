#include <sourcemod>
#include <sdktools>
#include <autoexecconfig>
#include <shavit>
#pragma semicolon 1
#pragma newdecls required


ConVar gC_Forgiveness;
ConVar gC_Scale;


public Plugin myinfo = 
{
	name = "War-3 Legit CSS",
	author = "KiD Fearless",
	description = "",
	version = "1.0",
	url = ""
}

public void OnPluginStart()
{
	gC_Forgiveness = CreateConVar("css_forgiveness", "0.1", "How forgiving should legit css be for missing a bhop, lower = more forgiving");
	gC_Scale = CreateConVar("css_scale", "2.0", "scale factor for landing to leaving speed. 2.0 = halfway point");

	AutoExecConfig();
}


public Action OnPlayerRunCmd(int client, int &buttons)
{
	static bool sB_PrevGround[MAXPLAYERS];
	static int sI_LandingTick[MAXPLAYERS];
	static float sF_LandingVelocity[MAXPLAYERS];


	if(!IsPlayerAlive(client))
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
					SetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity);
				}
			}
		}
	}

	sB_PrevGround[client] = bOnGround;

	return Plugin_Continue;
}


stock float GetClientVelocity(int client)
{
	float vVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vVel);

	vVel[2] = 0.0;
	
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