static int g__timer_Engine;
static bool g__timer_Engine_Checked = false;


/*
* enum -> GameType
*/
enum {
	GameType_CSS,
	GameType_CSGO
};

/**
* Used to print console messages to all players
*
* @param format			String to print
* @param ...			Formatting options
*/
stock PrintToConsoleAll(char[] format, any ...){
	char buffer[192];

	for (int i = 1; i <= MaxClients; i++){
		if (IsClientInGame(i)){
			SetGlobalTransTarget(i);
			VFormat(buffer, sizeof(buffer), format, 2);
			PrintToConsole(i, "%s", buffer);
		}
	}
}

/*
* Used to print messages to all players and allow custom colors
*/
stock PrintColorTextAll(const String:msg[], any:...){
	decl String:buffer[300];
	VFormat(buffer, sizeof(buffer), msg, 2);

	if(GetGameType() != GameType_CSGO){
		new Handle:hMessage = StartMessageAll("SayText2");

		if (hMessage != INVALID_HANDLE)
		{
			if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf)
			{
				PbSetInt(hMessage, "ent_idx", 0);
				PbSetBool(hMessage, "chat", true);
				PbSetString(hMessage, "msg_name", buffer);
				if (GetGameType() != GameType_CSGO){
					PbAddString(hMessage, "params", "");
					PbAddString(hMessage, "params", "");
					PbAddString(hMessage, "params", "");
					PbAddString(hMessage, "params", "");
				}
			}
			else
			{
				BfWriteByte(hMessage, 0);
				BfWriteByte(hMessage, true);
				BfWriteString(hMessage, buffer);
			}

			EndMessage();
		}
	}
	else
	{
		PrintToConsoleAll(buffer);
		PrintToChatAll(buffer);
	}
}

/*
* Forces a cvar's value
*/
stock ForceConVar(String:cvarname[], String:value[]){
	ConVar cvar = FindConVar(cvarname);
	if(cvar != null)
		cvar.SetString(value, true);
}

/*
* Used to print messages to a single player and allows special colors without annoying hexadecimal spam in console
*/
stock PrintColorText(client, const String:msg[], any:...){
	if(IsClientInGame(client)){
		new String:buffer[300];
		VFormat(buffer, sizeof(buffer), msg, 3);
		if(GetGameType() != GameType_CSGO){

			new Handle:hMessage = StartMessageOne("SayText2", client);
			if (hMessage != INVALID_HANDLE)
			{
				if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf)
				{
					PbSetInt(hMessage, "ent_idx", client);
					PbSetBool(hMessage, "chat", true);
					PbSetString(hMessage, "msg_name", buffer);
					PbAddString(hMessage, "params", "");
					PbAddString(hMessage, "params", "");
					PbAddString(hMessage, "params", "");
					PbAddString(hMessage, "params", "");
				}
				else
				{
					BfWriteByte(hMessage, client);
					BfWriteByte(hMessage, true);
					BfWriteString(hMessage, buffer);
				}

				EndMessage();
			}
		}else{
			PrintToConsole(client, buffer);
			PrintToChat(client, buffer);
		}
	}
}

/*
* Used to print messages to a player's spectators and allows special colors without annoying hexadecimal spam in console
*/
stock PrintColorTextObservers(target, const String:msg[], any:...){
	new String:buffer[300];
	VFormat(buffer, sizeof(buffer), msg, 3);

	new clients[MaxClients], observercount;

	for(new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsPlayerAlive(client) && !IsFakeClient(client))
		{
			new observee 		= GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
			new ObserverMode 	= GetEntProp(client, Prop_Send, "m_iObserverMode");

			if(observee == target && (ObserverMode == 4 || ObserverMode == 5))
			{
				if(GetGameType() != GameType_CSGO){
					clients[observercount++] = client;
				}else{
					PrintToChat(client, buffer);
				}
			}
		}
	}

	if(observercount == 0)
		return;

	if(GetGameType() != GameType_CSGO){
		new Handle:hMessage = StartMessage("SayText2", clients, observercount);
		if (hMessage != INVALID_HANDLE)
		{
			if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf)
			{
				PbSetInt(hMessage, "ent_idx", 0);
				PbSetBool(hMessage, "chat", true);
				PbSetString(hMessage, "msg_name", buffer);
				PbAddString(hMessage, "params", "");
				PbAddString(hMessage, "params", "");
				PbAddString(hMessage, "params", "");
				PbAddString(hMessage, "params", "");
			}
			else
			{
				BfWriteByte(hMessage, 0);
				BfWriteByte(hMessage, true);
				BfWriteString(hMessage, buffer);
			}

			EndMessage();
		}
	}
}


