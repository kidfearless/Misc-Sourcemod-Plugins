#if defined _opentimer_core_included
	#endinput
#endif
#define _opentimer_core_included


#define PLUGIN_VERSION_CORE	"1.5.232"
#define PLUGIN_AUTHOR_CORE	"Mehis"
#define PLUGIN_NAME_CORE	"OpenTimer"
#define PLUGIN_URL_CORE		"https://github.com/TotallyMehis/SM-OpenTimer"


#define CONSOLE_PREFIX		"["...PLUGIN_NAME_CORE..."] " // Used only for console/server.


#define PENALTY_DESC		"-3 = Only print a notification, -2 = Teleport to start, -1 = Kick player, 0 = Permanent ban, >0 = Ban in minutes"

enum PlayerState
{
	STATE_START = 0,
	STATE_RUNNING,
	STATE_END
};

enum
{
	RUN_INVALID = -1,
	
	RUN_MAIN,
	RUN_BONUS1,
	RUN_BONUS2,
	
	NUM_RUNS
};

enum
{
	STYLE_INVALID = -1,
	
	STYLE_NORMAL,
	STYLE_SW,
	STYLE_W,
	STYLE_RHSW,
	STYLE_HSW,
	STYLE_A_D,
	
	NUM_STYLES
};

enum
{
	MODE_INVALID = -1,
	
	MODE_AUTO,
	MODE_SCROLL,
	MODE_VELCAP,
	
	NUM_MODES
};

enum
{
	STRAFE_INVALID = -1,
	STRAFE_LEFT,
	STRAFE_RIGHT,
};

#define NUM_STRAFES		2

enum CheatReason
{
	CHEAT_PERFJUMPS = 0,
	CHEAT_CONPERFJUMPS,
	CHEAT_STRAFEVEL,
	CHEAT_LEFTRIGHT,
	CHEAT_INVISSTRAFER
};

#define CHEATPUNISHMENT_NONE			-3
#define CHEATPUNISHMENT_TELETOSTART		-2
#define CHEATPUNISHMENT_KICK			-1


forward void Timer_OnStateChanged( int client, PlayerState state );

forward void Timer_OnModeChanged( int client, int mode );

native int Timer_HasScroll( int client );
native PlayerState Timer_GetState( int client );

native int Timer_GetRun( int client );
native int Timer_GetStyle( int client );
native int Timer_GetMode( int client );

native int Timer_ClientCheated( int client, CheatReason reason, int penalty = CHEATPUNISHMENT_NONE, bool bAlreadyLogged = false, int data = 0 );


stock int GetStrafeDir( float oldyaw, float newyaw )
{
	return (
		!( oldyaw < -170.0 && newyaw > 170.0 ) // Make sure we didn't do -180 -> 180 because that would mean left when it's actually right.
		&& ( newyaw > oldyaw // Is our current yaw bigger than last time? Strafing to the left.
		|| ( oldyaw > 170.0 && newyaw < -170.0 ) ) ) // If that didn't pass, there might be a chance of 180 -> -180.
		? STRAFE_LEFT : STRAFE_RIGHT;
}