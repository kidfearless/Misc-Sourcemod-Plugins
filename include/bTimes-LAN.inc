#define VERSION "2001"
#define URL "www.strafeodyssey.com"

#define MAX_TYPES 2
#define LAN 1

#define TIMER_MAIN 0
#define TIMER_BONUS 1
#define TIMER_ANY 2

#define STRING_TAB "     "

enum{
	GameType_CSS,
	GameType_CSGO
};

#define AUTO_BHOP   	1<<0
#define STOP_GUNS    	1<<1
#define STOP_MUSIC   	1<<2

native LAN_GetClientSettings(client);
native LAN_SetClientSettings(client, settings);

/*
* Used to print messages to all players and allows special colors without annoying hexadecimal spam in console
*/
stock PrintColorTextAll(const String:msg[], any:...)
{
	new g_GameTypeINC;

	decl String:sGame[64];
	GetGameFolderName(sGame, sizeof(sGame));

	if(StrEqual(sGame, "cstrike")){
		g_GameTypeINC = GameType_CSS;
	}else if(StrEqual(sGame, "csgo")){
		g_GameTypeINC = GameType_CSGO;
	}else{
		SetFailState("This timer does not support this game (%s)", sGame);
	}
	
	decl String:buffer[300];
	VFormat(buffer, sizeof(buffer), msg, 2);
	
	if(g_GameTypeINC != GameType_CSGO){
		new Handle:hMessage = StartMessageAll("SayText2"); 

		if (hMessage != INVALID_HANDLE) 
		{
			if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) 
			{
				PbSetInt(hMessage, "ent_idx", 0);
				PbSetBool(hMessage, "chat", true);
				PbSetString(hMessage, "msg_name", buffer);
				if (g_GameTypeINC != GameType_CSGO){
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
	}else{
		PrintToChatAll(buffer);
	}
}

/*
* Used to print messages to a single player and allows special colors without annoying hexadecimal spam in console
*/
stock PrintColorText(client, const String:msg[], any:...)
{
	new g_GameTypeINC;

	decl String:sGame[64];
	GetGameFolderName(sGame, sizeof(sGame));

	if(StrEqual(sGame, "cstrike")){
	g_GameTypeINC = GameType_CSS;
	}else if(StrEqual(sGame, "csgo")){
	g_GameTypeINC = GameType_CSGO;
	}else{
	SetFailState("This timer does not support this game (%s)", sGame);}
	if(IsClientInGame(client)){
		new String:buffer[300];
		VFormat(buffer, sizeof(buffer), msg, 3);
		if(g_GameTypeINC != GameType_CSGO){
			
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
			PrintToChat(client, buffer);
		}
	}
}

/*
* Used to print messages to a player's spectators and allows special colors without annoying hexadecimal spam in console
*/
stock PrintColorTextObservers(target, const String:msg[], any:...)
{
	new g_GameTypeINC;

	decl String:sGame[64];
	GetGameFolderName(sGame, sizeof(sGame));

	if(StrEqual(sGame, "cstrike")){
	g_GameTypeINC = GameType_CSS;
	}else if(StrEqual(sGame, "csgo")){
	g_GameTypeINC = GameType_CSGO;
	}else{
	SetFailState("This timer does not support this game (%s)", sGame);}
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
				if(g_GameTypeINC != GameType_CSGO){
					clients[observercount++] = client;
				}else{
					PrintToChat(client, buffer);
				}
			}
		}
	}
	
	if(observercount == 0)
		return;
	
	if(g_GameTypeINC != GameType_CSGO){
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

/*
* Gets a client's velocity with extra settings to disallow velocity on certain axes
*/
stock Float:GetClientVelocity(client, bool:UseX, bool:UseY, bool:UseZ)
{
	new Float:vVel[3];
	
	if(UseX)
	{
		vVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	}
	
	if(UseY)
	{
		vVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	}
	
	if(UseZ)
	{
		vVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
	}
	
	return GetVectorLength(vVel);
}

/*
* Turns all lowercase letters in a string to uppercase
*/
stock StringToUpper(String:buffer[])
{
	new len = strlen(buffer);
	
	for(new idx = 0; idx < len; idx++)
	{
		buffer[idx] = CharToUpper(buffer[idx]);
	}
}

/*
* Adds brackets to a string, might change so players can choose brackets
*/
stock AddBracketsToString(String:buffer[], maxlength)
{
	if(strlen(buffer) > 0)
		Format(buffer, maxlength, "[%s]", buffer);
}

/*
* Adds a space to the end of a string, probably gonna remove this
*/
stock AddSpaceToEnd(String:buffer[], maxlength){
	if(strlen(buffer) > 0)
		Format(buffer, maxlength, "%s ", buffer);
}

stock PrintHintGameText(client, const char[] format, any:...){
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

stock ReplaceMessage(String:message[], maxlength){
	if(GetGameType() == GameType_CSS){
		ReplaceString(message, maxlength, "^", "\x07", false);
	}else if(GetGameType() == GameType_CSGO){
		ReplaceString(message, maxlength, "^A", "\x0A");
		ReplaceString(message, maxlength, "^1", "\x01");
		ReplaceString(message, maxlength, "^2", "\x02");
		ReplaceString(message, maxlength, "^3", "\x03");
		ReplaceString(message, maxlength, "^4", "\x04");
		ReplaceString(message, maxlength, "^5", "\x05");
		ReplaceString(message, maxlength, "^6", "\x06");
		ReplaceString(message, maxlength, "^7", "\x07");
		ReplaceString(message, maxlength, "^fix", "\x01\x0B", false);
	}
	ReplaceString(message, maxlength, "{team}", "\x03", false);
}

stock GetGameType(){
	new _GameType, String:sGame[64];
	GetGameFolderName(sGame, sizeof(sGame));

	if(StrEqual(sGame, "cstrike")){
		_GameType = GameType_CSS;
	}else if(StrEqual(sGame, "csgo")){
		_GameType = GameType_CSGO;
	}
	
	return _GameType;
}