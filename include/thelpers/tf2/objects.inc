
#if defined __thelpers_tf2_objects_included
	#endinput
#endif

#define __thelpers_tf2_objects_included


/**
 * Entity methodmap that represents all object entities in TF2 (sentries, dispensers, etc)
*/
methodmap CBaseObject __nullable__ < CBaseCombatCharacter
{
	/**
	 * Create a CBaseObject instance from the given entity index.
	 *
	 * @param entIndex		The entity index to bind this methodmap to. Can be an invalid entity index.
	 *						You can use the CBaseEntity.IsValid property to check if the given entity is valid or not.
	*/
	public CBaseObject( int entIndex )
	{
		return view_as<CBaseObject>( new CBaseCombatCharacter( entIndex ) );
	}

	/**
	 * Gets the player which built this object.
	*/
	property CTFPlayer Builder
	{
		public get() { return view_as<CTFPlayer>( this.GetPropEnt( Prop_Send, "m_hBuilder" ) ); }
	}

	/**
	 * Gets the type of object that this entity represents.
	*/
	property TFObjectType ObjectType
	{
		public get() { return TF2_GetObjectType( this.Ref ); }
	}

	/**
	 * Gets the object mode this entity is operating in.
	*/
	property TFObjectMode ObjectMode
	{
		public get() { return TF2_GetObjectMode( this.Ref ); }
	}

	/**
	 * Is this object a building?
	*/
	property bool IsBuilding
	{
		public get() { return this.GetProp( Prop_Send, "m_bBuilding" ) == 1; }
	}
	/**
	 * Is this object being placed?
	*/
	property bool IsPlacing
	{
		public get() { return this.GetProp( Prop_Send, "m_bPlacing" ) == 1; }
	}
	/**
	 * Is this object being carried?
	*/
	property bool IsCarried
	{
		public get() { return this.GetProp( Prop_Send, "m_bCarried" ) == 1; }
	}
	/**
	 * Is this object disabled?
	*/
	property bool IsDisabled
	{
		public get() { return this.GetProp( Prop_Send, "m_bDisabled" ) == 1; }
	}
	/**
	 * Is this object a disposable building?
	*/
	property bool IsDisposableBuilding
	{
		public get() { return this.GetProp( Prop_Send, "m_bDisposableBuilding" ) == 1; }
	}
	/**
	 * Is this object a mini building?
	*/
	property bool IsMiniBuilding
	{
		public get() { return this.GetProp( Prop_Send, "m_bMiniBuilding" ) == 1; }
	}

	/**
	 * Is this object being deployed after being carried?
	*/
	property bool IsCarryDeployed
	{
		public get() { return this.GetProp( Prop_Send, "m_bCarryDeploy" ) == 1; }
	}

	/**
	 * Gets a float representing the percent that this object is constructed.
	*/
	property float PercentConstructed
	{
		public get() { return this.GetPropFloat( Prop_Send, "m_flPercentageConstructed" ); }
	}

	/**
	 * Gets the upgrade level of this object.
	*/
	property int UpgradeLevel
	{
		public get() { return this.GetProp( Prop_Send, "m_iUpgradeLevel" ); }
	}
	/**
	 * Gets the upgrade metal of this object.
	*/
	property int UpgradeMetal
	{
		public get() { return this.GetProp( Prop_Send, "m_iUpgradeMetal" ); }
	}

};
