
#if defined __thelpers_gamerules_included
	#endinput
#endif

#define __thelpers_gamerules_included


/**
 * Base gamerules class.
 * Note: this represents the gamerules proxy entity, but this makes no functional difference for usage.
*/
methodmap CGameRules < CBaseEntity
{
	/**
	 * Returns the gamerules proxy entity for this game, or null if the entity has not been created yet.
	*/
	public static CGameRules GetEntity()
	{
		CBaseEntity gameRulesEnt = null;

#if defined GAME_TF2
		gameRulesEnt = CBaseEntity.FindByClassname( null, "tf_gamerules" );
#elseif defined GAME_CSS || defined GAME_CSGO
		gameRulesEnt = CBaseEntity.FindByClassname( null, "cs_gamerules" );
#elseif defined GAME_DODS
		gameRulesEnt = CBaseEntity.FindByClassname( null, "dod_gamerules" );
#elseif defined GAME_HL2MP
		gameRulesEnt = CBaseEntity.FindByClassname( null, "hl2mp_gamerules" );
#elseif defined GAME_L4D || defined GAME_L4D2
		gameRulesEnt = CBaseEntity.FindByClassname( null, "terror_gamerules" );
#elseif defined GAME_DOTA
		gameRulesEnt = CBaseEntity.FindByClassname( null, "dota_gamerules" );
#else
		ThrowError( "CGameRules.GetEntity is not supported for this game!" );
#endif

		return view_as<CGameRules>( gameRulesEnt );
	}
};


/**
 * Gamerules for multiplayer games.
*/
methodmap CMultiplayRules < CGameRules
{
};


/**
 * Gamerules for teamplay based multiplayer games.
*/
methodmap CTeamplayRules < CMultiplayRules
{
};


/**
 * Gamerules for round and team based multiplayer games.
*/
methodmap CTeamplayRoundBasedRules < CTeamplayRules
{
	/**
	 * Gets the current round state of the game.
	*/
	property int RoundState
	{
		public get() { return GameRules_GetProp( "m_iRoundState" ); }
	}

	/**
	 * Is the game currently in overtime?
	*/
	property bool IsInOvertime
	{
		public get() { return GameRules_GetProp( "m_bInOvertime" ) == 1; }
	}
	/**
	 * Is the game in setup?
	*/
	property bool IsInSetup
	{
		public get() { return GameRules_GetProp( "m_bInSetup" ) == 1; }
	}
	/**
	 * Is the game currently waiting for players to connect?
	*/
	property bool IsInWaitingForPlayers
	{
		public get() { return GameRules_GetProp( "m_bInWaitingForPlayers" ) == 1; }
	}
};
