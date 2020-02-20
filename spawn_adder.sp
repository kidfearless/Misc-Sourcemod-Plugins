#include <sourcemod>

public void OnPluginStart()
{
	RegAdminCmd("sm_addspawn", Command_AddSpawn, ADMFLAG_RCON, "sm_addspawn <ct/t> <optional:z-offset>");
}

public Action Command_AddSpawn(int client, int args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "sm_addspawn <ct/t> <optional:z-offset>");
		return Plugin_Handled;
	}
	char team[3];
	GetCmdArg(1, team, 3);
	team[0] = CharToLower(team[0]);
	char entity[32];
	entity = (team[0] == 'c')? "info_player_counterterrorist" : "info_player_terrorist";

	float offset = 0.5;
	if(args == 2)
	{
		char arg[16];
		GetCmdArg(2, arg, 16);
		offset = StringToFloat(arg);
	}

	char path[PLATFORM_MAX_PATH] = "addons/stripper/maps/";

	char map[PLATFORM_MAX_PATH];
	GetCurrentMap(map, PLATFORM_MAX_PATH);
	if(StrContains(map, "workshop/") == 0)
	{
		char buffers[2][PLATFORM_MAX_PATH];

		int count = ExplodeString(map[9], "/", buffers, 2, PLATFORM_MAX_PATH);
		if(count > 0)
		{
			Format(path, PLATFORM_MAX_PATH, "%sworkshop/%s", path, buffers[0]);
			if(!DirExists(path))
			{
				CreateDirectory(path, 511);
			}
		}
		FormatEx(path, PLATFORM_MAX_PATH, "addons/stripper/maps/%s.cfg", map);

		

		
		float vec[3];
		GetClientAbsOrigin(client, vec);
		vec[2] += offset;
		
		char cfg[128];
		FormatEx(cfg, 128, "add:\n{\n\"origin\" \"%f %f %f\"\n\"classname\" \"%s\"\n}\n", vec[0], vec[1], vec[2], entity);

		File file = OpenFile(path, "a+");
		file.WriteLine(cfg);
		file.Flush();
		delete file;
	}
	
	return Plugin_Handled;

}
