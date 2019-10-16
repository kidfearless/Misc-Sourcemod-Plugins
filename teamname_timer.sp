#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <shavit>
#include <mapchooser>
#define REQUIRE_PLUGIN

#pragma newdecls required


ConVar mp_teamname_1 = null;
ConVar mp_teamname_2 = null;
ConVar sm_nextmap = null;


public Plugin myinfo = 
{
	name = "TeamName Game Stats",
	author = "KiD Fearless",
	description = "Changes teamnames to nextmap and timeleft",
	version = "1.0",
	url = "https://steamcommunity.com/id/kidfearless/"
};

public void OnPluginStart()
{
	mp_teamname_1 = FindConVar("mp_teamname_1");
	mp_teamname_2 = FindConVar("mp_teamname_2");
	sm_nextmap = FindConVar("sm_nextmap");
}

public void OnMapStart()
{
	CreateTimer(1.0, Timer_TeamChange, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_TeamChange(Handle timer)
{
	int timeleft;
	char stimeleft[64];
	char snextmap[64];
	char scurrentmap[64];
	sm_nextmap.GetString(snextmap, sizeof(snextmap));


	if(!IsCharNumeric(snextmap[0]) && !IsCharAlpha(snextmap[0]))
	{
		Format(snextmap, sizeof(snextmap), "Next Map:\nPending Vote");
	}
	else
	{
		Format(snextmap, sizeof(snextmap), "%s [T%i]", snextmap, Shavit_GetMapTier(snextmap));
	}

//	mp_teamname_1.SetString(stimeleft, true);

	for(int i = 2; i < MaxClients; ++i)
	{
		if(IsValidClient(i))
		{
			//int style = Shavit_GetBhopStyle(client);
			//int track = Shavit_GetClientTrack(client);
			//float time;
			//Shavit_GetPlayerPB(client, style, time, track);
			//int rank = Shavit_GetRankForTime(style, time, track);
			//char team1[64];
			//Format(team1, sizeof(team1), "Rank:")

		}
	}
	mp_teamname_2.SetString(snextmap, true);
}

bool IsPendingVote()
{
	return gB_Mapchooser && EndOfMapVoteEnabled() && !HasEndOfMapVoteFinished();
}