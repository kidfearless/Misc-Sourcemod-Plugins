#if defined _smc_included_
	#endinput
#endif
#define _smc_included_

/**
 * Called when a player RTV's.
 *
 * @param client					Client index.
 * @noreturn
 */
forward void SMC_OnRTV(int client);

/**
 * Called when a player UNRTV's.
 *
 * @param client					Client index.
 * @noreturn
 */
forward void SMC_OnUnRTV(int client);

/**
 * Called when a player uses !stay.
 *
 * @param client					Client index.
 * @noreturn
 */
forward void SMC_OnStay(int client);

/**
 * Called when a player uses !leave.
 *
 * @param client					Client index.
 * @noreturn
 */
forward void SMC_OnLeave(int client);

/**
 * Called when the map changes from an RTV.
 *
 * @noreturn
 */
forward void SMC_OnSuccesfulRTV();

/**
 * Called when the scoreboards are updated with their new values.
 * @param teamname1					Value that mp_teamname1 will be set to.
 * @param teamname2					Value that mp_teamname2 will be set to.
 * @noreturn
 */
forward Action SMC_OnTeamNameChange(char teamName1[64], char teamName2[64]);

/**
 * Native used to get the nextmap set by the mapchooser
 * @param mapName					Buffer to store the next map.
 * @param mapLength					Maximum Length of the mapName buffer
 * @param id						Buffer to store the workshop id.
 * @param idLength					Maximum Length of the id buffer
 * @noreturn
 */
native void SMC_GetNextMap(char[] mapName, int mapLength, char[] id = "", int idLength = 0);

/**
 * Native used to set the nextmap set by the mapchooser
 * @param mapName					Desired map, should be the maps display name or partial name.
 * @param mapLength					Maximum Length of the mapName buffer
 * @return 							true if the nextmap was set.
 */
native bool SMC_SetNextMap(const char[] mapName, int mapLength);

/**
 * Native used to change the map with the mapchooser system.
 * @param mapName					Desired map, should be the maps display name or partial name.
 * @param mapLength					Maximum Length of the mapName buffer
 * @param delay						Delay in seconds for the map change to actually happen.
 * @return 							true if no errors were found.
 */
native bool SMC_ChangeMap(const char[] mapName, int mapLength, float delay = 2.0);

public SharedPlugin __pl_smc =
{
	name = "shavit - MapChooser",
	file = "shavit_mapchooser.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_smc_SetNTVOptional()
{
	MarkNativeAsOptional("SMC_GetNextMap");
	MarkNativeAsOptional("SMC_ChangeMap");
	MarkNativeAsOptional("SMC_SetNextMap");
}
#endif