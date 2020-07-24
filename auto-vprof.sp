#include <sourcemod>
#include <convar_class>

public Plugin myinfo =
{
	name = "Auto-VPROF",
	author = "KiD Fearless",
	description = "Automatically starts a profiler when performance drops below a certain point",
	version = "1.0",
	url = "https://github.com/kidfearless/Misc-Sourcemod-Plugins/"
};


Convar g_cEnabled;
Convar g_cThreshHold;
ConVar con_logfile;

bool g_IsLogging;
bool g_IsProcessing;

public void OnPluginStart()
{
	g_cEnabled = new Convar("auto_vprof_enabled", "1", "Enables/Disables the plugin", .hasMin = true, .hasMax = true, .max = 1.0);
	g_cThreshHold = new Convar("auto_vprof_threshold", "1.5", "Threshold as a percentage of the servers tick interval before logging occurs.\n1.5 being a frame took 50% longer than it should to have processed", .hasMin = true, .min = 1.0);

	Convar.AutoExecConfig();
	
	con_logfile = FindConVar("con_logfile");

	RegAdminCmd("sm_auto_vprof_test", Command_Test, ADMFLAG_RCON);
}

public void OnConfigsExecuted()
{
	// avoid heavy calculations that happen in between map changes
	CreateTimer(0.2, Timer_PostMapStart);
}

public Action Timer_PostMapStart(Handle timer, any data)
{
	g_IsProcessing = false;
}

public void OnGameFrame()
{
	if(!g_IsLogging && !g_IsProcessing && g_cEnabled.BoolValue)
	{
		float interval = GetTickInterval();
		float value = interval * g_cThreshHold.FloatValue;
		if(GetGameFrameTime() >= value)
		{
			g_IsLogging = true;
			ServerCommand("sm prof start");
			LogMessage("[AUTO-VPROF] Encountered frame time of %f/%f. %.0f%% above normal... Beginning profiler.", value, interval, value/interval);
		}
	}
}

public void OnMapEnd()
{
	if(g_IsLogging && g_cEnabled.BoolValue)
	{
		char defValue[PLATFORM_MAX_PATH];
		con_logfile.GetString(defValue, PLATFORM_MAX_PATH);

		ServerCommand("sm prof stop");
		
		char newValue[PLATFORM_MAX_PATH];
		Format(newValue, PLATFORM_MAX_PATH, "vprof_%i.log", GetTime());
		
		con_logfile.SetString(newValue);
		
		ServerCommand("sm prof dump vprof");

		DataPack pack = new DataPack();
		pack.WriteString(defValue);

		CreateTimer(0.1, Timer_PostDump, pack);

		LogMessage("[AUTO-VPROF] Dumped Profiler to %s.", newValue);
	}

	g_IsProcessing = true;
	g_IsLogging = false;
}

public Action Command_Test(int client, int args)
{
	if(!g_IsLogging)
	{
		g_IsLogging = true;

		ServerCommand("sm prof start");
		ReplyToCommand(client, "[AUTO-VPROF] Started Profiler.");
	}
	else
	{
		g_IsLogging = false;

		char defValue[PLATFORM_MAX_PATH];
		con_logfile.GetString(defValue, PLATFORM_MAX_PATH);

		ServerCommand("sm prof stop");
		
		char newValue[PLATFORM_MAX_PATH];
		Format(newValue, PLATFORM_MAX_PATH, "vprof_%i.log", GetTime());
		
		con_logfile.SetString(newValue);
		
		ServerCommand("sm prof dump vprof");

		DataPack pack = new DataPack();
		pack.WriteString(defValue);

		CreateTimer(0.1, Timer_PostDump, pack);

		ReplyToCommand(client, "[AUTO-VPROF] Dumped Profiler to %s.", newValue);
	}

	return Plugin_Handled;
}

public Action Timer_PostDump(Handle timer, DataPack pack)
{
	pack.Reset();

	char defValue[PLATFORM_MAX_PATH];
	pack.ReadString(defValue, PLATFORM_MAX_PATH);

	con_logfile.SetString(defValue);
	delete pack;
}