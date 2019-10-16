
#if defined __thelpers_entity_included
	#endinput
#endif

#define __thelpers_entity_included


// todo: does solidtype differ among games?
enum SolidType_t
{
	SOLID_NONE		= 0, // no solid model
	SOLID_BSP		= 1, // BSP tree
	SOLID_BBOX		= 2, // an AABB
	SOLID_OBB		= 3, // an OBB
	SOLID_OBB_YAW	= 4, // an OBB, constrained so that it can only yaw
	SOLID_CUSTOM	= 5, // always call into the entity for tests
	SOLID_VPHYSICS	= 6, // solid vphysics object, get vcollide from the model and collide with that
	SOLID_LAST,
};

// todo: do solid flags differ among games?
enum SolidFlags_t
{
	FSOLID_CUSTOMRAYTEST		= 0x0001,	// Ignore solid type + always call into the entity for ray tests
	FSOLID_CUSTOMBOXTEST		= 0x0002,	// Ignore solid type + always call into the entity for swept box tests
	FSOLID_NOT_SOLID			= 0x0004,	// Are we currently not solid?
	FSOLID_TRIGGER				= 0x0008,	// This is something may be collideable but fires touch functions
											// even when it's not collideable (when the FSOLID_NOT_SOLID flag is set)
	FSOLID_NOT_STANDABLE		= 0x0010,	// You can't stand on this
	SOLID_VOLUME_CONTENTS		= 0x0020,	// Contains volumetric contents (like water)
	FSOLID_FORCE_WORLD_ALIGNED	= 0x0040,	// Forces the collision rep to be world-aligned even if it's SOLID_BSP or SOLID_VPHYSICS
	FSOLID_USE_TRIGGER_BOUNDS	= 0x0080,	// Uses a special trigger bounds separate from the normal OBB
	FSOLID_ROOT_PARENT_ALIGNED	= 0x0100,	// Collisions are defined in root parent's local coordinate space
	FSOLID_TRIGGER_TOUCH_DEBRIS	= 0x0200,	// This trigger will touch debris objects
	FSOLID_MAX_BITS	= 10
};

const CBaseEntity INVALID_ENTITY = view_as<CBaseEntity>( INVALID_ENT_REFERENCE );


