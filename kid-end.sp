
#include <sourcemod>
#include <shavit>

bool gB_UsedEnd[MAXPLAYERS+1];


public void OnClientConnected(int client)
{
	gB_UsedEnd[client] = false;
}

public void Shavit_OnEnd(int client, int track)
{
	Shavit_StopTimer(client);
	gB_UsedEnd[client] = true;
}

public Action Shavit_OnFinishPre(int client, any snapshot[TIMERSNAPSHOT_SIZE])
{
	if(gB_UsedEnd[client])
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void Shavit_OnEnterZone(int client, int type, int track, int id, int entity)
{
	gB_UsedEnd[client] = false;
}