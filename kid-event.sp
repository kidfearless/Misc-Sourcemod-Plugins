#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <shavit>
#include <bank>

public Plugin myinfo = 
{
	name = "",
	author = "KiD Fearless",
	description = "",
	version = "",
	url = "http://steamcommunity.com/id/kidfearless"
}

any gA_StyleSettings[STYLE_LIMIT][STYLESETTINGS_SIZE];
char gS_LogPath[PLATFORM_MAX_PATH];
char gS_CurrentMap[PLATFORM_MAX_PATH];
char gS_DisplayName[PLATFORM_MAX_PATH];
char gS_BankName[32]
int gI_Tier = 0;
bool gB_Late = false;

public OnPluginStart()
{
	
	RegConsoleCmd("sm_balance", Command_ShowBalance, "Display your current ammount of raffle tickets you have");
	RegConsoleCmd("sm_raffle", Command_ShowBalance, "Display your current ammount of raffle tickets you have");
	RegConsoleCmd("sm_raffletickets", Command_ShowBalance, "Display your current ammount of raffle tickets you have");
	RegConsoleCmd("sm_tickets", Command_ShowBalance, "Display your current ammount of raffle tickets you have");
	RegConsoleCmd("sm_balance", Command_ShowBalance, "Display your current ammount of raffle tickets you have");
	
	
	BuildPath(Path_SM, gS_LogPath, PLATFORM_MAX_PATH, "logs/sg_event.csv");
	
	LogToFileEx(gS_LogPath, "Date, Name, Style, Time, mulitplier, FullPoints, TotalBalance, Map, Tier");
	
	
	Format(gS_BankName, sizeof(gS_BankName), "bhopevent");

}

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int err_max)
{
	MarkNativeAsOptional("Bank_SetBalance");
	MarkNativeAsOptional("Bank_GetBalance");
	MarkNativeAsOptional("Bank_EditBalance");
}

public void OnMapStart()
{
	GetMapDisplayName(gS_CurrentMap, gS_DisplayName, sizeof(gS_CurrentMap));
	gI_Tier = Shavit_GetMapTier(gS_DisplayName);
}

public void Bank_OnDatabaseReady()
{
	Bank_Create(gS_BankName);
	gB_Late = true;
	for(int client = 1; client < MAXPLAYERS; client++)
	{
		if(IsClientInGame(client))
		{
			CheckEmptyBalance(client);
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	if(gB_Late == true)
	{
		CheckEmptyBalance(client);
	}
}

public void CheckEmptyBalance(int client)
{
	char buffer[32];
	Format(buffer, sizeof(buffer), "%f", (Bank_GetBalance(gS_BankName, client)));
	if((StrEqual(buffer, "NaN")) || ((Bank_GetBalance(gS_BankName, client)) < 0.0))
	{
		Bank_SetBalance(gS_BankName, client, 0.0);
	}
}

public void Shavit_OnStyleConfigLoaded(int styles)
{
	if(styles == -1)
	{
		styles = Shavit_GetStyleCount();
	}

	for(int i = 0; i < styles; i++)
	{
		Shavit_GetStyleSettings(i, gA_StyleSettings[i]);
	}
}

public void Shavit_OnFinish(int client, int style, float time, int jumps, int strafes, float sync, int track, float oldtime, float perfs)
{
	char stylename[128];
	Shavit_GetStyleStrings(style, sStyleName, stylename, 128);
	
	if(gI_Tier == 0)
	{
		OnMapStart();
	}
	
	
	float mulitplier = (gA_StyleSettings[style][fRankingMultiplier]);
	
	float fullpoints = (((gI_Tier*gI_Tier)*mulitplier)*1.0);
	
	
	float totalbalance = Bank_GetBalance(gS_BankName, client);

	if((oldtime == 0.0) && (track == 0) && ((GetTime() >= 1527822000) && (GetTime() <= 1528434000)))
	{
		LogToFileEx(gS_LogPath, ", %L, %s, %0.02f, %0.2f, %0.2f, %0.2f, %s, %i", client, stylename, time, mulitplier, fullpoints, totalbalance, gS_DisplayName, gI_Tier);
		
		Bank_EditBalance(gS_BankName, client, fullpoints);
	}
}


public Action Command_ShowBalance(int client, int args)
{
	float raffletickets = Bank_GetBalance(gS_BankName, client);
	
	if(raffletickets == -1.0)
	{
		PrintToChat(client, "You have not won any tickets.");
	}
	else
	{
		PrintToChat(client, "You have %f tickets", raffletickets);
	}
	
	return Plugin_Handled;
}
