
#if defined __thelpers_tf2_gamerules_included
	#endinput
#endif

#define __thelpers_tf2_gamerules_included


/**
 * TF2 gamerules class.
*/
methodmap CTFGameRules < CTeamplayRoundBasedRules
{
	/**
	 * Is king-of-the-kill currently being played?
	*/
	property bool IsPlayingKoth
	{
		public get() { return GameRules_GetProp( "m_bPlayingKoth" ) == 1; }
	}
	/**
	 * Is medieval mode currently being played?
	*/
	property bool IsPlayingMedieval
	{
		public get() { return GameRules_GetProp( "m_bPlayingMedieval" ) == 1; }
	}
	/**
	 * Is special delivery currently being played?
	*/
	property bool IsPlayingSpecialDelivery
	{
		public get() { return GameRules_GetProp( "m_bPlayingSpecialDeliveryMode" ) == 1; }
	}
	/**
	 * Is hybrid CTF/CP currently being played?
	*/
	property bool IsPlayingHybridCTFCP
	{
		public get() { return GameRules_GetProp( "m_bPlayingHybrid_CTF_CP" ) == 1; }
	}
	/**
	 * Is mann-vs-machine currently being played?
	*/
	property bool IsPlayingMvM
	{
		public get() { return GameRules_GetProp( "m_bPlayingMannVsMachine" ) == 1; }
	}
};
