#if defined _zones_manager_included
#endinput
#endif
#define _zones_manager_included

#define MAX_RADIUS_ZONES 256
#define MAX_ZONES 256

#define MAX_ZONE_NAME_LENGTH 128
#define MAX_ZONE_TYPE_LENGTH 64

#define MAX_EFFECT_NAME_LENGTH 128

#define MAX_KEY_NAME_LENGTH 128
#define MAX_KEY_VALUE_LENGTH 128

#define MAX_EFFECT_CALLBACKS 3
#define EFFECT_CALLBACK_ONENTERZONE 0
#define EFFECT_CALLBACK_ONACTIVEZONE 1
#define EFFECT_CALLBACK_ONLEAVEZONE 2

#define DEFAULT_MODELINDEX "sprites/laserbeam.vmt"
#define DEFAULT_HALOINDEX "materials/sprites/halo.vmt"

#define ZONE_TYPES 4
#define ZONE_TYPE_TRIGGER 1
#define ZONE_TYPE_CUBE 2
#define ZONE_TYPE_CIRCLE 3
#define ZONE_TYPE_POLY 4

#define ZONING_STATE_NONE 0
#define ZONING_STATE_IDLE 1
#define ZONING_STATE_DRAWING 2

#define ZONE_DRAW_HALF 0
#define ZONE_DRAW_FULL 1
#define ZONE_DRAW_NONE 2

#define ZONE_INDEX_CURRENT -1337

typedef Zones_Manager_Effect_OnEnterZone = function void(int client, int entity, StringMap values);
typedef Zones_Manager_Effect_OnActiveZone = function void(int client, int entity, StringMap values);
typedef Zones_Manager_Effect_OnLeaveZone = function void(int client, int entity, StringMap values);

/**----------------------------------------------------------*/
//Forwards

/**
 * Registers a new zone effect.
 *
 * @param name			Name of the new effect.
 * @param OnEnterZone	The function which gets called when somebody enters the zone.
 * @param OnActiveZone	The function which gets called when a client is sitting in the zone.
 * @param OnLeaveZone	The function which gets called when a client leaves the zone.
 */
native void ZonesManager_RegisterEffect(const char[] name, Zones_Manager_Effect_OnEnterZone OnEnterZone = INVALID_FUNCTION, Zones_Manager_Effect_OnActiveZone OnActiveZone = INVALID_FUNCTION, Zones_Manager_Effect_OnLeaveZone OnLeaveZone = INVALID_FUNCTION);

/**
 * Registers a new zone effect key.
 */
native void ZonesManager_RegisterEffectKey(const char[] name, const char[] effect, const char[] defaultvalue);

/**
 * Registers a new zone effect key.
 */
native void ZonesManager_RequestQueueEffects();
/**
 * Checks if an enttiy is a valid zone.
 *
 * @param entity		Zone Entity Index.
 * @return				True if a valid zone, false otherwise.
 */
native bool ZonesManager_IsValidZone(int zone);

/**
 * Clears all zone entites from the map.
 */
native void ZonesManager_ClearAllZones();

/**
 * Checks is an entity is currently inside a zone.
 *
 * @param client		Entity index.
 * @param zone			Zone Entity Index.
 * @return				True if the Entity is inside the zone, false otherwise.
 */
native bool ZonesManager_IsEntityInZone(int entity, int zone);

/**
 * Teleports a client inside a zone.
 *
 * @param client		Client Index.
 * @param zone			Zone Entity Index.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_TeleportClientToZone(int client, int zone);

/**
 * Gets a clients current look point.
 *
 * @param client		Client Index.
 * @param beam			Should the point get beamed?.
 * @param buffer		Buffer to store vector points.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_GetClientLookPoint(int client, bool beam = false, float buffer[3]);

/**
 * Gets a Zone Entity Index by its name.
 *
 * @param name			Name of the zone.
 * @return				Zone Entity Index, -1 on failure.
 */
native int ZonesManager_GetZoneByName(const char[] name);

