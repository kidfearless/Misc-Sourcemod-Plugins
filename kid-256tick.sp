#include <sourcemod>
#include <sdktools>
#include <sdkhooks>


// bool g_bOn256Tick[MAXPLAYERS+1];
bool g_bOn256Tick[MAXPLAYERS+1] = {true, ...};

public void OnPluginStart()
{
	RegConsoleCmd("sm_256", Command_256);
}

public void OnClientPutInServer(int client)
{
	// g_bOn256Tick[client] = false;
	g_bOn256Tick[client] = true;
}

public Action Command_256(int client, int args)
{
	g_bOn256Tick[client] = !g_bOn256Tick[client];
	ReplyToCommand(client, "toggled: %s", g_bOn256Tick[client] ? "on" : "off")
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	static float s_LastAng[MAXPLAYERS][3];
	float ang[3];
	ang = angles;

	float yawd = s_LastAng[client][1] - angles[1];
	if (yawd > 180.0)
	{
		yawd -= 360.0; // Negative value (Turned to the left)
	}
	else if (yawd < -180.0)
	{
		yawd += 360.0; // Positive value (Turned to the right)
	}

	// ang[1] += yawd;
	
	AirMove(client, vel, ang);
	s_LastAng[client] = angles;
}

void AirAccelerate( float wishdir[3], float wishspeed, float accel, float m_outWishVel[3], float m_vecVelocity[3] )
{
	int i;
	float addspeed, accelspeed, currentspeed;
	float wishspd;

	wishspd = wishspeed;

	// Cap speed
	if (wishspd > 30.0)
	{
		wishspd = 30.0;
	}

	// Determine veer amount
	currentspeed = m_vecVelocity[0] * wishdir[0] + m_vecVelocity[1] * wishdir[1];

	// See how much to add
	addspeed = wishspd - currentspeed;

	// If not adding any, done.
	if (addspeed <= 0.0)
	{
		PrintToConsoleAll( "returned");
		return;
	}

	// Determine acceleration speed after acceleration
	accelspeed = accel * wishspeed * GetGameFrameTime() * 0.5;

	// Cap it
	if (accelspeed > addspeed)
	{
		accelspeed = addspeed;
	}
	
	// Adjust pmove vel.
	for (i = 0; i < 3 ; i++)
	{
		m_vecVelocity[i] += accelspeed * wishdir[i];
		m_outWishVel[i] += accelspeed * wishdir[i];
	}
}

void AirMove(int client, const float vel[3], const float angles[3])
{
	int			i;
	float		wishvel[3];
	float		fmove, smove;
	float		wishdir[3];
	float		wishspeed;
	float fore[3], right[3], up[3];
	float m_vecVelocity[3];

	GetAngleVectors(angles, fore, right, up);  // Determine movement angles
	
	// Copy movement amounts
	fmove = vel[1];
	smove = vel[0];
	
	// Zero out z components of movement vectors
	fore[2] = 0.0;
	right[2] = 0.0;
	NormalizeVector(fore, fore);  // Normalize remainder of vectors
	NormalizeVector(right, right);    // 

	for (i = 0; i < 2; i++)
    // Determine x and y parts of velocity
	{	
		wishvel[i] = (fore[i] * fmove) + (right[i] * smove);
	}   
	wishvel[2] = 0.0;             // Zero out z part of velocity

	wishdir = wishvel;   // Determine maginitude of speed of move
	wishspeed = NormalizeVector(wishdir, wishdir);

	//
	// clamp to server defined max speed
	//

	float m_flMaxSpeed = FindConVar("sv_maxspeed").FloatValue;
	if ( wishspeed != 0.0 && (wishspeed > m_flMaxSpeed))
	{
		ScaleVector(wishvel, m_flMaxSpeed/wishspeed);
		wishspeed = m_flMaxSpeed;
	}
	
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", m_vecVelocity);

	float m_outWishVel[3];
	AirAccelerate( wishdir, wishspeed, FindConVar("sv_airaccelerate").FloatValue, m_outWishVel, m_vecVelocity );


	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, m_vecVelocity);
}