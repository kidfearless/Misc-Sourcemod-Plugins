enum
{
	WL_Blacklisted = -1,
	WL_None = 0,
	WL_Whitelisted = 1
};


/**
 * Returns the clients whitelist status
 *
 * @param client					Client index.
 * @Whitelist enum value
 */
native int Shavit_GetClientWhitelist(int client);