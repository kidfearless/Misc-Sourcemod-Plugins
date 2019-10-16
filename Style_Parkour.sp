#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
//#include <sdktools_engine>
//#include <sdktools_trace>
//#include <sdktools_tempents>
//#include <sdktools_tempents_stocks>
//#include <sdktools_entinput>
#include <shavit>


#pragma semicolon 1
#pragma newdecls required


public Plugin myinfo =
{
	name = "Style: Parkour",
	author = "Hymns For Disco",
	description = "Style: Parkour.",
	version = "1.0",
	url = "www.swoobles.com"
}



const FSOLID_NOT_SOLID = 0x0004;
const FSOLID_TRIGGER = 0x0008;
#define SOLID_NONE	0
#define COLLISION_GROUP_PLAYER_MOVEMENT	8
#define ROCKET_COLLISION_GROUP	COLLISION_GROUP_PLAYER_MOVEMENT

#define USE_SPECIFIED_BOUNDS	3

float g_fRocketMins[3] = {-0.0, -0.0, -0.0};
float g_fRocketMaxs[3] = {0.0, 0.0, 0.0};

#define WALLJUMP_COOLDOWN_BASE 1.0
#define WALLJUMP_MAX_IN_AIR 3
#define TRACE_HULL_RADIUS 40.0
#define WALLJUMP_VERTICAL_VELOCITY 200.0

#define GRAPPLE_PULL_MAX 400.0
#define GRAPPLE_PULL_ACCEL 25.0
#define GRAPPLE_CHARGE_MAX 1024.0
#define GRAPPLE_CHARGE_USE -3.5
#define GRAPPLE_CHARGE_REGEN 1.0
#define GRAPPLE_CHARGE_WALLJUMP 200.0
#define GRAPPLE_HOOK_SPEED 4500.0

enum ParkourData
{
	Parkour_Ticks,
	bool:Parkour_Enabled,
	Grapple_HookEntityRef,
	Float:Grapple_Charge,
	bool:Grapple_Hooked,
	bool:Grapple_Expired,
	Float:WallJump_LastJumpTime,
	WallJump_JumpsSinceGround
};

int g_eParkourData[MAXPLAYERS + 1][ParkourData];

int g_Sprite;


public void OnMapStart()
{
	g_Sprite = PrecacheModel("materials/sprites/laserbeam.vmt");
}


public void OnClientConnected(int iClient)
{
	g_eParkourData[iClient][Parkour_Enabled] = false;
}

public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle)
{
	char[] sSpecial = new char[128];
	Shavit_GetStyleStrings(newstyle, sSpecialString, sSpecial, 128);

	if(StrContains(sSpecial, "swble", false) == -1)//off
	{
		OnDeactivated(client);
	}
	else//on
	{
		OnActivated(client);
	}
}

public void OnActivated(int iClient)
{
	SDKHook(iClient, SDKHook_PreThinkPost, OnPreThinkPost);
	g_eParkourData[iClient][Parkour_Enabled] = true;
	g_eParkourData[iClient][Grapple_Charge] = GRAPPLE_CHARGE_MAX;
	g_eParkourData[iClient][Grapple_HookEntityRef] = -1;
}

public void OnDeactivated(int iClient)
{
	g_eParkourData[iClient][Parkour_Enabled] = false;
	SDKUnhook(iClient, SDKHook_PreThinkPost, OnPreThinkPost);
	KillHook(iClient);
}

bool IsNearWall(int iClient)
{
	float fEyePos[3], fOrigin[3];
	GetClientEyePosition(iClient, fEyePos);
	GetClientAbsOrigin(iClient, fOrigin);
	
	float fEyeHeight = fEyePos[2] - fOrigin[2] - 16.0;
	float fMins[3];
	fMins[0] = -TRACE_HULL_RADIUS;
	fMins[1] = -TRACE_HULL_RADIUS;
	fMins[2] = -fEyeHeight;
	float fMaxs[3];
	fMaxs[0] = TRACE_HULL_RADIUS;
	fMaxs[1] = TRACE_HULL_RADIUS;
	fMaxs[2] = 0.0;
	
	TR_TraceHullFilter(fEyePos, fEyePos, fMins, fMaxs, MASK_PLAYERSOLID, TraceFilter_DontHitPlayers);
	
	if(TR_DidHit())
	{
		return true;
	}
	else
	{
		return false;
	}
}


public bool TraceFilter_DontHitPlayers(int iEnt, int iMask, any iData)
{
	if(1 <= iEnt <= MaxClients)
		return false;
	
	return true;
}

public void OnPreThinkPost(int iClient)
{
	int iButtons = GetClientButtons(iClient);
	
	OnGrapple(iClient, iButtons & IN_ATTACK);

	if(iButtons & IN_ATTACK2)
	{
		OnAttack2(iClient);
	}

	//PrintHintText(iClient, "%f", g_eParkourData[iClient][Grapple_Charge]);
	
	if(GetEntityFlags(iClient) & FL_ONGROUND)
	{
		g_eParkourData[iClient][WallJump_JumpsSinceGround] = 0;
	}
}


