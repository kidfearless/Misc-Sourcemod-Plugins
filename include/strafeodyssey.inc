#if defined _strafe_core_included
  #endinput
#endif
#define _strafe_core_included


#define STRAFE_VERSION "1.0"
#define STRAFE_URL "strafeodyssey.com"

#include <strafeodyssey-stocks>

/*
* Settings definitions
*/
#define IGNORE_ADVERT	1<<0

#define DEFAULT_SETTINGS

/**
*   Gets a client's current settings
*
*   @param client		Client to get settings for.
*
*   @return           Client's settings flag
*/
native int Strafe_GetClientSettings(int client);

/**
*   Sets a user's new settings
*
*   @param client		Client to set settings for.
*   @param settings     Settings to set
*/
native void Strafe_SetClientSettings(int client, int settings);

/**
*   Reloads the core plugin's config file.
*
*   @param map          Whether to load the maps config (if exists) or the default config instead.
*/
native void Strafe_ReloadConfiguration(bool map = true);



public SharedPlugin:__pl_store =
{
	name = "servercore",
	file = "so-core.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if defined REQUIRE_PLUGIN
public __pl_store_SetNTVOptional()
{
	MarkNativeAsOptional("Strafe_GetClientSettings");
	MarkNativeAsOptional("Strafe_SetClientSettings");
	MarkNativeAsOptional("Strafe_ReloadConfiguration");
}
#endif