/**
 * Gets a zone name.
 *
 * @param zone			Zone Entity Index.
 * @param buffer		Buffer to store name.
 * @param maxlength		Buffer size.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_GetZoneName(int zone, char[] buffer, int maxlength);

/**
 * Gets a zone start vector.
 *
 * @param zone			Zone Entity Index.
 * @param buffer		Buffer to store vector points.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_GetZoneStart(int zone, float buffer[3]);

/**
 * Gets a zone end vector
 * This is currently only applicable to box zones.
 *
 * @param zone			Zone Entity Index.
 * @param buffer		Buffer to store vector points.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_GetZoneEnd(int zone, float buffer[3]);

/**
 * Gets a zone circle radius.
 * This is currently only applicable to circle zones.
 *
 * @param zone			Zone Entity Index.
 * @return				Radius, -1.0 on failure.
 */
native float ZonesManager_GetZoneRadius(int zone);

/**
 * Gets a zone color values.
 *
 * @param zone			Zone Entity Index.
 * @param buffer		Buffer to store color values.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_GetZoneColor(int zone, int buffer[4]);

/**
 * Gets a zone draw type.
 *
 * @param zone			Zone Entity Index.
 * @return				Zone draw type.
 */
native int ZonesManager_GetZoneDrawType(int zone);

/**
 * Gets an arraylist of zone entities.
 *
 * @return				ArrayList of zones, null on failure.
 */
native ArrayList ZonesManager_GetZoneList();

/**
 * Gets the current zone count.
 *
 * @return				Zone count.
 */
native int ZonesManager_GetZoneCount();

/**
 * Returns true if zone is spawned and active.
 *
 * @param zone			Zone Entity Index.
 * @return				True / false.
 */
native bool ZonesManager_IsZoneActive(int zone);

/**
 * Deletes a zone safely.
 *
 * @param zone			Zone Entity Index.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_DeleteZone(int zone);

/**
 * Gets a zone type.
 *
 * @param zone			Zone Entity Index.
 * @return				Zone type, -1 on failure.
 */
native int ZonesManager_GetZoneType(int zone);

/**
 * Retrieves an arraylist of zones which has been assigned to client.
 *
 * @param client		Client Index.
 * @return				ArrayList of zones, null of failure.
 */
native ArrayList ZonesManager_GetAssignedZones(int client);

/**
 * Gets the number of points in a zone.
 * This is currently only applicable to polygon zones.
 *
 * @param zone			Zone Entity Index.
 * @return				Number of points.
 */
native int ZonesManager_GetZonePointsCount(int zone);

/**
 * Gets the zone points as an ArrayList.
 * This is currently only applicable to polygon zones.
 *
 * @param zone			Zone Entity Index.
 * @return				Arraylist of points, null on failure.
 */
native ArrayList ZonesManager_GetZonePoints(int zone);

/**
 * Gets the point heights of a zone.
 * This is currently only applicable to polygon zones.
 *
 * @param zone			Zone Entity Index.
 * @return				Point height.
 */
native float ZonesManager_GetZonePointHeight(int zone);

/**
 * Gets the lowest corner of a zone.
 *
 * @param zone			Zone Entity Index.
 * @return				Lowest Corner, -1.0 on failure.
 */
native float ZonesManager_GetZoneLowestCorner(int zone);

/**
 * Gets the highest corner of a zone.
 *
 * @param zone			Zone Entity Index.
 * @return				Highest Corner, -1.0 on failure.
 */
native float ZonesManager_GetZoneHighestCorner(int zone);

/**
 * Gets the Teleport location of a zone.
 *
 * @param zone			Zone Entity Index.
 * @param location		Buffer to store location.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_GetZoneTeleportLocation(int zone, float location[3]);

/**
 * Checks if a vector of points is inside zone.
 *
 * @param zone			Zone Entity Index.
 * @param origin		Vector origin.
 * @return				True / false.
 */
native float ZonesManager_IsVectorInsideZone(int zone, float origin[3]);

/**
 * Starts a zone creation.
 *
 * @param type			Zone type.
 * @param name			Zone name.
 * @return				Index of the newly created zone.
 */
native int ZonesManager_StartZone(int type, const char[] name);

/**
 * Registers an existing trigger_* as a zone.
 *
 * @param zone			Trigger Entity Index.
 * @param name			Zone name.
 * @return				True if successful, false otherwise.
 */
