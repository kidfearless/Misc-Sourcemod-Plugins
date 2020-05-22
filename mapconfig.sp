#include <sourcemod>

public void OnConfigsExecuted()
{
	char map[PLATFORM_MAX_PATH];
	GetCurrentMap(map, PLATFORM_MAX_PATH);
	GetMapDisplayName(map, map, PLATFORM_MAX_PATH);
	ServerCommand("exec %s.cfg", map);
}