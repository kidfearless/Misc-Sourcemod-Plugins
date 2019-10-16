
#if defined __thelpers_combatcharacter_included
	#endinput
#endif

#define __thelpers_combatcharacter_included

// CBaseCombatCharacter technically derives from CBaseFlex, but there likely isn't much that's useful from serverside plugins
// may revisit implementing flex if the need arises

/**
 * Entity methodmap that all combat characters derive from, including NPCs and players.
*/
methodmap CBaseCombatCharacter __nullable__ < CBaseAnimating
{
	/**
	 * Create a CBaseCombatCharacter instance from the given entity index.
	 *
	 * @param entIndex		The entity index to bind this methodmap to. Can be an invalid entity index.
	 *						You can use the CBaseEntity.IsValid property to check if the given entity is valid or not.
	*/
	public CBaseCombatCharacter( int entIndex )
	{
		return view_as<CBaseCombatCharacter>( new CBaseAnimating( entIndex ) );
	}


	/**
	 * Gets the active weapon of this entity instance.
	*/
	property CBaseCombatWeapon ActiveWeapon
	{
		public get() { return view_as<CBaseCombatWeapon>( this.GetPropEnt( Prop_Send, "m_hActiveWeapon" ) ); }
	}
};
