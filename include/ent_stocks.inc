#if defined _ent_stocks_included
	#endinput
#endif
#define _ent_stocks_included

#include <sdktools>
#include <sdkhooks>

stock void Game_End()
{
	int end = CreateEntityByName("game_end");
	AcceptEntityInput(end, "EndGame");
}