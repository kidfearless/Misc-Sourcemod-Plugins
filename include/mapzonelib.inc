#if defined _mapzonelib_included
  #endinput
#endif
#define _mapzonelib_included

/**
 * Maximal length of a zone group's name.
 */
#define MAX_ZONE_GROUP_NAME 64

/**
 * Maximal length of a zone's name.
 */
#define MAX_ZONE_NAME 64

/**
 * If the zone is composed out of several zones or stands alone.
 */
enum MapZoneType
{
	MapZoneType_Zone,
	MapZoneType_Cluster
};

/**
 * Who the zone is showed to.
 */
enum ZoneVisibility
{
	ZoneVisibility_WhenEditing, // Show zone when the zone editing menu is open. This is the default and will always be the case even if admins only is set as visibility.
	ZoneVisibility_AdminsOnly,  // Show zones to admins only.
	ZoneVisibility_Everyone     // Always show the zone to everyone.
};

/**
 * List of options to hide certain options from menus in a zone group.
 * @see MapZone_SetGroupMenuHideFlags
 */
enum MenuHideFlag
{
	HideFlag_None = 0,
	HideFlag_Visibility = 1,               // Hide the "Zone visibility" option from the edit menus.
	HideFlag_TeamFilter = 2,               // Hide the "Team filter" option from the edit menus.
	HideFlag_Clipboard = 4,                // Hide the Copy & Paste options from the menus.
	HideFlag_Dimensions = 8,               // Hide the "Display dimensions" option from the edit menus.
	HideFlag_Rename = 16,                  // Hide the "Rename" option from the edit menu.

	// If both cluster delete flags are set, the "Delete" menu option isn't shown at all.
	HideFlag_ClusterDeleteZones = 32,      // Hide the "delete cluster and all contained zones" option from cluster delete menu.
	HideFlag_ClusterDontDeleteZones = 64   // Hide the "delete cluster, but keep all contained zones" option from cluster delete menu.
};

/**
 * How to draw the zone beams.
 */
enum DisplayDimensions
{
	Dimension_1D, // Only show a single line between the two points of the zone.
	Dimension_2D, // Draw the lower rectangle of the box on the ground only.
	Dimension_3D  // Draw a full 3D box defining the zone.
};

/**
 * Register a new group of zones.
 * Zones created in this group will be saved in a 
 * seperate folder in "configs/mapzonelib/<group>/mapname.zones".
 *
 * If there already are zones saved for that group, they are loaded.
 *
 * @param group    The name of the group.
 */
native void MapZone_RegisterZoneGroup(const char[] group);

/**
 * Shows the zone editing admin menu to a client.
 * The client will be able to add, modify and remove
 * zones in the group.
 *
 * @param client   The client index.
 * @param group    The zone group name.
 * @return         True if menu was shown, false if no zone group with that name.
 */
native bool MapZone_ShowMenu(int client, const char[] group);

/**
 * Show the edit menu of a zone or cluster right away.
 *
 * @param client                The client index.
 * @param group                 The zone group name.
 * @param zoneName              The name of the zone or cluster.
 * @param bEnableCancelForward  Call the menu cancel forward when going back from this edit menu
 *                              instead of the zone list? Ignored if no menu cancel callback registered.
 *                              @see MapZone_SetMenuCancelAction
 */
native void MapZone_ShowZoneEditMenu(int client, const char[] group, const char[] zoneName, bool bEnableCancelForward = false);

/**
 * Called when a client selects the "Back" option in
 * the zone group's root menu.
 * Can be used to make the transition back into your own
 * menu hierachy.
 *
 * @param client   The client index.
 * @param reason   The reason why the menu got cancelled. One of the default MenuCancel_* values.
 * @param group    The zone group name.
 * @noreturn
 */
typedef MapZoneMenuCancelCB = function void (int client, int reason, const char[] group);

/**
 * Register for the cancel action of the zone group menu.
 * Whenever a client cancels the menu or wants to go back from the zone menus,
 * you're able to show your own menus again or do other cleanup using this callback.
 *
 * @param group    The zone group name.
 * @param callback The callback function to call when the zone root menu is cancelled.
 * @return True if callback registered, false if no zone group with that name.
 */
native bool MapZone_SetMenuCancelAction(const char[] group, MapZoneMenuCancelCB callback);

