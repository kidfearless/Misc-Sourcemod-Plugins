
#if defined __thelpers_tf2_projectiles_included
	#endinput
#endif

#define __thelpers_tf2_projectiles_included


/**
 * Entity class that all TF2 projectile entities derive from.
*/
methodmap CTFBaseRocket __nullable__ < CBaseAnimating
{
	/**
	 * Create a CTFBaseRocket instance from the given entity index.
	 *
	 * @param entIndex		The entity index to bind this methodmap to. Can be an invalid entity index.
	 *						You can use the CBaseEntity.IsValid property to check if the given entity is valid or not.
	*/
	public CTFBaseRocket( int entIndex )
	{
		return view_as<CTFBaseRocket>( new CBaseAnimating( entIndex ) );
	}


	/**
	 * Gets or sets the entity that launched this projectile.
	*/
	property CBaseEntity Launcher
	{
		public get() { return this.GetPropEnt( Prop_Send, "m_hLauncher" ); }
		public set( CBaseEntity launcher ) { this.SetPropEnt( Prop_Send, "m_hLauncher", launcher ); }
	}

	/**
	 * Gets or sets the number of times this projectile has been reflected.
	*/
	property int DeflectedCount
	{
		public get() { return this.GetProp( Prop_Send, "m_iDeflected" ); }
		public set( int count ) { this.SetProp( Prop_Send, "m_iDeflected", count ); }
	}


	/**
	 * Gets the initial launch velocity of this projectile.
	 *
	 * @param vec	Float vector buffer in which to store the velocity.
	*/
	public void GetInitialVelocity( float vec[ 3 ] )
	{
		this.GetPropVector( Prop_Send, "m_vInitialVelocity", vec );
	}
};
