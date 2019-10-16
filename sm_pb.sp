#include<sourcemod>
#include<shavit>


public void OnPluginStart()
{
	RegConsoleCmd("sm_pb", Command_PB, "Prints your personal best to chat");
}

public Action Command_PB(int client, int args)
{

	float pb;
	float wr
	Shavit_GetWRTime(Shavit_GetBhopStyle(client), wr, Track_Main);
	Shavit_GetPlayerPB(client, Shavit_GetBhopStyle(client), pb, Track_Main);
	
	char[] pbtime = new char[32];
	char[] wrtime = new char[32];
	
	FormatSeconds(pb, pbtime, 32, true);
	FormatSeconds(wr, wrtime, 32, true);
	
	if(wr == 0.0)
	{
		Format(wrtime, 32, "None");
	}
	if(pb == 0.0)
	{
		Format(pbtime, 32, "None");
	}
	
	PrintToChat(client, "  WR: %s PB: %s", wrtime, pbtime);
	return Plugin_Handled;
}