native int ZonesManager_RegisterTrigger(int zone, const char[] name)

/**
 * Sets the current zoning state for a zone on the client.
 *
 * @param client		Client Index.
 * @param zone			Zone Entity Index.
 * @param state			Zoning state.
 * @return				True if successful, false otherwise.
 */
native int ZonesManager_SetZoningState(int client, int zone, int state)

/**
 * Gets the current zoning state for a zone on the client.
 *
 * @param client		Client Index.
 * @param zone			Zone Entity Index.
 * @return				Zoning state or ZONING_STATE_NONE on failure.
 */
native int ZonesManager_GetZoningState(int client, int zone)

/**
 * Assigns zone creation to a client.
 *
 * @param client		Client Index.
 * @param zone			Zone Entity Index.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_AssignZone(int client, int zone);

/**
 * Unassigns zone creation from a client.
 *
 * @param client		Client Index.
 * @param zone			Zone Entity Index.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_UnAssignZone(int client, int zone);

/**
 * Sets a zones name.
 *
 * @param zone			Zone Entity Index.
 * @param name			Zone name.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_SetZoneName(int zone, const char[] name);

/**
 * Sets a zones start point.
 *
 * @param zone			Zone Entity Index.
 * @param start			Start vector.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_SetZoneStart(int zone, float buffer[3]);

/**
 * Sets a zones end point.
 * This is currently only applicable to box zones.
 *
 * @param zone			Zone Entity Index.
 * @param end			End vector.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_SetZoneEnd(int zone, float end[3]);

/**
 * Sets a zones end point.
 * This is currently only applicable to circle zones.
 *
 * @param zone			Zone Entity Index.
 * @param radius		Radius of the circle.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_SetZoneRadius(int zone, float radius);

/**
 * Sets a zones color.
 * This uses decimal RGB color codes where 0 is R, 1 is G, 2 is B and 3 is alpha.
 *
 * @param zone			Zone Entity Index.
 * @param color			Array of decimal RGB colors.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_SetZoneColor(int zone, int color[4]);

/**
 * Sets a zones draw type.
 * ZONE_DRAW_HALF or ZONE_TYPE_FULL.
 *
 * @param zone			Zone Entity Index.
 * @param drawtypee		Zone draw type.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_SetZoneDrawType(int zone, int drawtype = ZONE_DRAW_HALF);

/**
 * Sets a zones height.
 * This is currently only applicable to polygon and circle zones.
 *
 * @param zone			Zone Entity Index.
 * @param height		Height of the zone points.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_SetZoneHeight(int zone, float height);

/**
 * Adds a point to a zone.
 * This is currently only applicable to polygon zones.
 *
 * @param zone			Zone Entity Index.
 * @param point			Point vector to add.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_AddZonePoint(int zone, float point[3]);

/**
 * Adds a list of point to a zone.
 * This is currently only applicable to polygon zones.
 *
 * @param zone			Zone Entity Index.
 * @param points		ArrayList of points to add.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_AddMultipleZonePoints(int zone, ArrayList points);

/**
 * Removes a point from a zone.
 * This is currently only applicable to polygon zones.
 *
 * @param zone			Zone Entity Index.
 * @param points		Point vector to remove.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_RemoveZonePoint(int zone, float point[3]);

/**
 * Removes the last point added to a zone.
 * This is currently only applicable to polygon zones.
 *
 * @param zone			Zone Entity Index.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_RemoveLastZonePoint(int zone);

/**
 * Remove a list of point from a zone.
 * This is currently only applicable to polygon zones.
 *
 * @param zone			Zone Entity Index.
 * @param points		ArrayList of points to remove.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_RemoveMultipleZonePoints(int zone, ArrayList points);

/**
 * Remove all points from a zone.
 * This is currently only applicable to polygon zones.
 *
 * @param zone			Zone Entity Index.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_RemoveAllZonePoints(int zone);

/**
 * Finishes a zone creation and spawns it into the world.
 * This should be called after initializing the zone with the other natives.
 *
 * @param zone			Zone Entity Index.
 * @return				Entity index of the zone, -1 on failure.
 */
native int ZonesManager_FinishZone(int zone);

