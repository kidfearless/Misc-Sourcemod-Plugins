
#if defined __thelpers_combatweapon_included
	#endinput
#endif

#define __thelpers_combatweapon_included


// games which use econ have their weapons derive from CEconEntity
#if defined GAME_ECON
	#define THELPERS_COMBATWEAPON_DERIVED_FROM CEconEntity
#else
	#define THELPERS_COMBATWEAPON_DERIVED_FROM CBaseAnimating
#endif


/**
 * Entity methodmap from which all weapon entities derive from.
*/
methodmap CBaseCombatWeapon < THELPERS_COMBATWEAPON_DERIVED_FROM
{
	/**
	 * Create a CBaseCombatWeapon instance from the given entity index.
	 *
	 * @param entIndex		The entity index to bind this methodmap to. Can be an invalid entity index.
	 *						You can use the CBaseEntity.IsValid property to check if the given entity is valid or not.
	*/
	public CBaseCombatWeapon( int entIndex )
	{
		return view_as<CBaseCombatWeapon>( new CBaseAnimating( entIndex ) );
	}


	// todo
};
