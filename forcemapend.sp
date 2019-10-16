#include <sourcemod>
#include <cstrike>

public Plugin myinfo =
{
	name = "Force Map End",
	author = "KiD Fearless",
	description = "Forces the map to end for single round servers",
	version = "1.0",
	url = "https://steamcommunity.com/id/kidfearless/"
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
    if(reason == CSRoundEnd_Draw)
    {
		FindConVar("mp_timelimit").IntValue = 0;
		FindConVar("mp_roundtime").IntValue = 0;
	}
}