/**
 * Gets a KeyValues object with zone data.
 * This should be called after initializing the zone with the other natives.
 * You must delete the KV Object when you are finished with it.
 *
 * @param zone			Zone Entity Index.
 * @return				KeyValues with zone info, null on failure.
 */
native KeyValues ZonesManager_GetZoneKeyValues(int zone);

/**
 * Gets a KeyValues string with zone data.
 * This should be called after initializing the zone with the other natives.
 *
 * @param zone			Zone Entity Index.
 * @return				KeyValues with zone info, null on failure.
 */
native KeyValues ZonesManager_GetZoneKeyValuesAsString(int zone, char[] buffer);

/**
 * Creates a zone (Advanced).
 * This is useful when loading existing zones which you may have saved.
 * This function assumes you know what you are doing and does not do any error checking!
 *
 * @param type			Type of the zone.
 * @param name			Zone name.
 * @param start			Start vector.
 * @param end			End vector (Currently only applicable to box zones).
 * @param radius		Zone radius (Currently only applicable to circle zones).
 * @param color			Zone color (This uses decimal RGB color codes where 0 is R, 1 is G, 2 is B and 3 is alpha).
 * @param drawtype		Zone draw type (ZONE_DRAW_HALF or ZONE_DRAW_FULL).
 * @param points		ArrayList of zone points (Currently only applicable to polygon zones).
 * @param height		Height of zone points (Currently only applicable to polygon zones).
 * @param effects		ArrayList of effects for the zone.
 * @return				Entity index of the zone, -1 on failure.
 */
native int ZonesManager_CreateZoneAdvanced(int type, const char[] name, float start[3], float end[3] =  { -1.0, -1.0, -1.0 }, float radius = -1.0, int color[4] =  { 255, 255, 0, 255 }, int drawtype = ZONE_DRAW_HALF, ArrayList points = null, float height = 256.0, StringMap effects = null);

/**
 * Loads a zone from KeyValues string..
 *
 * @param buffer		Buffer to KeyValues string.
 * @return				Entity index of the zone, -1 on failure.
 */
native int ZonesManager_CreateZoneFromKeyValuesString(const char[] buffer);

/**
 * Adds an effect to the zone.
 *
 * @param zone			Zone Entity Index.
 * @param effect		Name of effect to add.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_AddZoneEffect(int zone, const char[] name);

/**
 * Removes an effect from the zone.
 *
 * @param zone			Zone Entity Index.
 * @param effect		Name of effect to remove.
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_RemoveZoneEffect(int zone, const char[] name);

/**
 * Hides a zone Beam from a client.
 * @param client		Client Index.
 * @param zone			Zone Entity Index.
 *
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_HideZoneFromClient(int client, int zone);

/**
 * Shows a zone Beam to everyone.
 * @param client		Client Index.
 * @param zone			Zone Entity Index.
 *
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_UnHideZoneFromClient(int client, int zone);

/**
 * Forces a zone Beam to show to a client even if he is not standing in it.
 * @param client		Client Index.
 * @param zone			Zone Entity Index.
 *
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_ForceZoneRenderingToClient(int client, int zone);

/**
 * Removes forcing a zone Beam to show to a client.
 * @param client		Client Index.
 * @param zone			Zone Entity Index.
 *
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_UnForceZoneRenderingToClient(int client, int zone);

/**
 * Hooks an entity to be processed in a zone.
 * This does not need to be called on player or other zone entities.
 * @param entity		Entity Index.
 * @param zone			Zone Entity Index.
 *
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_Hook(int entity, int zone);

/**
 * UnHooks an entity being processed in a zone.
 * This does not need to be called on player or other zone entities.
 * @param entity		Entity Index.
 * @param zone			Zone Entity Index.
 *
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_UnHook(int entity, int zone);

/**
 * Hooks an entity to be processed in a globally in all zones.
 * This does not need to be called on player or other zone entities.
 * @param client		Client Index.
 * @param zone			Zone Entity Index.
 *
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_HookGlobal(int entity);

/**
 * UnHooks an entity being processed globally in all zones.
 * This does not need to be called on player or other zone entities.
 * @param client		Client Index.
 * @param zone			Zone Entity Index.
 *
 * @return				True if successful, false otherwise.
 */
