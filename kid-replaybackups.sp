#include <sourcemod>
#include <shavit>

ConVar g_cBackupLimit;
char g_sReplayFolder[PLATFORM_MAX_PATH];


public void OnPluginStart()
{
	g_cBackupLimit = CreateConVar("shavit_backup_count", "1", "Number of backups to save per map", _, true, 0.0);
	AutoExecConfig();
}

public void OnConfigsExecuted()
{
	if(!GetReplayFolder())
	{
		g_sReplayFolder[0] = 0;
	}
}

public Action Shavit_OnFinishPre(int client, timer_snapshot_t snapshot)
{
	// quick check for practice mode and bad times
	if(snapshot.bClientPaused || snapshot.fCurrentTime >= Shavit_GetWorldRecord(snapshot.bsStyle, snapshot.iTimerTrack))
	{
		return Plugin_Continue;
	}

	SaveReplay(snapshot.bsStyle, snapshot.iTimerTrack);

	return Plugin_Continue;
}

void SaveReplay(int style, int track)
{
	// someone messed up their configs
	if(g_sReplayFolder[0] == 0)
	{
		return;
	}

	// Get the current map name
	char map[PLATFORM_MAX_PATH];
	GetCurrentMap(map, 160);
	GetMapDisplayName(map, map, 160);

	// format the track as a string
	char sTrack[4];
	FormatEx(sTrack, 4, "_%d", track);

	// Get the path to the doomed replay file
	char sourcePath[PLATFORM_MAX_PATH];
	FormatEx(sourcePath, PLATFORM_MAX_PATH, "%s/%d/%s%s.replay", g_sReplayFolder, style, map, (track > 0)? sTrack:"");
	
	if(FileExists(sourcePath))
	{
		char destinationPath[PLATFORM_MAX_PATH];
		int backupCount = 0;
		FormatEx(destinationPath, PLATFORM_MAX_PATH, "%s.backup%i", sourcePath, backupCount);

		while(FileExists(sourcePath) && backupCount < g_cBackupLimit.IntValue)
		{
			++backupCount;
			FormatEx(destinationPath, PLATFORM_MAX_PATH, "%s.backup%i", sourcePath, backupCount);
		}

		if(backupCount == g_cBackupLimit.IntValue)
		{
			FormatEx(destinationPath, PLATFORM_MAX_PATH, "%s.backup%i", sourcePath, 0);
			DeleteFile(destinationPath);
		}

		CopyFile(sourcePath, destinationPath);
	}
}

bool GetReplayFolder()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, PLATFORM_MAX_PATH, "configs/shavit-replay.cfg");

	KeyValues kv = new KeyValues("shavit-replay");
	
	if(!kv.ImportFromFile(sPath))
	{
		delete kv;

		return false;
	}

	char sFolder[PLATFORM_MAX_PATH];
	kv.GetString("replayfolder", sFolder, PLATFORM_MAX_PATH, "{SM}/data/replaybot");

	delete kv;

	if(StrContains(sFolder, "{SM}") != -1)
	{
		ReplaceString(sFolder, PLATFORM_MAX_PATH, "{SM}/", "");
		BuildPath(Path_SM, sFolder, PLATFORM_MAX_PATH, "%s", sFolder);
	}
	
	g_sReplayFolder = sFolder;

	return true;
}

/*
* Copies file source to destination
* Based on code of javalia:
* http://forums.alliedmods.net/showthread.php?t=159895
*
* @param source		Input file
* @param destination	Output file
*/
bool CopyFile(const char[] source, const char[] destination)
{
	File file_source = OpenFile(source, "rb");

	if(file_source == null)
	{
		return false;
	}

	File file_destination = OpenFile(destination, "wb");

	if(file_destination == null)
	{
		delete file_source;

		return false;
	}

	int buffer[32];
	int cache = 0;

	while(!IsEndOfFile(file_source))
	{
		cache = ReadFile(file_source, buffer, 32, 1);

		file_destination.Write(buffer, cache, 1);
	}

	delete file_source;
	delete file_destination;

	return true;
}