#include <sourcemod>

public void OnPluginStart()
{
	RegConsoleCmd("mapsize", GetMapSize, "Returns the map size in megabytes");
}

void GetMapSize()
{
	char currentMap[PLATFORM_MAX_PATH];
	GetCurrentMap(currentMap, sizeof(currentMap));

	Format(currentMap, sizeof(currentMap), "maps/%s.bsp", currentMap);
	int size = ( (FileSize(currentMap)) / 1000000);
	return Plugin_Handled;
}