/**
 * Called when a zone is about to be displayed before default checks are executed.
 * Can be used to override the visibility setting for that zone 
 * by changing the bShowZone parameter and returning > Plugin_Continue.
 *
 * This is called for every single zone seperately, even if they are in a cluster.
 *
 * @param client       The client index.
 * @param iVisibility  The configured visibility setting of the zone.
 * @param group        The zone group name.
 * @param zoneName     The name of the zone.
 * @param bShowZone    In parameter - Set whether to show the zone to the client or not.
 * @return             Plugin_Continue to use default behavior of visibility setting, something else to use bShowZone.
 */
typedef MapZoneVisibilityOverrideCB = function Action (int client, ZoneVisibility iVisibility, const char[] group, const char[] zoneName, bool &bShowZone);

/**
 * Register a callback to override who can see a zone when it's about to be shown.
 *
 * @param group     The zone group name.
 * @param callback  The callback function to call when a zone is about to be shown to client.
 * @return          True if the callback registered, false if no zone group with that name or registration failed.
 */
native bool MapZone_AddZoneVisibilityOverrideHandler(const char[] group, MapZoneVisibilityOverrideCB callback);

/**
 * Add a new cluster to that zone group.
 *
 * @param group         The zone group name.
 * @param sClusterName  The name of the new cluster.
 * @param iAdmin        Optional: Client index of admin who added the cluster.
 * @error               There already exists a zone, cluster with that name or invalid client index.
 */
native void MapZone_AddCluster(const char[] group, const char[] sClusterName, int iAdmin=0);

/**
 * Start adding a zone in a zone group. Opens the edit menu afterwards.
 *
 * @param client                The client index.
 * @param group                 The zone group name.
 * @param bEnableCancelForward  Call the menu cancel forward when aborting the add or going 
 *                              back from the edit menu instead of the zone list?
 *                              Ignored if no menu cancel callback registered.
 *                              @see MapZone_SetMenuCancelAction
 * @param sClusterName          Optional: The name of the cluster this zone should be added to.
 * @error                       Invalid group name, invalid client index, invalid cluster name.
 */
native void MapZone_StartAddingZone(int client, const char[] group, bool bEnableCancelForward = false, const char[] sClusterName = "");

/**
 * Set the default name of new zones/clusters created by the client from "Zone X" to something else.
 * A number starting from 1 is appended to the name if it is already taken.
 *
 * @param client                The client index.
 * @param group                 The zone group name.
 * @param sBaseName             Name of new zones which will be appended by a number to distinguish duplicates.
 * @param bAutoName             Name new zones or clusters based on this name automatically instead of asking for a name.
 * @error                       Invalid client index or invalid group name.
 */
native void MapZone_SetNewZoneBaseName(int client, const char[] group, const char[] sBaseName, bool bAutoName);

/**
 * Delete a zone or cluster from a group.
 *
 * @param group              The zone group name.
 * @param zoneName           The name of the zone.
 * @param bDeleteChildZones  Delete all zones contained in the cluster? (Ignored if not a cluster.)
 * @param iAdmin             Blame the deletion of the zone on this client.
 * @error                    Invalid group or zone name, invalid admin client index.
 */
native void MapZone_DeleteZone(const char[] group, const char[] zoneName, bool bDeleteChildZones=false, int iAdmin=0);

/**
 * Set the default color of the zone beams for this group.
 *
 * @param group   The zone group name.
 * @param iColor  The RGBA colors of the laser.
 * @return        True if set, false if no zone group with that name.
 */
native bool MapZone_SetZoneDefaultColor(const char[] group, const int iColor[4]);

/**
 * Set the color of the zone.
 *
 * @param group     The zone group name.
 * @param zoneName  The zone or cluster name.
 * @param iColor    The RGBA colors of the laser.
 * @return          True if set, false if no zone group or zone with that name.
 */
native bool MapZone_SetZoneColor(const char[] group, const char[] zoneName, const int iColor[4]);

/**
 * Set the visibility of the zone or cluster.
 * 
 * @param group        The zone group name.
 * @param zoneName     The zone or cluster name.
 * @param iVisibility  The new visibility setting of the zone.
 * @return             True if set, false if no zone group or zone with that name.
 */
native bool MapZone_SetZoneVisibility(const char[] group, const char[] zoneName, ZoneVisibility iVisibility);

/**
 * Returns how many dimensions of the zone should be shown.
 * @see DisplayDimensions
 *
 * @param group        The zone group name.
 * @param zoneName     The zone or cluster name.
 * @return             The amount of dimensions to draw the zone in (1D, 2D or 3D).
 * @error              No zone group or zone/cluster with that name.
 */
native DisplayDimensions MapZone_GetZoneDisplayDimensions(const char[] group, const char[] zoneName);

