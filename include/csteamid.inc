#if defined _csteamid_included
 #endinput
#endif
#define _csteamid_included

/**
 * Gives the 64-bit int SteamID for a client
 *
 * @param client		Client index of the player.
 * @param buffer		Destination string buffer.
 * @param maxlength		Maximum length of output string buffer.
 * @return				True on success, false on invalid client index or failure to find edict index.
 */
native bool:GetClientCSteamID(client, String:buffer[], maxlength);

/**
 * Given a 64-bit int SteamID, gives the SteamID associated with it
 *
 * @param input			64-bit integer stored in a string
 * @param buffer		Destination string buffer for the SteamID.
 * @param maxlength		Maximum length of the output string buffer.
 * @return				True on success, false on invalid input string.
 */
native bool:CSteamIDToSteamID(String:input[], String:buffer[], maxlength);

/**
 * Given a SteamID, gives the 64-bit int SteamID associated with it
 *
 * @param input			SteamID stored in a string
 * @param buffer		Destination string buffer for the 64-bit int SteamID.
 * @param maxlength		Maximum length of the output string buffer.
 * @return				True on success, false on invalid SteamID.
 */
native bool:SteamIDToCSteamID(String:input[], String:buffer[], maxlength);

/**
 * Do not edit below this line!
 */
public Extension:__ext_csteamid =
{
	name = "CSteamID",
	file = "csteamid.ext",
	autoload = 1,
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};
