#include <sourcemod>

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("plugin.basecommands");
	RegServerCmd("setconvar", Server_ConVar, "Same as sm_cvar but doesn't log.");
}

static Action Server_ConVar(int args)
{
	char cvarname[64];
	GetCmdArg(1, cvarname, sizeof(cvarname));

	ConVar hndl = FindConVar(cvarname);
	if (hndl == null)
	{
		PrintToServer("[SM] %t", "Unable to find cvar", cvarname);
		return Plugin_Handled;
	}

	char value[255];
	if (args < 2)
	{
		hndl.GetString(value, sizeof(value));

		PrintToServer("[SM] %t", "Value of cvar", cvarname, value);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, value, sizeof(value));
	
	// The server passes the values of these directly into ServerCommand, following exec. Sanitize.
	if (StrEqual(cvarname, "servercfgfile", false) || StrEqual(cvarname, "lservercfgfile", false))
	{
		int pos = StrContains(value, ";", true);
		if (pos != -1)
		{
			value[pos] = '\0';
		}
	}

	hndl.SetString(value, true);

	return Plugin_Handled;
}