/**
 * Set how many dimensions of the zone should be shown.
 * @see DisplayDimensions
 *
 * @param group        The zone group name.
 * @param zoneName     The zone or cluster name.
 * @param iDimension   The amount of dimensions to draw the zone in (1D, 2D or 3D).
 * @return             True if set, false if no zone group or zone with that name.
 */
native bool MapZone_SetZoneDisplayDimensions(const char[] group, const char[] zoneName, DisplayDimensions iDimension);

/**
 * Returns the MenuHideFlags for a zone group.
 *
 * @param group        The zone group name.
 * @return             The MenuHideFlags of the zone group or HideFlag_None if no zone group with that name.
 */
native MenuHideFlag MapZone_GetGroupMenuHideFlags(const char[] group);

/**
 * Set which menu options to hide from the edit menu for a zone group.
 * @see MenuHideFlag enum
 *
 * @param group        The zone group name.
 * @param iFlags       The flags of the menu items to hide.
 * @return             True if set, false if no zone group with that name.
 */
native bool MapZone_SetGroupMenuHideFlags(const char[] group, MenuHideFlag iFlags);

/**
 * Check if a zone with that name exists in a zone group.
 *
 * @param group     The zone group name.
 * @param zoneName  The zone or cluster name.
 * @return          True if there is zone or cluster with that name in the group, false otherwise.
 */
native bool MapZone_ZoneExists(const char[] group, const char[] zoneName);

/**
 * Get the temporary internal zone index which is a unique identifier of the zone during the map.
 * It can change between mapchanges, so don't store it permanently. Use the zone name instead.
 * Can be used as a unique reference to a zone in your own data structures.
 * @see MapZone_GetZoneNameByIndex
 *
 * @param group        The zone group name.
 * @param zoneName     The zone or cluster name.
 * @param mapZoneType  Will be set to the type of the zone. Cluster or standalone zone.
 * @return             The internal index of the zone.
 * @error              Invalid group or zone name.
 */
native int MapZone_GetZoneIndex(const char[] group, const char[] zoneName, MapZoneType &mapZoneType);

/**
 * Get the name of the zone or cluster behind that internal index.
 * @see MapZone_GetZoneIndex
 *
 * @param group        The zone group name.
 * @param zoneIndex    The internal index of the zone or cluster.
 * @param mapZoneType  The type of the index as returned by MapZone_GetZoneIndex.
 * @param zoneName     Buffer to store the zone or cluster name in.
 * @param maxlen       Size of the buffer.
 * @error              Invalid group name, invalid index for that type or zone or cluster got deleted.
 */
native void MapZone_GetZoneNameByIndex(const char[] group, int zoneIndex, MapZoneType mapZoneType, char[] zoneName, int maxlen);

/**
 * Get an adt_array of zone (and cluster) names of this group.
 * Zone names are at most MAX_ZONE_NAME long.
 * 
 * You have to close the handle using CloseHandle after use.
 *
 * @param group             The zone group name.
 * @param bIncludeClusters  Include clustered zones in this list?
 * @return                  Handle to adt_array containing zone and cluster names
 *                          or INVALID_HANDLE if group doesn't exist.
 */
native ArrayList MapZone_GetGroupZones(const char[] group, bool bIncludeClusters=true);

/**
 * Get the type of the zone. Clustered or standalone zone.
 *
 * @param group     The zone group name.
 * @param zoneName  The zone or cluster name.
 * @return          The MapZoneType. Standalone zone or cluster?
 * @error           Invalid group or zone name.
 */
native MapZoneType MapZone_GetZoneType(const char[] group, const char[] zoneName);

/**
 * Check if a zone is made of several smaller zones.
 *
 * @param group    The zone group name.
 * @param zoneName The name of the zone to check for clustering.
 * @return         True if zone is a cluster, false otherwise.
 */
stock bool MapZone_IsClusteredZone(const char[] group, const char[] zoneName)
{
	return MapZone_GetZoneType(group, zoneName) == MapZoneType_Cluster;
}

/**
 * Get an adt_array of zone names of zones in this cluster.
 * Zone names are at most MAX_ZONE_NAME long.
 * You have to close the handle using CloseHandle after use.
 *
 * @param group        The zone group name.
 * @param clusterName  The cluster name.
 * @return             Handle to adt_array containing zone names 
 *                     or INVALID_HANDLE if group or cluster doesn't exist.
 */
native ArrayList MapZone_GetClusterZones(const char[] group, const char[] clusterName);

