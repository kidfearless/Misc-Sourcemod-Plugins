#if defined _precache_manager_included
 #endinput
#endif
#define _precache_manager_included

// Returns the precache index for the given file path
// path must have been placed in the sourcemod/configs/precache_manager.cfg before the map is loaded
// file is case sensitive
// return -1 on failure, index on success
native int GetPrecachedIndex(char[] file);

public SharedPlugin __pl_precache_manager =
{
	name = "precache_manager",
	file = "precache_manager.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_precache_manager_SetNTVOptional()
{
	MarkNativeAsOptional("GetPrecachedIndex");
}
#endif