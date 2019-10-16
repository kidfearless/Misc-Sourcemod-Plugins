
#if defined __thelpers_animating_included
	#endinput
#endif

#define __thelpers_animating_included


/**
 * Entity methodmap from which all entities with models or animations inherit.
 * This methodmap also implements functionality related to CBaseAnimatingOverlay.
*/
methodmap CBaseAnimating __nullable__ < CBaseEntity
{
	/**
	 * Create a CBaseAnimating instance from the given entity index.
	 *
	 * @param entIndex		The entity index to bind this methodmap to. Can be an invalid entity index.
	 *						You can use the CBaseEntity.IsValid property to check if the given entity is valid or not.
	*/
	public CBaseAnimating( int entIndex )
	{
		return view_as<CBaseAnimating>( new CBaseEntity( entIndex ) );
	}


	/**
	 * Gets or sets the current texture skin of this entity instance.
	*/
	property int Skin
	{
		public get() { return this.GetProp( Prop_Send, "m_nSkin" ); }
		public set( int skin ) { this.SetProp( Prop_Send, "m_nSkin", skin ); }
	}
	/**
	 * Gets or sets the current body group of this entity instance.
	*/
	property int Body
	{
		public get() { return this.GetProp( Prop_Send, "m_nBody" ); }
		public set( int body ) { this.SetProp( Prop_Send, "m_nBody", body ); }
	}
	/**
	 * Gets or instantly sets the model scale of this entity instance.
	*/
	property float ModelScale
	{
		public get() { return this.GetPropFloat( Prop_Send, "m_flModelScale" ); }
		public set( float scale ) { this.SetPropFloat( Prop_Send, "m_flModelScale", scale ); }
	}


	/**
	 * Sets the current model of this entity instance.
	 *
	 * @param model		The model path to set the current model to.
	*/
	public void SetModel( const char[] model )
	{
		SetEntityModel( this.Ref, model );
	}
	/**
	 * Gets the current model of this entity instance.
	 *
	 * @param buffer		The character buffer to store the current model path into. Ideally should be PLATFORM_MAX_PATH characters long.
	 * @param maxBuffer		The maximum length of the input buffer.
	 *
	 * @return		The number of non-null characters written into the input buffer.
	*/
	public int GetModel( char[] buffer, int maxBuffer )
	{
		return this.GetPropString( Prop_Data, "m_ModelName", buffer, maxBuffer );
	}

	/**
	 * Sets the model scale of this entity instance, with an optional length over which to interpolate the scaling.
	 *
	 * @param scale			The model scale to set.
	 * @param changeTime	The time in seconds over which the model will reach the given scale, or 0.0 to scale instantly.
	*/
	public void SetModelScale( float scale, float changeTime = 0.0 )
	{
		float inputVec[ 3 ];
		inputVec[ 0 ] = scale;
		inputVec[ 1 ] = changeTime;

		SetVariantVector3D( inputVec );
		this.AcceptInput( "SetModelScale" );
	}
};