/**
 * Get the name of the cluster a zone is part of.
 *
 * @param group        The zone group name.
 * @param zoneName     The name of the zone.
 * @param clusterName  A buffer to store the cluster name into.
 * @param maxlen       The buffer size.
 * @return             True if zone is part of a cluster, false otherwise.
 * @error              Invalid group or zone name.
 */
native bool MapZone_GetClusterNameOfZone(const char[] group, const char[] zoneName, char[] clusterName, int maxlen);

/**
 * Returns if a zone is part of a cluster.
 *
 * @param group        The zone group name.
 * @param zoneName     The name of the zone.
 * @return             True if zone is part of a cluster, false otherwise.
 * @error              Invalid group or zone name.
 */
stock bool MapZone_IsZonePartOfCluster(const char[] group, const char[] zoneName)
{
	char clusterName[MAX_ZONE_NAME];
	return MapZone_GetClusterNameOfZone(group, zoneName, clusterName, sizeof(clusterName));
}

/**
 * Changes the name of a zone or cluster.
 *
 * @param group     The zone group name.
 * @param sOldName  The current name of the zone or cluster.
 * @param sNewName  The new name to change to.
 * @return          True if name was changed, false if there already is a zone or cluster with the new name.
 * @error           Invalid group or zone name.
 */
native bool MapZone_SetZoneName(const char[] group, const char[] sOldName, const char[] sNewName);

/**
 * Swap the names of two zones/clusters.
 *
 * @param group        The zone group name.
 * @param sFirstName   The name of the first zone or cluster.
 * @param sSecondName  The name of the second zone or cluster.
 * @return             True if the names were swapped, false otherwise.
 */
stock bool MapZone_SwapZoneNames(const char[] group, const char[] sFirstName, const char[] sSecondName)
{
	// Make sure the zones itself exist for the swap.
	if (!MapZone_ZoneExists(group, sFirstName) || !MapZone_ZoneExists(group, sSecondName))
		return false;

	// Find a free swap name.
	int iNum;
	char sSwapName[MAX_ZONE_NAME];
	do
	{
		Format(sSwapName, sizeof(sSwapName), "xyz__%d", iNum++);
	} while (MapZone_ZoneExists(group, sSwapName));

	// Swap the names of the two zones.
	if (!MapZone_SetZoneName(group, sFirstName, sSwapName))
		return false;
	if (!MapZone_SetZoneName(group, sSecondName, sFirstName))
		return false;
	if (!MapZone_SetZoneName(group, sSwapName, sSecondName))
		return false;
	return true;
}

/**
 * Get the center position of a zone.
 *
 * @param group     The zone group name.
 * @param zoneName  The name of the zone.
 * @param fCenter   Buffer to store center coordinates in.
 * @error           Invalid group or zone name.
 */
native void MapZone_GetZonePosition(const char[] group, const char[] sZoneName, float fCenter[3]);

/**
 * Get the value of a custom key for a zone or cluster.
 *
 * @param group		The zone group name.
 * @param zoneName	The zone or cluster name.
 * @param key		The custom key.
 * @param value		The buffer to store the value in.
 * @param maxlne	The length of the value buffer.
 * @return			True if key was found and value was retrieved, false if no group or zone with that name or no keyvalue for that key.
 */
native bool MapZone_GetCustomString(const char[] group, const char[] zoneName, const char[] key, char[] value, int maxlen);

/**
 * Set the value of a custom key for a zone or cluster.
 * When the key is set with an empty string as value,
 * the key is removed from the zone.
 *
 * @param group		The zone group name.
 * @param zoneName	The zone or cluster name.
 * @param key		The custom key.
 * @param value		The new value associated with the key.
 * @return			True if value was written, false if no group or zone with that name.
 */
native bool MapZone_SetCustomString(const char[] group, const char[] zoneName, const char[] key, const char[] value);

/**
 * Called when all zones are loaded from the file
 * or database.
 */
forward void MapZone_OnZonesLoaded();

/**
 * Called when a client enteres a zone.
 * 
 * @param client      The client index.
 * @param sZoneGroup  The group name of the group containing the zone.
 * @param sZoneName   The name of the zone.
 */
forward void MapZone_OnClientEnterZone(int client, const char[] sZoneGroup, const char[] sZoneName);

/**
 * Called when a client leaves a zone.
 * 
 * @param client      The client index.
 * @param sZoneGroup  The name of the group containing the zone.
 * @param sZoneName   The name of the zone.
 */
forward void MapZone_OnClientLeaveZone(int client, const char[] sZoneGroup, const char[] sZoneName);


