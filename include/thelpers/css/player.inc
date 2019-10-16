
#if defined __thelpers_css_player_included
	#endinput
#endif

#define __thelpers_css_player_included


/**
 * Entity class that all CS:S player entities derive from.
*/
methodmap CCSPlayer __nullable__ < CBasePlayer
{
	/**
	 * Create a CCSPlayer instance from the given client index.
	 *
	 * @param clientIndex	The client index to bind this methodmap to. Can be an invalid client index.
	 *						You can use the CBaseEntity.IsValid property to check if the given client is valid or not.
	*/
	public CCSPlayer( int clientIndex )
	{
		return view_as<CCSPlayer>( new CBasePlayer( clientIndex ) );
	}


	/**
	 * Gets or sets this player's MVP count.
	*/
	property int MVPCount
	{
		public get() { return CS_GetMVPCount( this.Index ); }
		public set( int count ) { CS_SetMVPCount( this.Index, count ); }
	}


	/**
	 * Gets this player's clan tag.
	 *
	 * @param buffer		Character buffer to copy clan tag into.
	 * @param maxBuffer		The maximum size of the output buffer.
	 *
	 * @return		The number of non-null bytes written to output buffer.
	*/
	public int GetClanTag( char[] buffer, int maxBuffer )
	{
		return CS_GetClientClanTag( this.Index, buffer, maxBuffer );
	}
	/**
	 * Sets this player's clan tag.
	 *
	 * @param clanTag		The clan tag to set.
	*/
	public void SetClanTag( const char[] clanTag )
	{
		CS_SetClientClanTag( this.Index, clanTag );
	}

	/**
	 * Respawns this player.
	*/
	public void Respawn()
	{
		CS_RespawnPlayer( this.Index );
	}
};
