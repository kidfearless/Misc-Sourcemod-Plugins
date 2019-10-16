#if defined _timercore_included
  #endinput
#endif
#define _timercore_included

#define VERSION "2001-0.3"
#define URL "www.strafeodyssey.com"

#define MAX_TYPES 2

#define TIMER_MAIN 0
#define TIMER_BONUS 1
#define TIMER_ANY 2

#define STRING_TAB "     "

#define ALL -1

enum
{
	SQL_Column_Type = 2,
	SQL_Column_Style,
	SQL_Column_PlayerID,
	SQL_Column_Time,
	SQL_Column_Jumps,
	SQL_Column_Strafes,
	SQL_Column_Points,
	SQL_Column_Timestamp
};

// Core natives

/*
* Gets a client's player id in the database.
*
* @param client		Client index.
*
* @return			Client's player id.
*/
native GetClientID(client);

/*
* A better name for GetClientID()
*
* @param client        Client index.
*
* @return              Client's player id.
*/
stock GetPlayerID(client)
{
	return GetClientID(client);
}

/*
* Gets the name of a player in the database by their Player ID
*
* @param PlayerID      Player ID in the database.
* @param sName         Buffer to store the given name.
* @param maxlength     Maxlength of the sName string.
*/
native GetNameFromPlayerID(PlayerID, String:sName[], maxlength);

/*
* Gets a SteamID given a PlayerID in the timer database
*
* @param PlayerID      Player ID in the database.
* @param sAuth         Buffer to store the SteamID.
* @param maxlength     Maxlength of the sAuth string.
*/
native GetSteamIDFromPlayerID(PlayerID, String:sAuth[], maxlength);

/*
* Gets the map id in the timer database from a map name
*
* @param sMapName      The name of the map to get the map id for.
*
* @return              The map's map id, 0 if map not found.
*/
native GetMapIdFromMapName(const String:sMapName[]);

/*
* Gets the map name from a map id
*
* @param MapID         The map id you use to get the map name for.
* @param sMapName      The buffer to hold the map name.
* @param maxlength     The max length of the sMapName buffer.
*
* @return              True if the map was found, false otherwise.
*/
native bool:GetMapNameFromMapId(MapID, String:sMapName[], maxlength);

/*
* Gets if a client is spamming SQL related commands or not.
*
* @param client		Client index.
*
* @return 			True if client is spamming; false otherwise.
*/
native bool:IsSpamming(client);

/*
* Sets a client as spamming commands.
*
* @param client		Client index.
*
* @noreturn
*/
native SetIsSpamming(client, Float:BlockTime);

/*
* Adds a command to the timer's command list.
*
* @param sCommand		The command to add to the command list.
* @param sDescription	The description of the command added to the command list.
*
* @noreturn
*/
native RegisterCommand(const String:sCommand[], const String:sDescription[]);

#include <console>

/*
* Registers a console command and adds it to the timer's command list.
*
* @param sCommand		The command to register and add to the command list.
* @param callback		The callback for the command.
* @param sDescription	The description of the command.
*
* @noreturn
*/
stock RegConsoleCmdEx(const String:sCommand[], ConCmd:callback, const String:sDescription[])
{
	RegConsoleCmd(sCommand, callback, sDescription);

	RegisterCommand(sCommand, sDescription);
}

#include <bTimes-timer>

stock RegConsoleCmdPerStyle(const String:sBaseCmd[], ConCmd:callback, const String:sDescription[])
{
	decl String:sLiteralDesc[256], String:sType[32], String:sStyle[32], String:sTypeAbbr[32], String:sStyleAbbr[32], String:sLiteralBaseCmd[64];

	new TotalStyles = Style_GetTotal();
	for(new Type; Type < MAX_TYPES; Type++)
	{
		GetTypeName(Type, sType, sizeof(sType));
		GetTypeAbbr(Type, sTypeAbbr, sizeof(sTypeAbbr), true);

		for(new Style; Style < TotalStyles; Style++)
		{
			GetStyleName(Style, sStyle, sizeof(sStyle));
			GetStyleAbbr(Style, sStyleAbbr, sizeof(sStyleAbbr), true);

			if(Style_IsEnabled(Style) && Style_IsTypeAllowed(Style, Type))
			{
				strcopy(sLiteralDesc, sizeof(sLiteralDesc), sDescription);
				ReplaceString(sLiteralDesc, sizeof(sLiteralDesc), "{Type}", sType, false);
				ReplaceString(sLiteralDesc, sizeof(sLiteralDesc), "{Style}", sStyle, false);

				FormatEx(sLiteralBaseCmd, sizeof(sLiteralBaseCmd), "sm_%s%s%s", sTypeAbbr, sBaseCmd, sStyleAbbr);

				RegConsoleCmdEx(sLiteralBaseCmd, callback, sLiteralDesc);
			}
		}
	}
}
/*
* Called when a map's MapID is gauranteed to be in the database
*/
forward OnMapIDPostCheck();