void OnGrapple(int iClient, int bState)
{
	if(bState && !g_eParkourData[iClient][Grapple_Expired])
	{
		int iHook = EntRefToEntIndex(g_eParkourData[iClient][Grapple_HookEntityRef]);
		if(iHook > 0)
		{
			if(g_eParkourData[iClient][Grapple_Hooked])
			{
				float fClientPos[3];
				float fEyeAngles[3];
				float fGrappleEntPos[3];
				GetClientEyePosition(iClient, fClientPos);
				GetClientEyeAngles(iClient, fEyeAngles);
				GetEntPropVector(iHook, Prop_Send, "m_vecOrigin", fGrappleEntPos);
				
				float fClientVel[3], fHookDir[3];
				GetEntPropVector(iClient, Prop_Data, "m_vecVelocity", fClientVel);
				
				SubtractVectors(fGrappleEntPos, fClientPos, fHookDir);
				NormalizeVector(fHookDir, fHookDir);
				float fSpeedTowardsHook = GetVectorDotProduct(fClientVel, fHookDir);
				
				if (fSpeedTowardsHook < GRAPPLE_PULL_MAX)
				{
					float fSpeedToAdd = GRAPPLE_PULL_ACCEL;
					if(fSpeedTowardsHook + fSpeedToAdd > GRAPPLE_PULL_MAX)
					{
						fSpeedToAdd = GRAPPLE_PULL_MAX - fSpeedTowardsHook;
					}
					
					ScaleVector(fHookDir, fSpeedToAdd);
					AddVectors(fClientVel, fHookDir, fClientVel);
					TeleportEntity(iClient, NULL_VECTOR, NULL_VECTOR, fClientVel);
				}
				
				HookCharge(iClient, GRAPPLE_CHARGE_USE);
				
				int iColor[4];
				GetChargeColor(iClient, iColor);
				
				GetAngleVectors(fEyeAngles, fEyeAngles, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(fEyeAngles, 200.0);
				AddVectors(fClientPos, fEyeAngles, fClientPos);
				
				TE_SetupBeamPoints(fClientPos, fGrappleEntPos, g_Sprite, 0, 0, 0, 0.1, 2.0, 2.0, 10, 0.0, iColor, 0);
				TE_SendToClient(iClient);
				
				HookCharge(iClient, GRAPPLE_CHARGE_USE);
			}
		}
		else
		{
			iHook = CreateHook(iClient);
			if(!iHook)
				return;
			
			g_eParkourData[iClient][Grapple_HookEntityRef] = EntIndexToEntRef(iHook);
			
			float fEyePos[3];
			float velocity[3];
			GetClientEyePosition(iClient, fEyePos);
			GetClientEyeAngles(iClient, velocity);
			GetAngleVectors(velocity, velocity, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(velocity, GRAPPLE_HOOK_SPEED);
			TeleportEntity(iHook, fEyePos, NULL_VECTOR, velocity);
			
			int iColor[4];
			GetChargeColor(iClient, iColor);
			
			TE_SetupBeamFollow(iHook, g_Sprite, 0, 1.0, 5.0, 5.0, 10, iColor);
			TE_SendToClient(iClient);
		}
	}
	else if(bState)
	{
		HookCharge(iClient, GRAPPLE_CHARGE_REGEN);
	}
	else
	{
		HookCharge(iClient, GRAPPLE_CHARGE_REGEN);
		
		KillHook(iClient);
		
		if(g_eParkourData[iClient][Grapple_Expired])
			g_eParkourData[iClient][Grapple_Expired] = false;
	}
}

int CreateHook(int iClient)
{
	int iEnt = CreateEntityByName("smokegrenade_projectile");
	if(iEnt < 1 || !IsValidEntity(iEnt))
		return 0;
	
	InitHook(iClient, iEnt);
	return iEnt;
}

void KillHook(int iClient)
{
	int iHook = EntRefToEntIndex(g_eParkourData[iClient][Grapple_HookEntityRef]);
	if(iHook > 0)
		AcceptEntityInput(iHook, "KillHierarchy");
	
	g_eParkourData[iClient][Grapple_Hooked] = false;
	g_eParkourData[iClient][Grapple_HookEntityRef] = -1;
}

void HookCharge(int iClient, float fAmount)
{
	if(GetEntityFlags(iClient) & FL_ONGROUND && fAmount > 0.0)
	{
		g_eParkourData[iClient][Grapple_Charge] += 10.0 * fAmount;
	}
	else
	{
		g_eParkourData[iClient][Grapple_Charge] += fAmount;
	}

	if (g_eParkourData[iClient][Grapple_Charge] > GRAPPLE_CHARGE_MAX)
	{
		g_eParkourData[iClient][Grapple_Charge] = GRAPPLE_CHARGE_MAX;
	}
	else if (g_eParkourData[iClient][Grapple_Charge] <= 0.0)
	{
		g_eParkourData[iClient][Grapple_Charge] = 0.0;
		KillHook(iClient);
		g_eParkourData[iClient][Grapple_Expired] = true;	
	}
}

void GetChargeColor(int iClient, int iResult[4])
{
	int iGreen = RoundToFloor((255 / GRAPPLE_CHARGE_MAX) * g_eParkourData[iClient][Grapple_Charge]);
	int iRed = RoundToFloor(255.0 - (255 / GRAPPLE_CHARGE_MAX) * g_eParkourData[iClient][Grapple_Charge]);
	
	if(iRed < 0)
	{
		iRed = 0;
	}
	if(iGreen < 0)
	{
		iGreen = 0;
	}
	
	int iColor[4] = {255, 255, 0, 255};
	iColor[0] = iRed;
	iColor[1] = iGreen;
	
	iResult = iColor;
}

void InitHook(int iClient, int iHook)
{
	DispatchSpawn(iHook);
	
	SetEntityMoveType(iHook, MOVETYPE_FLYGRAVITY);
	SetEntProp(iHook, Prop_Send, "m_CollisionGroup", ROCKET_COLLISION_GROUP);
	SetEntProp(iHook, Prop_Data, "m_nSolidType", SOLID_NONE);
	SetEntProp(iHook, Prop_Send, "m_usSolidFlags", FSOLID_NOT_SOLID | FSOLID_TRIGGER);
	SetEntPropEnt(iHook, Prop_Send, "m_hOwnerEntity", iClient);
	
	SetEntProp(iHook, Prop_Data, "m_nSurroundType", USE_SPECIFIED_BOUNDS);
	SetEntPropFloat(iHook, Prop_Data, "m_flRadius", 0.0);
	SetEntProp(iHook, Prop_Data, "m_triggerBloat", 0);
	
	SetEntPropVector(iHook, Prop_Send, "m_vecMins", g_fRocketMins);
	SetEntPropVector(iHook, Prop_Send, "m_vecMaxs", g_fRocketMaxs);
	
	SetEntPropVector(iHook, Prop_Send, "m_vecSpecifiedSurroundingMins", g_fRocketMins);
	SetEntPropVector(iHook, Prop_Send, "m_vecSpecifiedSurroundingMaxs", g_fRocketMaxs);
	
	SetEntPropVector(iHook, Prop_Data, "m_vecSurroundingMins", g_fRocketMins);
	SetEntPropVector(iHook, Prop_Data, "m_vecSurroundingMaxs", g_fRocketMaxs);
	
	SDKHook(iHook, SDKHook_StartTouchPost, OnHookStartTouchPost);
}

public void OnHookStartTouchPost(int iHook, int iOther)
{
	int iOwner = GetEntPropEnt(iHook, Prop_Send, "m_hOwnerEntity");
	g_eParkourData[iOwner][Grapple_Hooked] = true;
	float nullVector[3] = {0.0, 0.0, 0.0};
	TeleportEntity(iHook, NULL_VECTOR, NULL_VECTOR, nullVector);
	SetEntityMoveType(iHook, MOVETYPE_NONE);
}

void OnAttack2(int iClient)
{
	if((GetEngineTime() - g_eParkourData[iClient][WallJump_LastJumpTime] >= WALLJUMP_COOLDOWN_BASE)
	&& IsNearWall(iClient)
	&& (g_eParkourData[iClient][WallJump_JumpsSinceGround] < WALLJUMP_MAX_IN_AIR))
	{
		g_eParkourData[iClient][WallJump_JumpsSinceGround]++;
		
		float fNewVel[3];
		float velocity[3];
		float fEyeAngles[3];
		GetEntPropVector(iClient, Prop_Data, "m_vecVelocity", velocity);
		GetClientEyeAngles(iClient, fEyeAngles);
		GetAngleVectors(fEyeAngles, fNewVel, NULL_VECTOR, NULL_VECTOR);
		
		ScaleVector(fNewVel, 200.0);
		
		if(fNewVel[2] > 0)
		{
			fNewVel[2] += 300.0;
		}
		else
		{
			fNewVel[2] = 0.0;
		}
		
		velocity[2] = 0.0;
		AddVectors(velocity, fNewVel, fNewVel);
		TeleportEntity(iClient, NULL_VECTOR, NULL_VECTOR, fNewVel);
		g_eParkourData[iClient][WallJump_LastJumpTime] = GetEngineTime();
		
		HookCharge(iClient, GRAPPLE_CHARGE_WALLJUMP);
	}
}