stock ReplaceMessage(String:message[], maxlength){
	if(GetGameType() == GameType_CSS){
		ReplaceString(message, maxlength, "{stop}", "\x0A", false);
		ReplaceString(message, maxlength, "{team}", "\x03", false);
		ReplaceString(message, maxlength, "^", "\x07", false);
	}else if(GetGameType() == GameType_CSGO){
		ReplaceString(message, maxlength, "^a", "\x0A", false);
		ReplaceString(message, maxlength, "^z", "\x01 ");
		ReplaceString(message, maxlength, "^10", "\x10");
		ReplaceString(message, maxlength, "^1", "\x01");
		ReplaceString(message, maxlength, "^2", "\x02");
		ReplaceString(message, maxlength, "^3", "\x03");
		ReplaceString(message, maxlength, "^4", "\x04");
		ReplaceString(message, maxlength, "^5", "\x05");
		ReplaceString(message, maxlength, "^6", "\x06");
		ReplaceString(message, maxlength, "^7", "\x07");
		ReplaceString(message, maxlength, "^8", "\x08");
		ReplaceString(message, maxlength, "^9", "\x09");
		ReplaceString(message, maxlength, "^b", "\x0B", false);
		ReplaceString(message, maxlength, "^c", "\x0C", false);
		ReplaceString(message, maxlength, "^e", "\x0E", false);
		ReplaceString(message, maxlength, "^f", "\x0f", false);
	}
}
stock UnformatMessage(String:message[], maxlength){
	ReplaceString(message, maxlength, "^a", "", false);
	ReplaceString(message, maxlength, "{team}", "", false);
	ReplaceString(message, maxlength, "^z", "");
	ReplaceString(message, maxlength, "^10", "");
	ReplaceString(message, maxlength, "^1", "");
	ReplaceString(message, maxlength, "^2", "");
	ReplaceString(message, maxlength, "^3", "");
	ReplaceString(message, maxlength, "^4", "");
	ReplaceString(message, maxlength, "^5", "");
	ReplaceString(message, maxlength, "^6", "");
	ReplaceString(message, maxlength, "^7", "");
	ReplaceString(message, maxlength, "^8", "");
	ReplaceString(message, maxlength, "^9", "");
	ReplaceString(message, maxlength, "^b", "", false);
	ReplaceString(message, maxlength, "^c", "", false);
	ReplaceString(message, maxlength, "^e", "", false);
	ReplaceString(message, maxlength, "^f", "", false);
	if(GetGameType() == GameType_CSS)
		ReplaceString(message, maxlength, "^", "", false);
}


stock ShowMOTDNotify(client, char[] motdTitle, char[] motdURL, motdType, bool ShouldAddGame = true){
	char newURL[1024];
	char finalURL[1024];

	if(GetGameType() == GameType_CSGO){
		if(ShouldAddGame)
			FormatEx(newURL, sizeof(newURL), "%s&game=csgo", motdURL);
		else
			FormatEx(newURL, sizeof(newURL), "%s", motdURL);

		FormatEx(finalURL, sizeof(finalURL), "http://strafeodyssey.com/csgo.php?%s", newURL);
	}else if(GetGameType() == GameType_CSS){
		if(ShouldAddGame)
			FormatEx(newURL, sizeof(newURL), "%s&game=css", motdURL);
		else
			FormatEx(newURL, sizeof(newURL), "%s", motdURL);

		FormatEx(finalURL, sizeof(finalURL), "%s", newURL);
	}

	PrintToConsole(client, "\n[Timer] Page URL: %s\n", newURL);

	ShowMOTDPanel(client, motdTitle, finalURL, motdType);
}

stock int GetGameType(){
	if(g__timer_Engine_Checked == false){
		EngineVersion engVersion = GetEngineVersion();

		if(engVersion == Engine_CSGO)
			g__timer_Engine = GameType_CSGO;
		else if(engVersion == Engine_CSS)
			g__timer_Engine = GameType_CSS;

		g__timer_Engine_Checked = true;
	}
	return g__timer_Engine;
}

stock void PrintHintGameText(client, const char[] format, any:...){
	decl String:buffer[1024];
	VFormat(buffer, sizeof(buffer), format, 3);
	if(GetGameType() == GameType_CSGO)
		PrintHintText(client, "<font size='16'>%s</font size>", buffer);
	else
		PrintHintText(client, buffer);
}

stock PrintHintGameTextAll(const char[] format, any:...){
	decl String:buffer[1024];
	VFormat(buffer, sizeof(buffer), format, 2);
	if(GetGameType() == GameType_CSGO)
		PrintHintTextToAll("<font size='16'>%s</font size>", buffer);
	else
		PrintHintTextToAll(buffer);
}
