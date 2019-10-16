#if defined _kac_included_
	#endinput
#endif
#define _kac_included_

/**
 * Logs a message to KaC/flags.log
 *
 * @param message					buffer to hold the log message.
 * @param any						format variables.
 * @noreturn
 */
native void KaC_LogMessage(const char[] format, any ...);

/**
 * Returns the clients check status against the anticheat.
 *
 * @param client					client index used for checking
 * @returns 						clients check status.
 */
native bool KaC_ShouldCheck(int client);

/**
 * Sets the clients check status for the given client index.
 *
 * @param client					client index used for checking
 * @param shouldCheck				new bool value for checking, true to check, false to ignore client.
 * @returns 						clients check status.
 */
native void KaC_SetCheck(int client, bool shouldCheck);

/**
 * Forward fired when the safety check status has changed. KaC_SetCheck fires this forward.
 *
 * @param client					client index used for checking
 * @param oldCheck					bool value of the players previous safety check.
 * @param newCheck					new bool value of the players safety check.
 * @returns 						clients check status.
 */
forward void KaC_OnSafetyCheckChanged(int client, bool oldCheck, bool newCheck);

public SharedPlugin __pl_kac =
{
	name = "KiD's antiCheat",
	file = "KaC_Core.smx",
	#if defined REQUIRE_PLUGIN
	required = 0,
	#else
	required = 0,
	#endif
};


#if !defined REQUIRE_PLUGIN
public void __pl_kac_SetNTVOptional()
{
	MarkNativeAsOptional("KaC_LogMessage");
	MarkNativeAsOptional("KaC_ShouldCheck");
	MarkNativeAsOptional("KaC_SetCheck");
}
#endif