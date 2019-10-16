#if defined _opentimer_stocks_included
	#endinput
#endif
#define _opentimer_stocks_included


stock float GetEntitySpeed( int ent )
{
	float vecVel[3];
	GetEntityVelocity( ent, vecVel );
	
	return SquareRoot( vecVel[0] * vecVel[0] + vecVel[1] * vecVel[1] );
}

// For comparisons.
stock float GetEntitySpeedSquared( int ent )
{
	float vecVel[3];
	GetEntityVelocity( ent, vecVel );
	
	return ( vecVel[0] * vecVel[0] + vecVel[1] * vecVel[1] );
}

stock void GetEntityVelocity( int ent, float vec[3] )
{
	GetEntPropVector( ent, Prop_Data, "m_vecVelocity", vec );
}

/*stock int GetEntityFlags( int ent )
{
	return GetEntProp( client, Prop_Data, "m_fFlags" );
}*/

stock int GetClientOldButtons( int client )
{
	return GetEntProp( client, Prop_Data, "m_nOldButtons" );
}

stock void SetClientOldButtons( int client, int buttons )
{
	SetEntProp( client, Prop_Data, "m_nOldButtons", buttons );
}

stock int GetClientWaterLevel( int client )
{
	return GetEntProp( client, Prop_Send, "m_nWaterLevel" );
}

stock void ClampFloat( float &fl, float min, float max )
{
	if ( fl > max )
	{
		fl = max;
	}
	else if ( fl < min )
	{
		fl = min;
	}
}

stock bool IsGenericAdmin( int client )
{
	AdminId admin = GetUserAdmin( client );
	
	if ( admin != INVALID_ADMIN_ID )
	{
		return ( GetAdminFlags( admin, Access_Real ) & ADMFLAG_GENERIC ) ? true : false;
	}
	
	return false;
}