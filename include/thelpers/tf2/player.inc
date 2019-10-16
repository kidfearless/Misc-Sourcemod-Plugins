
#if defined __thelpers_tf2_player_included
	#endinput
#endif

#define __thelpers_tf2_player_included


/**
 * Entity class that all TF2 player entities derive from.
*/
methodmap CTFPlayer __nullable__ < CBasePlayer
{
	/**
	 * Create a CTFPlayer instance from the given client index.
	 *
	 * @param clientIndex	The client index to bind this methodmap to. Can be an invalid client index.
	 *						You can use the CBaseEntity.IsValid property to check if the given client is valid or not.
	*/
	public CTFPlayer( int clientIndex )
	{
		return view_as<CTFPlayer>( new CBasePlayer( clientIndex ) );
	}


	/**
	 * Gets the team this player belongs to.
	*/
	property TFTeam Team
	{
		public get() { return view_as<TFTeam>( GetClientTeam( this.Index ) ); }
	}

	/**
	 * Gets the player class of this player instance.
	*/
	property TFClassType Class
	{
		public get() { return TF2_GetPlayerClass( this.Ref ); }
	}


	/**
	 * Sets the client's player class.
	 *
	 * @param class			The TF2 class to set the player to.
	 * @param persistent	If true, this sets the player's desired class so it sticks after death.
	*/
	public void SetClass( TFClassType class, bool persistent = true )
	{
		TF2_SetPlayerClass( this.Ref, class, _, persistent );
	}

	/**
	 * Changes this player's assigned team.
	 *
	 * @param team	The team to assign to this player.
	*/
	public void ChangeTeam( TFTeam team )
	{
		ChangeClientTeam( this.Index, view_as<int>( team ) );
	}

	/**
	 * Regenerate the player's class, loadout, weapons, ammo, etc.
	 * Equivalent of having a player touch a resupply cabinet.
	*/
	public void Regenerate()
	{
		TF2_RegeneratePlayer( this.Index );
	}

	/**
	 * Respawns this player.
	*/
	public void Respawn()
	{
		TF2_RespawnPlayer( this.Index );
	}

	/**
	 * Sets the custom model of this player.
	 *
	 * @param model		The model to set on this player.
	*/
	public void SetCustomModel( const char[] model )
	{
		SetVariantString( model );
		this.AcceptInput( "SetCustomModel" );
	}

};
