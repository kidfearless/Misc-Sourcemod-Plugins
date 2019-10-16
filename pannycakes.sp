#include <sourcemod>
#define USES_CHAT_COLORS
#include <shavit>

public void OnPluginStart()
{
	RegConsoleCmd("sm_pannycakes", Command_PannyCakes, "pannycakes");
	RegConsoleCmd("sm_pannycake", Command_PannyCakes, "pannycakes");

}

public Action Command_PannyCakes(int client, int args)
{
	
	for(int i = 0; i < 256; ++i)
	{
		char buffer[256];
		Format(buffer, 256, " {rand}P{rand}A{rand}N{rand}N{rand}Y{rand}C{rand}A{rand}K{rand}E{rand}S {rand}P{rand}A{rand}N{rand}N{rand}Y{rand}C{rand}A{rand}K{rand}E{rand}S {rand}P{rand}A{rand}N{rand}N{rand}Y{rand}C{rand}A{rand}K{rand}E{rand}S");
		FormatChat(buffer, 256);
		PrintToChat(client, buffer);
	}
	return Plugin_Handled;
}

void FormatChat(char[] buffer, int size)
{
	FormatColors(buffer, size, true, true);

	char temp[8];
	do
	{
		strcopy(temp, 8, gS_CSGOColors[RealRandomInt(0, sizeof(gS_CSGOColors) - 1)]);
	}
	while(ReplaceStringEx(buffer, size, "{rand}", temp) > 0);
}

void FormatColors(char[] buffer, int size, bool colors, bool escape)
{
	if(colors)
	{
		for(int i = 0; i < sizeof(gS_GlobalColorNames); i++)
		{
			ReplaceString(buffer, size, gS_GlobalColorNames[i], gS_GlobalColors[i]);
		}

		for(int i = 0; i < sizeof(gS_CSGOColorNames); i++)
		{
			ReplaceString(buffer, size, gS_CSGOColorNames[i], gS_CSGOColors[i]);
		}
		

		ReplaceString(buffer, size, "^", "\x07");
		ReplaceString(buffer, size, "{RGB}", "\x07");
		ReplaceString(buffer, size, "&", "\x08");
		ReplaceString(buffer, size, "{RGBA}", "\x08");
	}

	if(escape)
	{
		ReplaceString(buffer, size, "%%", "");
	}
}

int RealRandomInt(int min, int max)
{
	int random = GetURandomInt();

	if(random == 0)
	{
		random++;
	}

	return (RoundToCeil(float(random) / (2147483647.0 / float(max - min + 1))) + min - 1);
}