#include <sourcemod>

//Change the following to limit the number of time this kind of vote is called
#define maxVote 1

int voteTimes;


public OnPluginStart() 
{ 
    HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy); 
} 

public OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
    voteTimes = 0;
}  

public OnMapStart()
{
	voteTimes = 0;
}


public Handle_VoteMenu(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		/* This is called after VoteEnd */
		CloseHandle(menu);
	}
	else if (action == MenuAction_VoteEnd)
	{
	/* 0=yes, 1=no */
		if (param1 == 0)
		{
			PrintToChatAll("Vote has failed. YOU fools voted no!!! How dare you incoming bands");
			voteTimes = voteTimes+1;
			FindConVar("sv_autobunnyhopping").SetInt(0);
		}	
		else
		{
			PrintToChatAll("YES is the answer to autobhop");
			voteTimes = voteTimes+1;
			FindConVar("sv_autobunnyhopping").SetInt(1);
		}
	}
}




public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{

	if ((strcmp(sArgs, "!autobhop", false) == 0)||(strcmp(sArgs, "/autobhop", false) == 0))
	{
	
	if (voteTimes >= maxVote)
    {
		PrintToChat(client, "\x04[Vote-autobhop]\x03 There was already an autobhop vote.");
		return Plugin_Handled;	
 	}
	
	
	ShowActivity2(client, "[SM] ", "Initiated Vote autobhop");
	LogAction(client, -1, "\"%L\" used vote-autobhop", client);
	new Handle:menu = CreateMenu(Handle_VoteMenu);
	SetMenuTitle(menu, "Turn on Autobhop so you can be Ph00n?");
	AddMenuItem(menu, "notsure1", "No");
	AddMenuItem(menu, "notsure2", "Yes");
	SetMenuExitButton(menu, false);
	VoteMenuToAll(menu, 18);
	
	return Plugin_Handled;
}


	return Plugin_Continue;
}