/*
* Called when the list of maps from the maps table in the database has been loaded into memory
*/
forward OnDatabaseMapListLoaded();

/*
* Called when a player's PlayerID is retrieved and gauranteed to be in the database
*/
forward OnPlayerIDLoaded(client);

/*
* Converts a time into a formatted string
*/
stock FormatPlayerTime(Float:Time, String:result[], maxlength, bool:showDash, precision, bool:showZeros = false){
	if(Time <= 0.0 && showDash == true)
	{
		Format(result, maxlength, "-");
		return;
	}

	new hours 	= RoundToFloor(Time/3600);
	Time         -= hours*3600;
	new minutes 	= RoundToFloor(Time/60);
	Time         -= minutes*60;
	new Float:seconds = Time;

	decl String:sPrecision[16];
	if(precision == 0)
		Format(sPrecision, sizeof(sPrecision), (hours > 0 || minutes > 0)?"%04.1f":"%.1f", seconds);
	else if(precision == 1)
		Format(sPrecision, sizeof(sPrecision), (hours > 0 || minutes > 0)?"%06.3f":"%.3f", seconds);
	else if(precision == 2)
		Format(sPrecision, sizeof(sPrecision), (hours > 0 || minutes > 0)?"%09.6f":"%.6f", seconds);

	if(showZeros){
		if((StringToInt(sPrecision) < 10) && (minutes < 1))
			Format(result, maxlength, "%d:%02d:0%s", hours, minutes, sPrecision);
		else
			Format(result, maxlength, "%d:%02d:%s", hours, minutes, sPrecision);
	}else{
		if(hours > 0)
			Format(result, maxlength, "%d:%02d:%s", hours, minutes, sPrecision);
		else if(minutes > 0)
			Format(result, maxlength, "%d:%s", minutes, sPrecision);
		else
			Format(result, maxlength, "%s", sPrecision);
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
* Gets the name of a specified type
*/
stock GetTypeName(Type, String:sType[], maxlength, bool:bBlankIfMain = false)
{
	if((Type == TIMER_MAIN && bBlankIfMain == true) || Type == ALL)
	{
		FormatEx(sType, maxlength, "");
		return;
	}

	decl String:sTypeList[MAX_TYPES][] = {"Main", "Bonus"};

	FormatEx(sType, maxlength, sTypeList[Type]);
}

/*
* Gets the abbreviation of a specified type
*/
stock GetTypeAbbr(Type, String:sAbbr[], maxlength, bool:bBlankIfMain = false)
{
	if((Type == TIMER_MAIN && bBlankIfMain == true) || Type == ALL)
	{
		FormatEx(sAbbr, maxlength, "");
		return;
	}

	decl String:sAbbrList[MAX_TYPES][] = {"", "b"};

	FormatEx(sAbbr, maxlength, sAbbrList[Type]);
}

/*
* Turns all lowercase letters in a string to uppercase
*/
stock StringToUpper(String:buffer[]){
	new len = strlen(buffer);

	for(new idx = 0; idx < len; idx++){
		buffer[idx] = CharToUpper(buffer[idx]);
	}
}

/*
* Turns all uppercase letters in a string to lowercase
*/
stock StringToLower(String:buffer[]){
	new len = strlen(buffer);

	for(new idx = 0; idx < len; idx++){
		buffer[idx] = CharToLower(buffer[idx]);
	}
}


/*
* Adds brackets to a string, might change so players can choose brackets
*/
stock AddBracketsToString(String:buffer[], maxlength){
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

#include <sdktools>
//stock PrecacheSoundAny( const String:szPath[] ){
//	AddToStringTable( FindStringTable( "soundprecache" ), szPath );
//}
#include <strafeodyssey-stocks>
