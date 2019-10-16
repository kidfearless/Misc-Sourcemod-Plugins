public void OnPluginStart()
{
	RegAdminCmd("restart_server", Command_ShutdownServer, ADMFLAG_ROOT);
}

public Action Command_ShutdownServer(int client, int args)
{
	ShutdownServer();

	return Plugin_Handled;
}

public void ShutdownServer()
{	
	for(new i = 1; i <= MAXPLAYERS; i++)
	{
		if (IsClientInGame(i))
		{
			ClientCommand(i, "retry");
		}
	}
	
	RequestFrame(RestartServer);
}

public void RestartServer(any data)
{
	ServerCommand("_restart");
}