native bool ZonesManager_UnHookGlobal(int entity);

/**----------------------------------------------------------*/
//Forwards

/**
 * Called whenever the plugin requests for effects to be registered.
 * You should use this post forward to register new effects.
**/
forward void ZonesManager_OnQueueEffects_Post();

/**
 * Called right before an entity enters the zone.
 *
 * @param entity			Entity Index.
 * @param zone          	Entity index for this zone.
 * @param name				Name of the zone.
 * @param type            	Type of zone.
 * @return                	Plugin_Handled or Plugin_Stop = stops post forward counterpart from firing.
**/
forward Action ZonesManager_OnStartTouchZone(int entity, int zone, const char[] name, int type);

/**
 * Called right before each tick while an entity is in a zone.
 *
 * @param entity			Entity Index.
 * @param zone          	Entity index for this zone.
 * @param name				Name of the zone.
 * @param type            	Type of zone.
 * @return              	Plugin_Handled or Plugin_Stop = stops post forward counterpart from firing.
**/
forward Action ZonesManager_OnTouchZone(int entity, int zone, const char[] name, int type);

/**
 * Called right before once an entity leaves the zone.
 *
 * @param entity			Entity Index.
 * @param zone          	Entity index for this zone.
 * @param name				Name of the zone.
 * @param type            	Type of zone.
 * @return                	Plugin_Handled or Plugin_Stop = stops post forward counterpart from firing.
**/
forward Action ZonesManager_OnEndTouchZone(int entity, int zone, const char[] name, int type);

/**
 * Called right after an entity enters the zone.
 *
 * @param entity			Entity Index.
 * @param zone          	Entity index for this zone.
 * @param name				Name of the zone.
 * @param type            	Type of zone.
**/
forward void ZonesManager_OnStartTouchZone_Post(int entity, int zone, const char[] name, int type);

/**
 * Called right after each tick while an entity is in a zone.
 *
 * @param entity			Entity Index.
 * @param zone          	Entity index for this zone.
 * @param name				Name of the zone.
 * @param type            	Type of zone.
**/
forward void ZonesManager_OnTouchZone_Post(int entity, int zone, const char[] name, int type);

/**
 * Called right after once an entity leaves the zone.
 *
 * @param entity			Entity Index.
 * @param zone          	Entity index for this zone.
 * @param name				Name of the zone.
 * @param type            	Type of zone.
**/
forward void ZonesManager_OnEndTouchZone_Post(int entity, int zone, const char[] name, int type);

/**
 * Called right after a zone has been hooked / spawned.
 *
 * @param zone				Zone Entity Index.
 * @param zonetype          Zone Type.
 * @param name				Name of the zone.
 * @param start            	Zone start vector.
 * @param end            	Zone end vector.
 * @param radius            Zone radius.
 * @param height            Zone height.
 * @param color             Zone color.
 * @param drawtype          Zone draw type.
 * @param drawtype          Zone points.
 * @param effects         	Zone effects.
**/
forward void ZonesManager_OnZoneSpawned(int zone, int zonetype, const char[] name, float start[3], float end[3], float radius, float height, int color[4], int drawtype, ArrayList points, StringMap effects);

