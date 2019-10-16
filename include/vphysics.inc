#if defined _sdktools_phys_included
  #endinput
#endif
#define _sdktools_phys_included

native bool:Phys_IsPhysicsObject(entity);

native bool:Phys_IsStatic(entity);
native bool:Phys_IsAsleep(entity);
native bool:Phys_IsHinged(entity);
native bool:Phys_IsCollisionEnabled(entity);
native bool:Phys_IsGravityEnabled(entity);
native bool:Phys_IsDragEnabled(entity);
native bool:Phys_IsMotionEnabled(entity);
native Phys_EnableCollisions(entity, bool:enable);
native Phys_EnableGravity(entity, bool:enable);
native Phys_EnableDrag(entity, bool:enable);
native Phys_EnableMotion(entity, bool:enable);
native Phys_Wake(entity);
native Phys_Sleep(entity);
native Phys_SetMass(entity, Float:mass);
native Float:Phys_GetMass(entity);
native Phys_SetMaterialIndex(entity, materialIndex);
native Phys_GetMaterialIndex(entity);
native Phys_BecomeHinged(entity, axis);
native Phys_RemoveHinged(entity);
native Phys_LocalToWorld(entity, Float:worldPosition[3], const Float:localPosition[3]);
native Phys_WorldToLocal(entity, Float:localPosition[3], const Float:worldPosition[3]);
native Phys_CalculateForceOffset(entity, const Float:forceVector[3], const Float:worldPosition[3], Float:centerForce[3], Float:centerTorque[3]);
native Phys_CalculateVelocityOffset(entity, const Float:forceVector[3], const Float:worldPosition[3], Float:centerVelocity[3], Float:centerAngularVelocity[3]);
native Phys_ApplyForceCenter(entity, const Float:forceVector[3]);
native Phys_ApplyTorqueCenter(entity, const Float:torque[3]);
native Phys_AddVelocity(entity, const Float:velocity[3], const Float:angularVelocity[3]);
native Phys_SetVelocity(entity, const Float:velocity[3], const Float:angularVelocity[3], bool:instantaneous = false);

native Phys_GetEnvironmentGravity(Float:gravity[3]);
native Phys_SetEnvironmentGravity(const Float:gravity[3]);
native Float:Phys_GetEnvironmentAirDensity();
native Phys_SetEnvironmentAirDensity(Float:density);

native Handle:Phys_CreateConstraintGroup(additionalIterations = 0, minErrorTicks = 15, Float:errorTolerance = 3.0);

native Handle:Phys_CreateSpring(startObject, endObject, const Float:startPos[3], const Float:endPos[3], bool:useLocalPositions, Float:naturalLength, Float:constant, Float:damping, Float:relativeDamping, bool:onlyStretch);

native Handle:Phys_CreateFixedConstraint(referenceObject, attachedObject, Handle:constraintGroup, Float:strength = 1.0, Float:forceLimit = 0.0, Float:torqueLimit = 0.0, Float:bodyMassScaleRef = 1.0, Float:bodyMassScaleAttached = 1.0, bool:isActive = true);
native Handle:Phys_CreateLengthConstraint(referenceObject, attachedObject, Handle:constraintGroup, const Float:refPosition[3], const Float:attachedPosition[3], Float:totalLength, Float:minLength = 0.0, Float:strength = 1.0, Float:forceLimit = 0.0, Float:torqueLimit = 0.0, Float:bodyMassScaleRef = 1.0, Float:bodyMassScaleAttached = 1.0, bool:isActive = true);
native Handle:Phys_CreateHingeConstraint(referenceObject, attachedObject, Handle:constraintGroup, const Float:worldPosition[3], const Float:worldAxisDirection[3], Float:minRotation = 0.0, Float:maxRotation = 0.0, Float:angularVelocity = 0.0, Float:torque = 0.0, Float:strength = 1.0, Float:forceLimit = 0.0, Float:torqueLimit = 0.0, Float:bodyMassScaleRef = 1.0, Float:bodyMassScaleAttached = 1.0, bool:isActive = true);

native Handle:Phys_CreateFrictionSnapshot(entity);
native bool:Phys_IsFrictionSnapshotValid(Handle:snapshot);
native bool:Phys_NextFrictionData(Handle:snapshot);
native Phys_GetTouchingEntity(Handle:snapshot);
native Phys_GetContactPoint(Handle:snapshot, Float:contactPoint[3]);

native Phys_GetIndexOfMaterial(const String:material[]);

forward Phys_OnObjectWake(entity);
forward Phys_OnObjectSleep(entity);

stock Phys_ApplyForceOffset(entity, const Float:forceVector[3], const Float:worldPosition[3])
{
	decl Float:centerForce[3];
	decl Float:centerTorque[3];

	Phys_CalculateForceOffset(entity, forceVector, worldPosition, centerForce, centerTorque);

	Phys_ApplyForceCenter(entity, centerForce);
	Phys_ApplyTorqueCenter(entity, centerTorque);
}

stock Phys_AddVelocityOffset(entity, const Float:forceVector[3], const Float:worldPosition[3])
{
	decl Float:centerVelocity[3];
	decl Float:centerAngularVelocity[3];

	Phys_CalculateVelocityOffset(entity, forceVector, worldPosition, centerVelocity, centerAngularVelocity);

	Phys_AddVelocity(entity, centerVelocity, centerAngularVelocity);
}

stock bool:Phys_IsTouchingEntity(entity, other)
{
	new Handle:snapshot = Phys_CreateFrictionSnapshot(entity);

	new bool:touching = false;

	while (Phys_IsFrictionSnapshotValid(snapshot))
	{
		if (Phys_GetTouchingEntity(snapshot) == other)
		{
			touching = true;
			break;
		}

		Phys_NextFrictionData(snapshot);
	}

	CloseHandle(snapshot);

	return touching;
}

/**
 * Do not edit below this line!
 */
public Extension:__ext_vphysics = 
{
	name = "VPhysics",
	file = "vphysics.ext",
	autoload = 1,
	#if defined REQUIRE_EXTENSIONS
		required = 1,
	#else
		required = 0,
	#endif
}