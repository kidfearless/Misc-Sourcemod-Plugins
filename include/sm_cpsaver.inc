#if defined _sm_cpsaver_included
#endinput
#endif
#define _sm_cpsaver_included

public SharedPlugin:__pl_sm_cpsaver = 
{
	name = "sm_cpsaver",
	file = "sm_cpsaver.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

/**
 * Clear saved checkpoints for client
 * 
 * @param client				Client index.
 * @noreturn						
 * @error                       Invalid client index.
 */
native CheckpointSaver_ClearCheckpoints(client);

public __pl_sm_cpsaver_SetNTVOptional()
{
	MarkNativeAsOptional("CheckpointSaver_ClearCheckpoints");
}