#if defined _tr_trigger_Included
 #endinput
#endif
#define _tr_trigger_Included

#include <sdktools>



stock int GetTriggerAtAim(int client)
{
	float origin[3];
	float ang[3];
	GetClientEyePosition(client, origin);
	GetClientEyeAngles(client, ang);

	DataPack pack = new DataPack();
	TR_EnumerateEntities(origin, ang, true, RayType_Infinite, GetFirstTrigger, pack);
	pack.Reset();

	if(!pack.IsReadable(sizeof(client)))
	{
		delete pack;
		return -1;
	}

	int _ent = pack.ReadCell();
	delete pack;
	return _ent;
}

public bool GetFirstTrigger(int entity, DataPack pack)
{
	pack.WriteCell(entity);
	return false;
}


/* 
	Returns the db map id for the current map or -1 on failure
*/
native int Ent_GetCurrentMapID();


/* Fired when a valid mapid has been assigned, and is ready to be used. */
forward void Ent_OnMapIDReady(int mapid);