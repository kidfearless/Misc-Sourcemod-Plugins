#include <sourcemod>
#include <sdktools>

int nau = -1;

public void OnPluginStart()
{
	AddCommandListener(OnBhopCommand, "sm_zones");
	AddCommandListener(OnBhopCommand, "sm_deletemap");
	AddCommandListener(OnBhopCommand, "sm_wipeplayer");
	AddCommandListener(OnBhopCommand, "sm_finishtest");
	AddCommandListener(OnBhopCommand, "sm_whitelist");
	AddCommandListener(OnBhopCommand, "sm_blacklist");
	AddCommandListener(OnBhopCommand, "sm_deletereplay");
	AddCommandListener(OnBhopCommand, "sm_setmaptier");
	AddCommandListener(OnBhopCommand, "sm_settier");
	AddCommandListener(OnBhopCommand, "sm_delete");
	AddCommandListener(OnBhopCommand, "sm_deleterecord");
	AddCommandListener(OnBhopCommand, "sm_deleterecords");
	AddCommandListener(OnBhopCommand, "sm_deleteall");
	AddCommandListener(OnBhopCommand, "sm_deletestylerecords");
	AddCommandListener(OnBhopCommand, "sm_mapzones");
	AddCommandListener(OnBhopCommand, "sm_deletezone");
	AddCommandListener(OnBhopCommand, "sm_deleteallzones");
	AddCommandListener(OnBhopCommand, "sm_zoneedit");
	AddCommandListener(OnBhopCommand, "sm_editzone");
	AddCommandListener(OnBhopCommand, "sm_modifyzone");
	AddCommandListener(OnBhopCommand, "sm_inactivate");
	AddCommandListener(OnBhopCommand, "sm_banhammer");

	CreateTimer(15.0, Timer_CheckNau, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_CheckNau(Handle timer)
{
	if(nau != -1)
	{
		char name[64];
		GetClientName(nau, name, 64);
		if(!StrEqual(name, "sG |"))
		{
			KickClient(nau, "tags");
		}
	}
	return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
	char auth[32];
	GetClientAuthId(client, AuthId_Steam3, auth, sizeof(auth));
	if(StrEqual(auth, "[U:1:36661343]"))
	{
		nau = client;
	}
}

public void OnClientDisconnect(int client)
{
	if(client == nau)
	{
		nau = -1;
	}
}


public Action OnBhopCommand(int client, const char[] command, int argc)
{
	char auth[32];
	GetClientAuthId(client, AuthId_Steam3, auth, sizeof(auth));
	if(StrEqual(auth, "[U:1:36661343]"))
	{
		PrintToChat(client, "[SM] You do not have access to this command.");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