/**
 * Called when a zone or cluster was created on the map.
 * This is called for every zone or cluster when loading the zones from the configs or database.
 *
 * @param sZoneGroup  The name of the group the zone was created in.
 * @param sZoneName   The name of the zone.
 * @param type        The type of the zone (Zone or Cluster).
 * @param iCreator    The client index of the user who created that zone or 0 if it has been loaded from elsewhere.
 */
forward void MapZone_OnZoneCreated(const char[] sZoneGroup, const char[] sZoneName, MapZoneType type, int iCreator);


/**
 * Called when a zone or cluster was removed from the map.
 *
 * @param sZoneGroup  The name of the group the zone was removed from.
 * @param sZoneName   The name of the zone.
 * @param type        The type of the zone (Zone or Cluster).
 * @param iCreator    The client index of the user who removed that zone.
 */
forward void MapZone_OnZoneRemoved(const char[] sZoneGroup, const char[] sZoneName, MapZoneType type, int iRemover);

/**
 * Called when a zone is added to a cluster.
 * Called for every zone in a cluster too when loading them from the config or database.
 *
 * @param sZoneGroup    The name of the group.
 * @param sZoneName     The name of the zone.
 * @param sClusterName  The name of the cluster the zone was added to.
 * @param iAdmin        The client index of the user adding the zone to the cluster or 0 if it has been loaded from elsewhere.
 */
forward void MapZone_OnZoneAddedToCluster(const char[] sZoneGroup, const char[] sZoneName, const char[] sClusterName, int iAdmin);

/**
 * Called when a zone is removed from a cluster.
 *
 * @param sZoneGroup    The name of the group.
 * @param sZoneName     The name of the zone.
 * @param sClusterName  The name of the cluster the zone was removed from.
 * @param iAdmin        The client index of the user removing the zone from the cluster.
 */
forward void MapZone_OnZoneRemovedFromCluster(const char[] sZoneGroup, const char[] sZoneName, const char[] sClusterName, int iAdmin);

/**
 * Called when an admin selected the option to teleport to a zone in the menu.
 * Right before the client is actually teleported.
 *
 * @param client        The client index.
 * @param sZoneGroup    The name of the group.
 * @param sZoneName     The name of the zone.
 */
forward void MapZone_OnClientTeleportedToZone(int client, const char[] sZoneGroup, const char[] sZoneName);

public SharedPlugin __pl_mapzonelib = 
{
	name = "mapzonelib",
	file = "mapzonelib.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_mapzonelib_SetNTVOptional()
{
	MarkNativeAsOptional("MapZone_RegisterZoneGroup");
	MarkNativeAsOptional("MapZone_ShowMenu");
	MarkNativeAsOptional("MapZone_ShowZoneEditMenu");
	MarkNativeAsOptional("MapZone_SetMenuCancelAction");
	MarkNativeAsOptional("MapZone_AddZoneVisibilityOverrideHandler");
	MarkNativeAsOptional("MapZone_StartAddingZone");
	MarkNativeAsOptional("MapZone_AddCluster");
	MarkNativeAsOptional("MapZone_SetNewZoneBaseName");
	MarkNativeAsOptional("MapZone_DeleteZone");
	MarkNativeAsOptional("MapZone_SetZoneDefaultColor");
	MarkNativeAsOptional("MapZone_SetZoneColor");
	MarkNativeAsOptional("MapZone_SetZoneVisibility");
	MarkNativeAsOptional("MapZone_GetZoneDisplayDimensions");
	MarkNativeAsOptional("MapZone_SetZoneDisplayDimensions");
	MarkNativeAsOptional("MapZone_GetGroupMenuHideFlags");
	MarkNativeAsOptional("MapZone_SetGroupMenuHideFlags");
	MarkNativeAsOptional("MapZone_GetZoneIndex");
	MarkNativeAsOptional("MapZone_GetZoneNameByIndex");
	MarkNativeAsOptional("MapZone_ZoneExists");
	MarkNativeAsOptional("MapZone_GetGroupZones");
	MarkNativeAsOptional("MapZone_GetZoneType");
	MarkNativeAsOptional("MapZone_GetClusterZones");
	MarkNativeAsOptional("MapZone_GetClusterNameOfZone");
	MarkNativeAsOptional("MapZone_SetZoneName");
	MarkNativeAsOptional("MapZone_GetZonePosition");
	MarkNativeAsOptional("MapZone_GetCustomString");
	MarkNativeAsOptional("MapZone_SetCustomString");
}
#endif
