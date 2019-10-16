#if defined _kid_tas_included
	#endinput
#endif
#define _kid_tas_included

#define e 2.71828
#define DEFAULT_AIR 1000.0
#define DEFAULT_VEL 450.0
#define DEFAULT_WISH 30.0
#define FORWARDMOVE vel[0]
#define SIDEMOVE vel[1]
#define PERFSPEEDHACK 227.6

stock float GetClientVelo(int client)
{
	float fAbsVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);

	float velocity = (SquareRoot(Pow(fAbsVelocity[0], 2.0) + Pow(fAbsVelocity[1], 2.0)));
	
	return velocity;
}

stock float PerfStrafeAngle(float speed)
{
	if(speed == 0.0)
	{
		return 90.0;
	}
	return RadToDeg(ArcTangent(30 / speed));
}

stock float NormalizeAngle( float ang )
{
    if ( ang > 180.0 )
    {
        ang -= 360.0;
    }
    else if ( ang < -180.0 )
    {
        ang += 360.0;
    }
    
    return ang;
}

stock float GetEffPerc(const float temp)
{
	float effPerc = temp;
	if(effPerc > 100.0)
	{
		effPerc = (100 - effPerc) + 100;
	}

	if(effPerc < 0.0)
	{
		effPerc = 0.0;
	}

	return effPerc;
}

stock void Strafe_Left(int client, int &buttons, float vel[3])
{
	vel[1] = -DEFAULT_VEL;
	//buttons |= IN_MOVELEFT;
}

stock void Strafe_Right(int client, int &buttons, float vel[3])
{
	vel[1] = DEFAULT_VEL;
	//buttons |= IN_MOVERIGHT;
}


stock bool Autobhop_OnGround(int client, int& buttons)
{
	if((GetEntityFlags(client) & FL_ONGROUND) == FL_ONGROUND && (buttons & IN_JUMP) != IN_JUMP)//if you are on the ground and not holding jump
	{
		return true;
	}
	return false;
}

bool IsSurfing(int client)
{
	float fPosition[3];
	GetClientAbsOrigin(client, fPosition);

	float fEnd[3];
	fEnd = fPosition;
	fEnd[2] -= 64.0;

	float fMins[3];
	GetEntPropVector(client, Prop_Send, "m_vecMins", fMins);

	float fMaxs[3];
	GetEntPropVector(client, Prop_Send, "m_vecMaxs", fMaxs);

	Handle hTR = TR_TraceHullFilterEx(fPosition, fEnd, fMins, fMaxs, MASK_PLAYERSOLID, TRFilter_NoPlayers, client);

	if(TR_DidHit(hTR))
	{
		float fNormal[3];
		TR_GetPlaneNormal(hTR, fNormal);

		delete hTR;

		// If the plane normal's Z axis is 0.7 or below (alternatively, -0.7 when upside-down) then it's a surf ramp.
		// https://mxr.alliedmods.net/hl2sdk-css/source/game/server/physics_main.cpp#1059

		return (-0.7 <= fNormal[2] <= 0.7);
	}

	delete hTR;

	return false;
}

public bool TRFilter_NoPlayers(int entity, int mask, any data)
{
	return (entity != view_as<int>(data) || (entity < 1 || entity > MaxClients));
}