#if !defined REQUIRE_PLUGIN
public void __pl_zones_manager_SetNTVOptional()
{
	MarkNativeAsOptional("ZonesManager_RequestQueueEffects");
	MarkNativeAsOptional("ZonesManager_SaveZones");
	MarkNativeAsOptional("ZonesManager_IsValidZone");
	MarkNativeAsOptional("ZonesManager_ClearAllZones");
	MarkNativeAsOptional("ZonesManager_IsEntityInZone");
	MarkNativeAsOptional("ZonesManager_AssignZone");
	MarkNativeAsOptional("ZonesManager_UnAssignZone");
	MarkNativeAsOptional("ZonesManager_SetZoningState");
	MarkNativeAsOptional("ZonesManager_GetZoningState");
	MarkNativeAsOptional("ZonesManager_GetAssignedZones");
	MarkNativeAsOptional("ZonesManager_GetZonePointsCount");
	MarkNativeAsOptional("ZonesManager_GetZonePoints");
	MarkNativeAsOptional("ZonesManager_GetZonePointHeight");
	MarkNativeAsOptional("ZonesManager_GetZoneByName");
	MarkNativeAsOptional("ZonesManager_GetZoneName");
	MarkNativeAsOptional("ZonesManager_GetZoneStart");
	MarkNativeAsOptional("ZonesManager_GetZoneEnd");
	MarkNativeAsOptional("ZonesManager_GetZoneRadius");
	MarkNativeAsOptional("ZonesManager_GetZoneColor");
	MarkNativeAsOptional("ZonesManager_GetZoneDrawType");
	MarkNativeAsOptional("ZonesManager_GetZoneList");
	MarkNativeAsOptional("ZonesManager_GetZoneCount");
	MarkNativeAsOptional("ZonesManager_IsZoneActive");
	MarkNativeAsOptional("ZonesManager_DeleteZone");
	MarkNativeAsOptional("ZonesManager_GetZoneType");
	MarkNativeAsOptional("ZonesManager_GetZoneLowestCorner");
	MarkNativeAsOptional("ZonesManager_GetZoneHighestCorner");
	MarkNativeAsOptional("ZonesManager_GetZoneTeleportLocation");
	MarkNativeAsOptional("ZonesManager_IsVectorInsideZone");
	MarkNativeAsOptional("ZonesManager_TeleportClientToZone");
	MarkNativeAsOptional("ZonesManager_GetClientLookPoint");
	MarkNativeAsOptional("ZonesManager_RegisterEffect");
	MarkNativeAsOptional("ZonesManager_RegisterEffectKey");
	MarkNativeAsOptional("ZonesManager_CreateZoneAdvanced");
	MarkNativeAsOptional("ZonesManager_CreateZoneFromKeyValuesString");
	MarkNativeAsOptional("ZonesManager_RegisterTrigger");
	MarkNativeAsOptional("ZonesManager_StartZone");
	MarkNativeAsOptional("ZonesManager_SetZoneName");
	MarkNativeAsOptional("ZonesManager_SetZoneStart");
	MarkNativeAsOptional("ZonesManager_SetZoneEnd");
	MarkNativeAsOptional("ZonesManager_SetZoneRadius");
	MarkNativeAsOptional("ZonesManager_SetZoneColor");
	MarkNativeAsOptional("ZonesManager_SetZoneDrawType");
	MarkNativeAsOptional("ZonesManager_SetZoneHeight");
	MarkNativeAsOptional("ZonesManager_AddZonePoint");
	MarkNativeAsOptional("ZonesManager_AddMultipleZonePoints");
	MarkNativeAsOptional("ZonesManager_RemoveZonePoint");
	MarkNativeAsOptional("ZonesManager_RemoveLastZonePoint");
	MarkNativeAsOptional("ZonesManager_RemoveMultipleZonePoints");
	MarkNativeAsOptional("ZonesManager_RemoveAllZonePoints");
	MarkNativeAsOptional("ZonesManager_AddZoneEffect");
	MarkNativeAsOptional("ZonesManager_RemoveZoneEffect");
	MarkNativeAsOptional("ZonesManager_FinishZone");
	MarkNativeAsOptional("ZonesManager_GetZoneKeyValues");
	MarkNativeAsOptional("ZonesManager_GetZoneKeyValuesAsString");
	MarkNativeAsOptional("ZonesManager_ForceZoneRenderingToClient");
	MarkNativeAsOptional("ZonesManager_UnForceZoneRenderingToClient");
	MarkNativeAsOptional("ZonesManager_HideZoneFromClient");
	MarkNativeAsOptional("ZonesManager_UnHideZoneFromClient");
	MarkNativeAsOptional("ZonesManager_Hook");
	MarkNativeAsOptional("ZonesManager_HookGlobal");
	MarkNativeAsOptional("ZonesManager_UnHook");
	MarkNativeAsOptional("ZonesManager_UnHook");
	MarkNativeAsOptional("ZonesManager_UnHookGlobal");
}
#endif

public SharedPlugin __pl_zones_manager = 
{
	name = "zones_manager_core", 
	file = "zones_manager_core.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};
