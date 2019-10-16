
#if defined __thelpers_css_gamerules_included
	#endinput
#endif

#define __thelpers_css_gamerules_included


/**
 * CS:S gamerules class.
*/
methodmap CCSGameRules < CTeamplayRules
{
	/**
	 * Is the currently played map a bomb defusal map?
	*/
	property bool IsBombDefuseMap
	{
		public get() { return GameRules_GetProp( "m_bMapHasBombTarget" ) == 1; }
	}
	/**
	 * Is the currently played map a hostage rescue map?
	*/
	property bool IsHostageRescueMap
	{
		public get() { return GameRules_GetProp( "m_bMapHasRescueZone" ) == 1; }
	}

	/**
	 * Gets the number of currently remaining hostages.
	*/
	property int HostagesRemaining
	{
		public get() { return GameRules_GetProp( "m_iHostagesRemaining" ); }
	}
};
