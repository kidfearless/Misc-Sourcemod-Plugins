
#if defined __thelpers_client_included
	#endinput
#endif

#define __thelpers_client_included



/**
 * Entity methodmap from which all players derive from.
*/
methodmap CBasePlayer __nullable__ < CBaseCombatCharacter
{
	/**
	 * Create a CBasePlayer instance from the given client index.
	 *
	 * @param clientIndex	The client index to bind this methodmap to. Can be an invalid client index.
	 *						You can use the CBaseEntity.IsValid property to check if the given client is valid or not.
	*/
	public CBasePlayer( int clientIndex )
	{
		if ( clientIndex == 0 )
		{
			// special case for client 0 as that is the worldspawn entity, and technically not a valid client
			return view_as<CBasePlayer>( INVALID_ENTITY );
		}
		
		return view_as<CBasePlayer>( new CBaseCombatCharacter( clientIndex ) );
	}


	/**
	 * Gets the team this player belongs to.
	*/
	property int Team
	{
		public get() { return GetClientTeam( this.Index ); }
	}

	/**
	 * Gets the UserID of this player.
	*/
	property int UserID
	{
		public get() { return GetClientUserId( this.Index ); }
	}
	/**
	 * Get the unique serial number of this player.
	*/
	property int Serial
	{
		public get() { return GetClientSerial( this.Index ) ; }
	}

	/**
	 * Is this player connected to the server?
	*/
	property bool IsConnected
	{
		public get() { return IsClientConnected( this.Index ); }
	}
	/**
	 * Is this player in game?
	*/
	property bool IsInGame
	{
		public get() { return IsClientInGame( this.Index ); }
	}
	/**
	 * Is this player fully authorized by Steam?
	*/
	property bool IsAuthorized
	{
		public get() { return IsClientAuthorized( this.Index ); }
	}
	/**
	 * Is this player's connection timing out?
	*/
	property bool IsTimingOut
	{
		public get() { return IsClientTimingOut( this.Index ); }
	}

	/**
	 * Gets this player's connection time in seconds.
	*/
	property float ConnectionTime
	{
		public get() { return GetClientTime( this.Index ); }
	}

	/**
	 * Is this player in SM's kick queue?
	*/
	property bool IsInKickQueue
	{
		public get() { return IsClientInKickQueue( this.Index ); }
	}

	/**
	 * Is this player a fake client (bot)?
	*/
	property bool IsFakeClient
	{
		public get() { return IsFakeClient( this.Index ); }
	}
	/**
	 * Is this player the SourceTV client?
	*/
	property bool IsSourceTV
	{
		public get() { return IsClientSourceTV( this.Index ); }
	}
	/**
	 * Is this player the Replay client?
	*/
	property bool IsReplay
	{
		public get() { return IsClientReplay( this.Index ); }
	}

	/**
	 * Is this player alive?
	*/
	property bool IsAlive
	{
		public get() { return IsPlayerAlive( this.Index ); }
	}
	/**
	 * Is this player spectating?
	 * Note: dead players are considered spectators.
	*/
	property bool IsSpectator
	{
		public get() { return IsClientObserver( this.Index ); }
	}

	/**
	 * Gets or sets the player's default field of view.
	*/
	property int DefaultFOV
	{
		public get() { return this.GetProp( Prop_Send, "m_iDefaultFOV" ); }
		public set( int fov ) { this.SetProp( Prop_Send, "m_iDefaultFOV", fov ); }
	}
	/**
	 * Gets or sets the player's current field of view.
	*/
	property int FOV
	{
		public get() { return this.GetProp( Prop_Send, "m_iFOV" ); }
		public set( int fov ) { this.SetProp( Prop_Send, "m_iFOV", fov ); }
	}

	/**
	 * Gets or sets this player's amount of armor.
	 * Note: Not all games may support this.
	*/
	property int Armor
	{
		public get() { return this.GetProp( Prop_Send, "m_ArmorValue" ); }
		public set ( int armor ) { this.SetProp( Prop_Send, "m_ArmorValue", armor ); }
	}

	property CBaseEntity ViewEntity
	{
		public get() { return this.GetPropEnt( Prop_Data, "m_hViewEntity" ); }
		public set( CBaseEntity entity )
		{
			SetClientViewEntity( this.Index, entity.Index );
			this.SetPropEnt( Prop_Data, "m_hViewEntity", entity );
		}
	}


	/**
	 * Changes this player's assigned team.
	*/
	public void ChangeTeam( int team )
	{
		ChangeClientTeam( this.Index, team );
	}

	/**
	 * Gets the Steam Account ID of this player.
	 *
	 * @param validate		Check Steam back-end validation status.
	*/
	public int GetAccountID( bool validate = true )
	{
		return GetSteamAccountID( this.Index, validate );
	}

	/**
	 * Gets the Steam ID string of this player.
	 *
	 * @param authType		Auth id type and format to use.
	 * @param buffer		The character buffer to copy the Steam ID to.
	 * @param maxBuffer		The maximum size of the input buffer.
	 * @param validate		Check Steam back-end validation status.
	 *
	 * @return		True on success, false otherwise.
	*/
	public bool GetSteamID( AuthIdType authType, char[] buffer, int maxBuffer, bool validate = true )
	{
		return GetClientAuthId( this.Index, authType, buffer, maxBuffer, validate );
	}

	/**
	 * Gets the player's display name.
	 *
	 * @param buffer		The buffer to copy the name into.
	 * @param maxBuffer		The maximum size of the buffer.
	 *
	 * @return		True on success, false otherwise.
	*/
	public bool GetName( char[] buffer, int maxBuffer )
	{
		return GetClientName( this.Index, buffer, maxBuffer );
	}

	/**
	 * Gets the player's IP address.
	 *
	 * @param buffer		The buffer to copy the IP into.
	 * @param maxBuffer		The maximum size of the buffer.
	 * @param removePort	If true, the client's port will be excluded from the address.
	 *
	 * @return		True on success, false otherwise.
	*/
	public bool GetIP( char[] buffer, int maxBuffer, bool removePort = true )
	{
		return GetClientIP( this.Index, buffer, maxBuffer, removePort );
	}

	/**
	 * Gets the vector origin of the player in world space.
	 *
	 * @param vec		The vector buffer to store the player origin in.
	*/
	public void GetAbsOrigin( float vec[ 3 ] )
	{
		GetClientAbsOrigin( this.Index, vec );
	}
	/**
	 * Gets the vector angles of the player in world space.
	 *
	 * @param ang		The angle buffer to store the player angles in.
	*/
	public void GetAbsAngles( float ang[ 3 ] )
	{
		GetClientAbsAngles( this.Index, ang );
	}

	/**
	 * Gets the vector origin of the player's eyes in world space.
	 *
	 * @param vec		The vector buffer to store the vector origin in.
	*/
	public void GetEyePosition( float vec[ 3 ] )
	{
		GetClientEyePosition( this.Index, vec );
	}
	/**
	 * Gets the vector angles of the player's eyes in world space.
	 *
	 * @param ang		The angle buffer to store the eye angles in.
	 *
	 * @return		True on success, false otherwise.
	*/
	public bool GetEyeAngles( float vec[ 3 ] )
	{
		GetClientEyeAngles( this.Index, vec );
	}

	/**
	 * Gets the OBB minimum extent of this player's collision prop.
	 *
	 * @param vec		Vector buffer to store the result in.
	*/
	public void GetMins( float vec[ 3 ] )
	{
		GetClientMins( this.Index, vec );
	}
	/**
	 * Gets the OBB maximum extent of this player's collision prop.
	 *
	 * @param vec		Vector buffer to store the result in.
	*/
	public void GetMaxs( float vec[ 3 ] )
	{
		GetClientMaxs( this.Index, vec );
	}

	/**
	 * Gets this player's current latency in seconds.
	 *
	 * @param direction		The traffic direction.
	 *
	 * @return		The current latency, or -1 if latency information is not available.
	*/
	public float GetLatency( NetFlow direction )
	{
		return GetClientLatency( this.Index, direction );
	}
	/**
	 * Gets this player's average latency in seconds.
	 *
	 * @param direction		The traffic direction.
	 *
	 * @return		The current latency, or -1 if latency information is not available.
	*/
	public float GetAvgLatency( NetFlow direction )
	{
		return GetClientAvgLatency( this.Index, direction );
	}
	/**
	 * Gets this player's average packet loss percentage from 0 to 1.
	 *
	 * @param direction		The traffic direction.
	 *
	 * @return		The average packet loss percentage, or -1 if packet loss information is not available.
	*/
	public float GetAvgLoss( NetFlow direction )
	{
		return GetClientAvgLoss( this.Index, direction );
	}
	/**
	 * Gets this player's average packet choke percentage from 0 to 1.
	 *
	 * @param direction		The traffic direction.
	 *
	 * @return		The average packet choke percentage, or -1 if packet choke information is not available.
	*/
	public float GetAvgChoke( NetFlow direction )
	{
		return GetClientAvgChoke( this.Index, direction );
	}
	/**
	 * Get the player's average data flow in bytes/sec.
	 *
	 * @param direction		The traffic direction.
	*/
	public float GetAvgData( NetFlow direction )
	{
		return GetClientAvgData( this.Index, direction );
	}
	/**
	 * Get the player's average data flow in packets/sec.
	 *
	 * @param direction		The traffic direction.
	*/
	public float GetAvgPackets( NetFlow direction )
	{
		return GetClientAvgPackets( this.Index, direction );
	}

	/**
	 * Reconnects this client without dropping the netchannel.
	*/
	public void Reconnect()
	{
		ReconnectClient( this.Index );
	}

	/**
	 * Kicks the player from the server with the given message.
	 *
	 * @param message	The kick reason to display to the player.
	*/
	public void Kick( const char[] message )
	{
		KickClient( this.Index, "%s", message );
	}

	/**
	 * Executes a fake client command on this player.
	 *
	 * @param command	The command to execute.
	*/
	public void FakeCommand( const char[] command )
	{
		FakeClientCommand( this.Index, "%s", command );
	}
	/**
	 * Executes a client command on this player.
	 *
	 * @param command	The command to execute.
	*/
	public void Command( const char[] command )
	{
		ClientCommand( this.Index, "%s", command );
	}
};



/**
 * Helper function to get a CBasePlayer wrapper from a player of the given UserID.
*/
stock CBasePlayer Player_FromUserId( int userid )
{
	int clientIndex = GetClientOfUserId( userid );
	return new CBasePlayer( clientIndex );
}

stock CBasePlayer Player_FromSerial( int serial )
{
	int clientIndex = GetClientFromSerial( serial );
	return new CBasePlayer( clientIndex );
}
