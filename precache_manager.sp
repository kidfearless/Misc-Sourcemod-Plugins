#include <sourcemod>
#include <sdktools>
#include <precache_manager>
StringMap gSM_Precached;

char gS_Path[PLATFORM_MAX_PATH];

// bool gB_Late;

public Plugin myinfo = 
{
	name = "precache_manager",
	author = "KiD Fearless",
	description = "Handles precaching files for usage in other plugins",
	version = "1.0",
	url = "https://github.com/kidfearless"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("GetPrecachedIndex", Native_GetPrecachedIndex);

	// gB_Late = late;

	return APLRes_Success;
}

public void OnPluginStart()
{
	gSM_Precached = new StringMap();

	BuildPath(Path_SM, gS_Path, PLATFORM_MAX_PATH, "configs/precache_manager.cfg");
}

public void OnMapStart()
{
	if(FileExists(gS_Path))
	{
		File file = OpenFile(gS_Path, "rt");
		if(file == null)
		{
			LogError("OnMapStart Failed to Open \"%s\"", gS_Path);
			return;
		}

		while(!file.EndOfFile())
		{
			char buffer[PLATFORM_MAX_PATH];
			if(file.ReadLine(buffer, PLATFORM_MAX_PATH))
			{
				/* int len = strlen(buffer);
				if(buffer[len-1] == '\n')
				{
					buffer[len-1] = 0;
				}
				if(buffer[len] == '\n')
				{
					buffer[len] = 0;
				} */

				ReplaceString(buffer, PLATFORM_MAX_PATH, "\n", "\0");
				ReplaceString(buffer, PLATFORM_MAX_PATH, "\r", "\0");
				ReplaceString(buffer, PLATFORM_MAX_PATH, "\r\n", "\0");
				
				int id = -2;

				if(StringContains(buffer, "decal"))
				{
					id = PrecacheDecal(buffer, true);
				}
				else if(StringContains(buffer, "material") || StringContains(buffer, "model"))
				{
					id = PrecacheModel(buffer, true);
				}
				else if(StringContains(buffer, "sound"))
				{
					id = PrecacheSound(buffer, true);
				}
				else if(StringContains(buffer, "script"))
				{
					id = PrecacheSentenceFile(buffer, true);
				}
				else if(StringContains(buffer, "particle"))
				{
					// particles/partic.pcf::effectname
					char particle[2][PLATFORM_MAX_PATH];
					if(StringContains(buffer, "::"))
					{
						ExplodeString(buffer, "::", particle, 2, PLATFORM_MAX_PATH);
						PrecacheEffect();
						id = PrecacheGeneric(particle[0], true);
						PrecacheParticleEffect(particle[1]);
						buffer = particle[0];
					}
					else
					{
						id = PrecacheGeneric(buffer, true);
					}
				}
				else
				{
					id = PrecacheGeneric(buffer, true);
				}

				LogMessage("precaching '%s'", buffer);

				if(gSM_Precached.SetValue(buffer, id, true))
				{
					LogMessage("success");
				}
				else
				{
					LogMessage("failure");
				}
			}
		}
		delete file;
	}
}

public void OnMapEnd()
{
	gSM_Precached.Clear();
}

// native int GetPrecachedIndex(char[] File);
public int Native_GetPrecachedIndex(Handle plugin, int numParams)
{
	char file[PLATFORM_MAX_PATH];
	if(GetNativeString(1, file, PLATFORM_MAX_PATH) != SP_ERROR_NONE)
	{
		LogError("GetPrecachedIndex Failed to GetNativeString");
		return -1;
	}
	int index;
	if(gSM_Precached.GetValue(file, index))
	{
		return index;
	}
	else
	{
		LogError("GetPrecachedIndex Failed to retrieve index");
		return -1;
	}
}

stock bool StringContains(const char[] str, const char[] sub, bool caseSense = false)
{
	return (StrContains(str, sub, caseSense) != -1);
}

/* STOCKS */
/**
 * Fix for "Attempted to precache unknown particle system"
 * https://forums.alliedmods.net/showpost.php?p=2471747&postcount=4
 *
 * @param sEffectName		"ParticleEffect".
 * @noreturn
 */
stock void PrecacheEffect(const char[] sEffectName = "ParticleEffect")
{
	static int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
	{
		table = FindStringTable("EffectDispatch");
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
	}
	else
	{
		if(FindStringIndex(table, "EffectDispatch") == INVALID_STRING_INDEX)
		{
			bool save = LockStringTables(false);
			AddToStringTable(table, sEffectName);
			LockStringTables(save);
		}
	}
}

/**
 * Fix for "Attempted to precache unknown particle system"
 * https://forums.alliedmods.net/showpost.php?p=2471747&postcount=4
 *
 * @param sEffectName		String containing particle effect name.
 * @noreturn
 */
stock void PrecacheParticleEffect(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("ParticleEffectNames");
	
	bool save = LockStringTables(false);
	AddToStringTable(table, sEffectName);
	LockStringTables(save);
}
