#include <sourcemod>

int gI_LastGenerateTime;
int gI_BrokenMap;

public void OnPluginStart()
{
	HookEvent("nav_generate", OnNavGeneratePre, EventHookMode_Pre);
}

public Action OnNavGeneratePre(Event event, const char[] name, bool dontBroadcast)
{
	if(GetTime() - gI_LastGenerateTime < 10)
	{
		char map[PLATFORM_MAX_PATH];
		GetCurrentMap(map, PLATFORM_MAX_PATH);
		char sid[PLATFORM_MAX_PATH];
		char mapname[1];
		ParseWorkshopMap(map, sid, mapname);
		gI_BrokenMap = StringToInt(sid);
		ForceChangeLevel("workshop/726282962/bhop_X", "Nav mesh broke");
		CreateTimer(5.0, DeleteThatMap);
	}
	else
	{
		gI_LastGenerateTime = GetTime();
	}

	return Plugin_Continue;
}

public Action DeleteThatMap(Handle handle)
{
	DeleteFolder(gI_BrokenMap);
	CreateTimer(5.0, ReturnToThatMap, gI_BrokenMap);
	return Plugin_Continue;
}

public Action ReturnToThatMap(Handle handle)
{
	ServerCommand("host_workshop_map %i", gI_BrokenMap);
	return Plugin_Continue;
}


stock void ParseWorkshopMap(char[] inputmap, char[] id, char[] map)
{
	char mapsplit[2][64];
	char input[PLATFORM_MAX_PATH];
	FormatEx(input, sizeof(input), "%s", inputmap);

	ReplaceString(input, PLATFORM_MAX_PATH, "workshop/", "", false);
	
	ExplodeString(input, "/", mapsplit, 2, 64);
	
	strcopy(id, PLATFORM_MAX_PATH, mapsplit[0]);
	strcopy(map, PLATFORM_MAX_PATH, mapsplit[1]);
}

void DeleteFolder(int id)
{
	if(id == 726282962 || id == 0)
	{
		return;
	}

	char directory[PLATFORM_MAX_PATH];
	FormatEx(directory, sizeof(directory), "maps/workshop/%i/", id);
	DirectoryListing workshopFolder = OpenDirectory(directory);
	char buffer[PLATFORM_MAX_PATH];

	while(workshopFolder.GetNext(directory, sizeof(directory)))
	{
		if(StrEqual(directory, ".", false) || StrEqual(directory, "..", false))
		{
			continue;
		}
		FormatEx(buffer, sizeof(buffer), "maps/workshop/%i/%s", id, directory);
		DeleteFile(buffer);
		LogMessage("[SM] - DeleteFolder - %s", buffer);
	}
	delete workshopFolder;
}