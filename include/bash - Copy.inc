#if defined _bash_included
 #endinput
#endif
#define _bash_included

/*
* Gets a client's velocity with extra settings to disallow velocity on certain axes
*/


stock Float:GetClientVelocity(client, bool:UseX, bool:UseY, bool:UseZ)
{
	new Float:vVel[3];

	if(UseX)
	{
		vVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	}

	if(UseY)
	{
		vVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	}

	if(UseZ)
	{
		vVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
	}

	return GetVectorLength(vVel);
}