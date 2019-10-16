/*
* 	hlstrikers colored chat include.
* 	Used some ideas from exvels include.
*/

#if defined _hls_color_chat_included
 #endinput
#endif
#define _hls_color_chat_included


enum
{
	COLOR_CHAT_GAME_NONE = 0,
	COLOR_CHAT_GAME_UNKNOWN,
	COLOR_CHAT_GAME_CSGO,
	COLOR_CHAT_GAME_CSS
};

new colorChat_Game;
new bool:colorChat_GameSupportsAnyColor;

#define COLOR_CHAT_MAX_MESSAGE_LENGTH 512
#define COLOR_CHAT_NO_INDEX -1

enum
{
	COLOR_CHAT_COLOR_DEFAULT = 0,
	COLOR_CHAT_COLOR_WHITE,
	COLOR_CHAT_COLOR_YELLOW,
	COLOR_CHAT_COLOR_GREEN,
	COLOR_CHAT_COLOR_OLIVE,
	COLOR_CHAT_COLOR_LIGHTGREEN,
	COLOR_CHAT_COLOR_RED,
	COLOR_CHAT_COLOR_LIGHTRED,
	COLOR_CHAT_COLOR_BLUE,
	COLOR_CHAT_COLOR_GOLD,
	COLOR_CHAT_COLOR_PURPLE,
	COLOR_CHAT_NUM_COLORS
};

new const String:ColorChat_Names[][] =
{
	"{default}",
	"{white}",
	"{yellow}",
	"{green}",
	"{olive}",
	"{lightgreen}",
	"{red}",
	"{lightred}",
	"{blue}",
	"{gold}",
	"{purple}"
};

new const String:ColorChat_Codes_CSGO[][] =
{
	"\x03",
	"\x01",
	"\x09",
	"\x04",
	"\x06",
	"\x05",
	"\x02",
	"\x07",
	"\x0B",	// Blue
	"\x03",	// Gold - Team T.
	"\x0E"
};

new const String:ColorChat_Codes_Any_Color[][] =
{
	"\x01",			// default (also yellow)
	"\x07fbfbfb",	// white
	"\x01",			// yellow
	"\x04",			// green
	"\x05",			// olive
	"\x03",			// lightgreen
	"\x07fb0000",	// red
	"\x07fb3f3f",	// lightred
	"\x079fc3fb",	// blue
	"\x07fbdc91",	// gold
	"\x07fbdc91"	// purple
};


stock CPrintToChat(client, const String:format[], any:...)
{
	decl String:szBuffer[COLOR_CHAT_MAX_MESSAGE_LENGTH];
	
	SetGlobalTransTarget(client);
	VFormat(szBuffer, sizeof(szBuffer), format, 3);
	
	CHandleBuffer(client, szBuffer, sizeof(szBuffer));
}

stock CPrintToChatAll(const String:format[], any:...)
{
	decl String:szBuffer[COLOR_CHAT_MAX_MESSAGE_LENGTH];
	
	for(new iClient=1; iClient<=MaxClients; iClient++)
	{
		if(IsClientInGame(iClient) && !IsFakeClient(iClient))
		{
			SetGlobalTransTarget(iClient);
			VFormat(szBuffer, sizeof(szBuffer), format, 2);
			CHandleBuffer(iClient, szBuffer, sizeof(szBuffer));
		}
	}
}

stock CHandleBuffer(iClient, String:szBuffer[], maxlength)
{
	new index;
	CFormat(szBuffer, maxlength, true, index);
	if(index == COLOR_CHAT_NO_INDEX)
		PrintToChat(iClient, szBuffer);
	else
		CSayText2(iClient, index, szBuffer);
}

stock CFormat(String:szMessage[], maxlength, bNeedsFixByte=true, &iIndex=COLOR_CHAT_NO_INDEX)
{
	if(colorChat_Game == COLOR_CHAT_GAME_NONE)
		ColorChat_GetGameInfo();
	
	if(colorChat_GameSupportsAnyColor)
	{
		for(new iColor=0; iColor<COLOR_CHAT_NUM_COLORS; iColor++)
			ReplaceString(szMessage, maxlength, ColorChat_Names[iColor], ColorChat_Codes_Any_Color[iColor]);
		
		return Format(szMessage, maxlength, "\x01%s", szMessage);
	}
	
	new iBytes;
	switch(colorChat_Game)
	{
		case COLOR_CHAT_GAME_CSGO:
		{
			new iOriginalLength = strlen(szMessage);
			decl iNumReplaced;
			for(new iColor=0; iColor<COLOR_CHAT_NUM_COLORS; iColor++)
			{
				iNumReplaced = ReplaceString(szMessage, maxlength, ColorChat_Names[iColor], ColorChat_Codes_CSGO[iColor]);
				
				if(iIndex != COLOR_CHAT_NO_INDEX)
					continue;
				
				if(!iNumReplaced)
					continue;
				
				if(iColor == COLOR_CHAT_COLOR_BLUE)
					iIndex = ColorChat_FindPlayerByTeam(3);
				else if(iColor == COLOR_CHAT_COLOR_GOLD)
					iIndex = ColorChat_FindPlayerByTeam(2);
			}
			
			iBytes += (strlen(szMessage) - iOriginalLength);
			
			if(bNeedsFixByte)
				iBytes += Format(szMessage, maxlength, " %s", szMessage);
		}
	}
	
	return iBytes;
}

stock ColorChat_FindPlayerByTeam(iTeamNum)
{
	for(new iClient=1; iClient<=MaxClients; iClient++)
	{
		if(IsClientInGame(iClient) && GetClientTeam(iClient) == iTeamNum)
			return iClient;
	}
	
	return COLOR_CHAT_NO_INDEX;
}

stock ColorChat_GetGameInfo()
{
	decl String:szGameName[18];
	GetGameFolderName(szGameName, sizeof(szGameName));
	
	if(StrEqual(szGameName, "csgo", false))
	{
		colorChat_Game = COLOR_CHAT_GAME_CSGO;
		colorChat_GameSupportsAnyColor = false;
	}
	else if(StrEqual(szGameName, "cstrike", false))
	{
		colorChat_Game = COLOR_CHAT_GAME_CSS;
		colorChat_GameSupportsAnyColor = true;
	}
	else
	{
		colorChat_Game = COLOR_CHAT_GAME_UNKNOWN;
		colorChat_GameSupportsAnyColor = false;
	}
}

stock CSayText2(client, sender, const String:szMessage[])
{
	new Handle:hBuffer = StartMessageOne("SayText2", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
	if(hBuffer == INVALID_HANDLE)
		return;
	
	if(GetUserMessageType() == UM_Protobuf)
	{
		PbSetInt(hBuffer, "ent_idx", sender);
		PbSetBool(hBuffer, "chat", true);
		PbSetString(hBuffer, "msg_name", szMessage);
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
	}
	else
	{
		BfWriteByte(hBuffer, sender);
		BfWriteByte(hBuffer, true);
		BfWriteString(hBuffer, szMessage);
	}
	
	EndMessage();
}