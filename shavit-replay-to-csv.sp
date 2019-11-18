#include <sourcemod>
#include <shavit>


enum 
{
	ORIGIN_X,
	ORIGIN_Y,
	ORIGIN_Z,
	ANGLES_X,
	ANGLES_Y,
	BUTTONS,
	ENT_FLAGS,
	MOVE_TYPE
}

#define REPLAY_FORMAT_FINAL "{SHAVITREPLAYFORMAT}{FINAL}"


public void OnPluginStart()
{
	RegAdminCmd("sm_dump_replay", Command_Dump, ADMFLAG_RCON, "Dumps the replay of the selected style and track for the current map to a csv USAGE: sm_dump_replay <style> <optional:track>");
}

public Action Command_Dump(int client, int args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "sm_dump_replay <style> <optional:track>");
		return Plugin_Handled;
	}
	char arg[6];
	GetCmdArg(1, arg, 6);
	int style = StringToInt(arg);
	int track = Track_Main;

	if(args > 1)
	{
		GetCmdArg(2, arg, 6);
		track = StringToInt(arg);
	}
	
	char map[PLATFORM_MAX_PATH];
	GetCurrentMap(map, PLATFORM_MAX_PATH);
	GetMapDisplayName(map, map, PLATFORM_MAX_PATH);

	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "data/replaybot");

	char sTrack[4];
	FormatEx(sTrack, 4, "_%d", track);

	Format(path, PLATFORM_MAX_PATH, "%s/%d/%s%s.replay", path, style, map, (track > 0) ? sTrack : "");

	if(!LoadReplay(style, track, path))
	{
		ReplyToCommand(client, "Failed to dump replay file");
		return Plugin_Handled;
	}

	ReplyToCommand(client, "Dumped replay file");


	return Plugin_Handled;
}


stock bool LoadReplay(int style, int track, const char[] path)
{
	if(FileExists(path))
	{
		File file = OpenFile(path, "rb");

		char header[64];

		if(!file.ReadLine(header, 64))
		{
			delete file;

			return false;
		}

		TrimString(header);
		char explodedHeader[2][64];
		ExplodeString(header, ":", explodedHeader, 2, 64);

		if(StrEqual(explodedHeader[1], REPLAY_FORMAT_FINAL))
		{
			return LoadCurrentReplayFormat(file, StringToInt(explodedHeader[0]), style, track, path);
		}
		else
		{
			return false;
		}
	}

	return true;
}

stock bool LoadCurrentReplayFormat(File file, int version, int style, int track, const char[] path)
{
	char wtPath[PLATFORM_MAX_PATH];
	FormatEx(wtPath, PLATFORM_MAX_PATH, "%s.csv", path);
	File wtFile = OpenFile(wtPath, "wt");


	char map[160];
	if(version >= 0x03)
	{
		file.ReadString(map, 160);

		file.Seek(6, SEEK_CUR);
	}

	int frameCount;
	file.ReadInt32(frameCount);
	

	file.Seek(4, SEEK_CUR);
	char sAuthID[32];

	if(version >= 0x04)
	{
		int id;
		file.ReadInt32(id);
		FormatEx(sAuthID, 32, "[U:1:%i]");
	}
	else
	{
		file.ReadString(sAuthID, 32);
	}

	wtFile.WriteLine("map:%s,steam id:%s", map, sAuthID);

	int cells = 8;

	if(version == 0x01)
	{
		cells = 6;
		wtFile.WriteLine("ORIGIN_X,ORIGIN_Y,ORIGIN_Z,ANGLES_X,ANGLES_Y,BUTTONS");
	}
	else
	{
		wtFile.WriteLine("ORIGIN_X,ORIGIN_Y,ORIGIN_Z,ANGLES_X,ANGLES_Y,BUTTONS,ENT_FLAGS,MOVE_TYPE");
	}

	

	any[] aReplayData = new any[cells];

	for(int i = 0; i < frameCount; i++)
	{
		if(file.Read(aReplayData, cells, 4) >= 0)
		{
			char line[255];
			FormatEx(line, 255, "%f,%f,%f,%f,%f,%i",
				aReplayData[ORIGIN_X], aReplayData[ORIGIN_Y], aReplayData[ORIGIN_Z],
				aReplayData[ANGLES_X], aReplayData[ANGLES_Y], aReplayData[BUTTONS]);

			if(version >= 0x02)
			{
				Format(line, 255, "%s,%i,%i", line, aReplayData[ENT_FLAGS], aReplayData[MOVE_TYPE]);
			}
			wtFile.WriteLine(line);
		}
	}

	wtFile.WriteLine("");


	delete file;
	delete wtFile;

	return true;
}