/**
 * Represents the base of the game entity hierarchy in the source engine
*/
methodmap CBaseEntity __nullable__
{
	/**
	 * Create an instance of the CBaseEntity methodmap from an entity index
	 *
	 * @param entIndex		The entity index to bind this methodmap to. Can be an invalid entity index.
	 *						You can use the IsValid property to check if the given entity is valid or not.
	*/
	public CBaseEntity( int entIndex )
	{
		if ( !IsValidEntity( entIndex ) )
			return INVALID_ENTITY;

		// to support logical ents, which are passed through certain forwards and callbacks as ent refs (!) rather than indexes
		// we have to first convert the reference to an actual index. this will no-op when given an index rather than a ref
		entIndex = EntRefToEntIndex( entIndex );

		return view_as<CBaseEntity>( EntIndexToEntRef( entIndex ) );
	}

	/**
	 * Gets the entity index of this entity instance.
	 * If the entity is invalid, INVALID_ENT_REFERENCE is returned instead.
	*/
	property int Index
	{
		public get() { return EntRefToEntIndex( view_as<int>( this ) ); }
	}
	/**
	 * Gets the entity reference of this entity instance.
	*/
	property int Ref
	{
		public get() { return view_as<int>( this ); }
	}

	/**
	 * Gets a value indicating if this entity is valid or not.
	*/
	property bool IsValid
	{
		public get() { return IsValidEntity( this.Ref ); }
	}


	/**
	 * Returns an integer sendprop or datamap value.
	 *
	 * @param propType		The property type.
	 * @param propName		The name of the property to get.
	 * @param size			The size of the integer property. This parameter is only used if size detection fails.
	 * @param element		The element into the array to get, if this property is an array.
	*/
	public int GetProp( PropType propType, const char[] propName, int size = 4, int element = 0 )
	{
		return GetEntProp( this.Ref, propType, propName, size, element );
	}
	/**
	 * Returns a floating point sendprop or datamap value.
	 *
	 * @param propType		The property type.
	 * @param propName		The name of the property to get.
	 * @param element		The element into the array to get, if this property is an array.
	*/
	public float GetPropFloat( PropType propType, const char[] propName, int element = 0 )
	{
		return GetEntPropFloat( this.Ref, propType, propName, element );
	}
	/**
	 * Returns an entity sendprop or datamap value.
	 *
	 * @param propType		The property type.
	 * @param propName		The name of the property to get.
	 * @param element		The element into the array to get, if this property is an array.
	*/
	public CBaseEntity GetPropEnt( PropType propType, const char[] propName, int element = 0 )
	{
		int entIndex = GetEntPropEnt( this.Ref, propType, propName, element );
		return new CBaseEntity( entIndex );
	}
	/**
	 * Returns a float vector sendprop or datamap value.
	 *
	 * @param propType		The property type.
	 * @param propName		The name of the property to get.
	 * @param vec			The vector buffer to store the value in.
	 * @param element		The element into the array to get, if this property is an array.
	*/
	public void GetPropVector( PropType propType, const char[] propName, float vec[ 3 ], int element = 0 )
	{
		GetEntPropVector( this.Ref, propType, propName, vec, element );
	}
	/**
	 * Returns a string sendprop or datamap value.
	 *
	 * @param propType		The property type.
	 * @param propName		The name of the property to get.
	 * @param buffer		The character buffer to store the value in.
	 * @param maxBuffer		The maximum size of the passed in character buffer.
	 * @param element		The element into the array to get, if this property is an array.
	 *
	 * @return	The number of non-null bytes written into the character buffer.
	*/
	public int GetPropString( PropType propType, const char[] propName, char[] buffer, int maxBuffer, int element = 0 )
	{
		return GetEntPropString( this.Ref, propType, propName, buffer, maxBuffer, element );
	}

	/**
	 * Sets an integer sendprop or datamap value.
	 *
	 * @param propType		The property type.
	 * @param propName		The name of the property to set.
	 * @param value			The value to set.
	 * @param size			The size of the integer property. This parameter is only used if size detection fails.
	 * @param element		The element into the array to set, if this property is an array.
	*/
	public void SetProp( PropType propType, const char[] propName, int value, int size = 4, int element = 0 )
	{
		SetEntProp( this.Ref, propType, propName, value, size, element );
	}
	/**
	 * Sets a floating point sendprop or datamap value.
	 *
	 * @param propType		The property type.
	 * @param propName		The name of the property to set.
	 * @param value			The value to set.
	 * @param element		The element into the array to set, if this property is an array.
	*/
	public void SetPropFloat( PropType propType, const char[] propName, float value, int element = 0 )
	{
		SetEntPropFloat( this.Ref, propType, propName, value, element );
	}
	/**
	 * Sets an entity sendprop or datamap value.
	 *
	 * @param propType		The property type.
	 * @param propName		The name of the property to set.
	 * @param value			The entity to set.
	 * @param element		The element into the array to set, if this property is an array.
	*/
	public void SetPropEnt( PropType propType, const char[] propName, CBaseEntity value, int element = 0 )
	{
		SetEntPropEnt( this.Ref, propType, propName, value.Ref, element );
	}
	/**
	 * Sets a float vector sendprop or datamap value.
	 *
	 * @param propType		The property type.
	 * @param propName		The name of the property to set.
	 * @param vec			The vector buffer value to set.
	 * @param element		The element into the array to set, if this property is an array.
	*/
	public void SetPropVector( PropType propType, const char[] propName, const float vec[ 3 ], int element = 0 )
	{
		SetEntPropVector( this.Ref, propType, propName, vec, element );
	}
	/**
	 * Sets a string sendprop or datamap value.
	 *
	 * @param propType		The property type.
	 * @param propName		The name of the property to get.
	 * @param buffer		The character buffer value to set.
	 *
	 * @return	The number of non-null bytes written into the sendprop or datamap.
	*/
	public int SetPropString( PropType propType, const char[] propName, const char[] buffer )
	{
		return SetEntPropString( this.Ref, propType, propName, buffer );
	}


	/**
	 * Gets or sets the team the current entity belongs to.
	*/
	property int Team
	{
		public get() { return this.GetProp( Prop_Send, "m_iTeamNum" ); }
		public set( int teamNum ) { this.SetProp( Prop_Send, "m_iTeamNum", teamNum ); }
	}

	/**
	 * Gets or sets this entity's health.
	*/
	property int Health
	{
		public get() { return this.GetProp( Prop_Send, "m_iHealth" ); }
		public set( int health ) { this.SetProp( Prop_Send, "m_iHealth", health ); }
	}

	/**
	 * Gets or sets this entity's gravity.
	*/
	property float Gravity
	{
		public get() { return GetEntityGravity( this.Ref ); }
		public set( float gravity ) { SetEntityGravity( this.Ref, gravity ); }
	}

	/**
	 * Gets or sets this entity's solid type.
	*/
	property SolidType_t SolidType
	{
		public get() { return view_as<SolidType_t>( this.GetProp( Prop_Send, "m_nSolidType" ) ); }
		public set( SolidType_t solidType ) { this.SetProp( Prop_Send, "m_nSolidType", view_as<int>( solidType ) ); }
	}
	/**
	 * Gets or sets this entity's solid flags.
	*/
	property SolidFlags_t SolidFlags
	{
		public get() { return view_as<SolidFlags_t>( this.GetProp( Prop_Send, "m_usSolidFlags" ) ); }
		public set( SolidFlags_t solidFlags ) { this.SetProp( Prop_Send, "m_usSolidFlags", view_as<int>( solidFlags ) ); }
	}

	/**
	 * Gets or sets this entity's owner entity.
	*/
	property CBaseEntity OwnerEntity
	{
		public get() { return this.GetPropEnt( Prop_Send, "m_hOwnerEntity" ); }
		public set( CBaseEntity owner ) { this.SetPropEnt( Prop_Send, "m_hOwnerEntity", owner ); }
	}

	/**
	 * Gets or sets this entity's render mode.
	*/
	property RenderMode RenderMode
	{
		public get() { return GetEntityRenderMode( this.Ref ); }
		public set( RenderMode mode ) { SetEntityRenderMode( this.Ref, mode ); }
	}

	/**
	 * Gets this entity's hammer id.
	*/
	property int HammerID
	{
		public get() { return this.GetProp( Prop_Data, "m_iHammerID" ); }
	}

	/**
	 * Gets the vector origin of the entity in local space (relative to the parent).
	 *
	 * @param vec		The vector buffer to store the entity origin in.
	*/
	public void GetLocalOrigin( float vec[ 3 ] )
	{
		this.GetPropVector( Prop_Send, "m_vecOrigin", vec );
	}
	/**
	 * Sets the vector origin of the entity in local space (relative to the parent).
	 *
	 * @param vec		The vector buffer to set the origin to.
	*/
	public void SetLocalOrigin( const float vec[ 3 ] )
	{
		this.SetPropVector( Prop_Send, "m_vecOrigin", vec );
	}
	/**
	 * Gets the vector angles of the entity in local space (relative to the parent).
	 *
	 * @param ang		The angle buffer to store the entity angles in.
	*/
	public void GetLocalAngles( float ang[ 3 ] )
	{
		this.GetPropVector( Prop_Send, "m_angRotation", ang );
	}
	/**
	 * Sets the vector angles of the entity in local space (relative to the parent).
	 *
	 * @param ang		The angle buffer to set the angles to.
	*/
	public void SetLocalAngles( const float ang[ 3 ] )
	{
		this.SetPropVector( Prop_Send, "m_angRotation", ang );
	}

	/**
	 * Gets the vector origin of the entity in world space.
	 *
	 * @param vec		The vector buffer to store the entity origin in.
	*/
	public void GetAbsOrigin( float vec[ 3 ] )
	{
		this.GetPropVector( Prop_Data, "m_vecAbsOrigin", vec );
	}
	/**
	 * Sets the vector origin of the entity in world space.
	 *
	 * @param vec		The vector buffer to set the origin to.
	*/
	public void SetAbsOrigin( const float vec[ 3 ] )
	{
		this.SetPropVector( Prop_Data, "m_vecAbsOrigin", vec );
	}
	/**
	 * Gets the vector angles of the entity in world space.
	 *
	 * @param ang		The angle buffer to store the entity angles in.
	*/
	public void GetAbsAngles( float ang[ 3 ] )
	{
		this.GetPropVector( Prop_Data, "m_angAbsRotation", ang );
	}
	/**
	 * Sets the vector angles of the entity in world space.
	 *
	 * @param ang		The angle buffer to set the angles to.
	*/
	public void SetAbsAngles( const float ang[ 3 ] )
	{
		this.SetPropVector( Prop_Data, "m_angAbsRotation", ang );
	}

	/**
	 * Gets the vector instantaneous velocity of this entity.
	 *
	 * @param vec		The vector buffer to store the velocity in.
	*/
	public void GetVelocity( float vec[ 3 ] )
	{
		this.GetPropVector( Prop_Data, "m_vecVelocity", vec );
	}

	/**
	 * Gets the OBB minimum extent of this entity's collision prop.
	 *
	 * @param vec		Vector buffer to store the result in.
	*/
	public void GetMins( float vec[ 3 ] )
	{
		this.GetPropVector( Prop_Send, "m_vecMins", vec );
	}
	/**
	 * Gets the OBB maximum extent of this entity's collision prop.
	 *
	 * @param vec		Vector buffer to store the result in.
	*/
	public void GetMaxs( float vec[ 3 ] )
	{
		this.GetPropVector( Prop_Send, "m_vecMaxs", vec );
	}

	/**
	 * Gets the current entity flags from this entity instance.
	 *
	 * @return	The current entity flags.
	*/
	public int GetFlags()
	{
		return GetEntityFlags( this.Ref );
	}
	/**
	 * Sets the given entity flags on this entity instance.
	 *
	 * @param	The entity flags to set.
	*/
	public void SetFlags( int flags )
	{
		SetEntityFlags( this.Ref, flags );
	}

	/**
	 * Adds the given entity flags to this entity instance.
	 *
	 * @param flags		The entity flags to add.
	*/
	public void AddFlag( int flags )
	{
		this.SetFlags( this.GetFlags() | flags );
	}
	/**
	 * Removes the given entity flags from this entity instance.
	 *
	 * @param flagsToRemove		The entity flags to remove.
	*/
	public void RemoveFlag( int flagsToRemove )
	{
		this.SetFlags( this.GetFlags() & ~flagsToRemove );
	}
	/**
	 * Clears the entity flags of this entity instance.
	*/
	public void ClearFlags()
	{
		this.SetFlags( 0 );
	}
	/**
	 * Toggles the given entity flag on this entity instance.
	 *
	 * @param flagToToggle		The entity flag to toggle.
	*/
	public void ToggleFlag( int flagToToggle )
	{
		this.SetFlags( this.GetFlags() ^ flagToToggle );
	}

	/**
	 * Spawns the entity into the game.
	 *
	 * @return		A boolean indicating if the entity was successfully spawned.
	*/
	public bool Spawn()
	{
		return DispatchSpawn( this.Ref );
	}

	/**
	 * Change an entity's origin, angles, or velocity instantly
	 *
	 * @param origin	New origin, or NULL_VECTOR for no change.
	 * @param angles	New angles, or NULL_VECTOR for no change.
	 * @param velocity	New velocity, or NULL_VECTOR for no change.
	*/
	public void Teleport( const float origin[ 3 ], const float angles[ 3 ], const float velocity[ 3 ] )
	{
		TeleportEntity( this.Ref, origin, angles, velocity );
	}

	/**
	 * Dispatch a Hammer entity key value into this entity.
	 *
	 * @param keyName		The key name of the keyvalue pair.
	 * @param value			The value of the keyvalue pair.
	 *
	 * @return		A boolean indicating if the entity has handled this key value.
	*/
	public bool KeyValue( const char[] keyName, const char[] value )
	{
		return DispatchKeyValue( this.Ref, keyName, value );
	}
	/**
	 * Dispatch a Hammer entity key value float into this entity.
	 *
	 * @param keyName		The key name of the keyvalue pair.
	 * @param value			The float value of the keyvalue pair.
	 *
	 * @return		A boolean indicating if the entity has handled this key value.
	*/
	public bool KeyValueFloat( const char[] keyName, float value )
	{
		return DispatchKeyValueFloat( this.Ref, keyName, value );
	}
	/**
	 * Dispatch a Hammer entity key value vector into this entity.
	 *
	 * @param keyName		The key name of the keyvalue pair.
	 * @param vec			The vector value of the keyvalue pair.
	 *
	 * @return		A boolean indicating if the entity has handled this key value.
	*/
	public bool KeyValueVector( const char[] keyName, const float vec[ 3 ] )
	{
		return DispatchKeyValueVector( this.Ref, keyName, vec );
	}

	/**
	 * Invokes a named entity input method on this entity. After completion, the global variant is re-initialized.
	 *
	 * @param input			The named input method to activate.
	 * @param activator		The entity which initiated the sequence of entity i/o, or null for no entity.
	 * @param caller		The entity from which this event was sent, or null for no entity.
	 * @param outputId		The unique ID of the output that this input was fired from.
	 *
	 * @return		A boolean value indicating if this input was successfully handled.
	*/
	public bool AcceptInput( const char[] input, CBaseEntity activator = view_as<CBaseEntity>( INVALID_ENT_REFERENCE ), CBaseEntity caller = view_as<CBaseEntity>( INVALID_ENT_REFERENCE ), int outputId = 0 )
	{
		int activatorRef = activator.IsValid ? activator.Ref : -1;
		int callerRef = caller.IsValid ? caller.Ref : -1;

		return AcceptEntityInput( this.Ref, input, activatorRef, callerRef, outputId );
	}

	/**
	 * Gets this entity's classname.
	 *
	 * @param classname		Buffer in which to store this entity's classname.
	 * @param maxClassname	The maximum length of the output buffer.
	 *
	 * @return		A boolean value indicating if the classname was successfully retrieved.
	*/
	public bool GetClassname( char[] classname, int maxClassname )
	{
		return GetEntityClassname( this.Ref, classname, maxClassname );
	}

	/**
	 * Sets the move parent of this entity.
	 *
	 * @param parent		The entity to parent to.
	*/
	public void SetParent( CBaseEntity parent )
	{
		SetVariantString( "!activator" );
		this.AcceptInput( "SetParent", parent );
	}
	/**
	 * Sets the attachment point of the parent entity to use. This entity should already be parented before calling this.
	 * Can optionally also maintain the current position and angle offset from the parent entity.
	 *
	 * @param attachmentName		The name of the attachment to use.
	 * @param maintainOffset		A boolean value indicating if the current position and angle offsets should be maintained.
	*/
	public void SetParentAttachment( const char[] attachmentName, bool maintainOffset = false )
	{
		SetVariantString( attachmentName );

		if ( maintainOffset )
		{
			this.AcceptInput( "SetParentAttachmentMaintainOffset" );
		}
		else
		{
			this.AcceptInput( "SetParentAttachment" );
		}
	}

	/**
	 * Gets the move parent of this entity, if any.
	*/
	public CBaseEntity GetParent()
	{
		return this.GetPropEnt( Prop_Data, "m_pParent" );
	}

	/**
	 * Dispatches a particle effect on this entity instance.
	 *
	 * @param effectName	The name of the effect to dispatch.
	*/
	public void DispatchEffect( const char[] effectName )
	{
		SetVariantString( effectName );
		this.AcceptInput( "DispatchEffect" );
	}

	/**
	 * Gets this entity's render color.
	 *
	 * @param r		The red component of the entity's color, filled by reference.
	 * @param g		The green component of the entity's color, filled by reference.
	 * @param b		The blue component of the entity's color, filled by reference.
	 * @param a		The alpha component of the entity's color, optionally filled by reference.
	*/
	public void GetRenderColor( int &r, int &g, int &b, int &a = 0 )
	{
		int color = this.GetProp( Prop_Send, "m_clrRender" );

		r = color & 0x000000FF;
		g = (color & 0x0000FF00) >> 8;
		b = (color & 0x00FF0000) >> 16;
		a = (color & 0xFF000000) >> 24;
	}
	/**
	 * Sets this entity's render color.
	 *
	 * @param r		The red component to set. Valid byte values from 0 to 255.
	 * @param g		The green component to set. Valid byte values from 0 to 255.
	 * @param b		The blue component to set. Valid byte values from 0 to 255.
	 * @param a		The optional alpha component to set. Valid byte values from 0 to 255.
	*/
	public void SetRenderColor( int r, int g, int b, int a = 255 )
	{
		SetEntityRenderColor( this.Ref, r, g, b, a );
	}


	/**
	 * Create an entity and wrap it in a CBaseEntity methodmap.
	*/
	public static CBaseEntity CreateByName( const char[] className, int forceEdictIndex = -1 )
	{
		int entIndex = CreateEntityByName( className, forceEdictIndex );
		return new CBaseEntity( entIndex );
	}

	/**
	 * Find an entity by classname and wrap the result in a CBaseEntity methodmap.
	*/
	public static CBaseEntity FindByClassname( CBaseEntity startEnt, const char[] className )
	{
		int entIndex = FindEntityByClassname( startEnt.Ref, className );
		return new CBaseEntity( entIndex );
	}
};
