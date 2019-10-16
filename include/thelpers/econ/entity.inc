
#if defined __thelpers_econ_entity_included
	#endinput
#endif

#define __thelpers_econ_entity_included


enum CBasePlayer: {};


methodmap CEconEntity __nullable__ < CBaseAnimating
{
	/**
	 * Create a CEconEntity instance from the given entity index.
	 *
	 * @param entIndex		The entity index to bind this methodmap to. Can be an invalid entity index.
	 *						You can use the CBaseEntity.IsValid property to check if the given entity is valid or not.
	*/
	public CEconEntity( int entIndex )
	{
		return view_as<CEconEntity>( new CBaseAnimating( entIndex ) );
	}


	/**
	 * Gets the item definition index of this econ entity.
	*/
	property int ItemIndex
	{
		public get() { return this.GetProp( Prop_Send, "m_iItemDefinitionIndex" ); }
	}

	/**
	 * Gets the item level of this econ entity.
	*/
	property int ItemLevel
	{
		public get() { return this.GetProp( Prop_Send, "m_iEntityLevel" ); }
	}
	/**
	 * Gets the item quality of this econ entity.
	*/
	property int ItemQuality
	{
		public get() { return this.GetProp( Prop_Send, "m_iEntityQuality" ); }
	}

	/**
	 * Gets the Steam Account ID of the owner of this econ entity.
	*/
	property int AccountID
	{
		public get() { return this.GetProp( Prop_Send, "m_iAccountID" ); }
	}


	/**
	 * Gets the player entity that owns this econ entity, if they're present on the server.
	*/
	public CBasePlayer GetOwningPlayer()
	{
		for ( int client = 1 ; client <= MaxClients ; ++client )
		{
			if ( !IsClientInGame( client ) )
				continue;

			int accountId = GetSteamAccountID( client );

			if ( accountId == 0 )
				continue; // skip clients with no auth or steamid

			if ( accountId == this.AccountID )
			{
				// NOTE: this must return the ref, since we can't construct a CBasePlayer here
				return view_as<CBasePlayer>( EntIndexToEntRef( client ) );
			}

#if 0
			// see SM bug #6188 for why we can't do this just yet
			CBasePlayer player = CBasePlayer( client );

			if ( !player.IsInGame )
				continue;

			if ( player.GetAccountID() == this.AccountID )
				return player;
#endif
		}

		return view_as<CBasePlayer>( INVALID_ENTITY );
	}

};
