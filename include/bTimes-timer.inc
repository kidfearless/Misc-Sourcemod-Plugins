#if defined _timer_included
  #endinput
#endif
#define _timer_included

#define MAX_STYLES 32

enum StyleConfig {
	String:Name[32],
	String:Name_Short[32],
	bool:Enabled,
	bool:TempEnabled,
	bool:AllowType[2],
	bool:Freestyle,
	bool:Freestyle_Unrestrict,
	bool:Freestyle_EzHop,
	bool:Freestyle_Auto,
	bool:Auto,
	bool:EzHop,
	Float:Gravity,
	Float:RunSpeed,
	Float:MaxVel,
	Float:MinFps,
	bool:CalcSync,
	bool:Prevent_Left,
	bool:Prevent_Right,
	bool:Prevent_Back,
	bool:Prevent_Forward,
	bool:Require_Left,
	bool:Require_Right,
	bool:Require_Back,
	bool:Require_Forward,
	bool:Hud_Style,
	bool:Hud_Strafes,
	bool:Hud_Jumps,
	bool:Count_Left_Strafe,
	bool:Count_Right_Strafe,
	bool:Count_Back_Strafe,
	bool:Count_Forward_Strafe,
	bool:Ghost_Use[2],
	bool:Ghost_Save[2],
	Float:PreSpeed,
	Float:SlowedSpeed,
	bool:Special,
	String:Special_Key[32],
	bool:GunJump,
	String:GunJump_Weapon[64],
	bool:UnrealPhys
};

/*
* Stops a client's timer.
* 
* @param client		Client index.
* 
* @noreturn
*/
native StopTimer(client);

/*
* Starts a client's timer.
* 
* @param client        Client index.
* 
* @noreturn
*/
native StartTimer(client, Type);

/*
* Gets if someone is being timed.
* 
* @param client        Client index.
* @param Type          The timer type being checked.
* 
* @return              True if they are being timed, false otherwise.
*/
native bool:IsBeingTimed(client, Type);

/*
* Ends someone's timer, attempting to save their time if it is new.
* 
* @param client        Client index.
* 
* @noreturn
*/
native FinishTimer(client);

/*
* Gets a client's style (Normal, Sideways, etc..).
* 
* @param client        Client index
* 
* @return              The client's style.
*/
native GetClientStyle(client);

/*
* Gets a client's timer type (main or bonus).
* 
* @param client        Client index.
* 
* @return              The client's timer type.
*/
native GetClientTimerType(client);

/*
* Gets if a player has their timer paused.
* 
* @param client        Client index.
* 
* @return              True if they are paused, false otherwise.
*/
native bool:IsTimerPaused(client);

/*
* Gets if a style is allowed.
* 
* @param Style         Timer style.
* 
* @return              True if the style is allowed, false otherwise.
*/
native bool:IsStyleAllowed(Style);

/*
* Gets the name of a specified style.
* 
* @param Style         The style you want the name for.
* @param sStyle        The buffer to hold the style name.
* @param maxlength     The max length of the style buffer.
* 
* @noreturn
*/
native GetStyleName(Style, String:sStyle[], maxlength, bool:bBlankIfDefault = false);

/*
* Gets the short name of a specified style.
* 
* @param Style         The style you want the name for.
* @param sStyle        The buffer to hold the style name.
* @param maxlength     The max length of the style buffer.
* 
* @noreturn
*/
native GetStyleAbbr(Style, String:sStyle[], maxlength, bool:bBlankIfDefault = false);

/*
* Gets the complete configuration for a specified style.
* 
* @param Style         The style to get a configuration for.
* @param Properties    The buffer to store all the style properties, (properties are listed in the StyleConfig enum)
* 
* @return              True if the style exists, false otherwise.
*/
native Style_GetConfig(Style, Properties[]);

/*
* Gets if a specified style is enabled for players to use.
* 
* @param Style         The style you want to know is enabled.
* 
* @return              True if the style is enabled, false otherwise.
*/
native bool:Style_IsEnabled(Style);

/*
* Gets if a style allows a specified timer type
* 
* @param Style         The style you are checking.
* @param Type          The type you want to know is allowed for the specified style.
* 
* @return              True if the timer type is allowed, false otherwise.
*/
native bool:Style_IsTypeAllowed(Style, Type);

/*
* Gets the total number of added styles.
* 
* @return              The total number of styles.
*/
native Style_GetTotal();

/*
* Gets if a style uses freestyle zones.
* 
* @param Style         The style to check.
* 
* @return              True if the style allows freestyle zones, false otherwise.
*/
native bool:Style_IsFreestyleAllowed(Style);

/*
* Gets if a replay bot should be used for the specified style and specified timer type.
* 
* @param Style         The style to check.
* @param Type          The timer type to check.
* 
* @return              True if the replay bot is allowed.
*/
native bool:Style_CanUseReplay(Style, Type);

/*
* Gets if a replay bot should be saved for the specified style and specified timer type.
* 
* @param Style         The style to check.
* @param Type          The timer type to check.
* 
* @return              True if the replay bot should be saved.
*/
native bool:Style_CanReplaySave(Style, Type);

native bool:Style_CalculateStrafeStats(Style);

/*
* Used to tell what type and what style a player wants information for given a command, can only be used during a command callback.
* 
* @param sCommand      The command the player used.
* @param sDelimeter    The delimeter to get the type and style strings.
* @param Type          The timer type to return.
* @param Style         The timer style to return.
* 
* @return              True if a type and a style were found, false otherwise.
*/
native GetTypeStyleFromCommand(const String:sDelimiter[], &Type, &Style);

/*
* Gets the unaffected bitsum of buttons (in case someone wants to do something with something like the IN_JUMP value to players on auto)
* 
* @param client        Client index.
*/
native Timer_GetButtons(client);

/*
* Called before a player finishes their run.
* 
* @param client        Client index.
* @param Type          Timer type.
* @param Style         Timer style.
*/
forward Action:OnTimerFinished_Pre(client, Type, Style);

/*
* Called after a player finishes their run.
* 
* @param client        Client index.
* @param Time          The player's finishing time.
* @param Type          The player's timer type.
* @param Style         The player's timer style.
* @param NewTime       true if it's a new time, false otherwise.
* @param OldPosition   The player's position before finishing the map.
* @param NewPosition   The player's position after finishing the map.
*/
forward OnTimerFinished_Post(client, Float:Time, Type, Style, bool:NewTime, OldPosition, NewPosition);

/*
* Called when their is an attempt to start a client's timer.
* 
* @param client        Client index.
* @param Type          Timer type.
* @param Style         Timer style.
*/
forward Action:OnTimerStart_Pre(client, Type, Style);

/*
* Called after a player's timer is started.
* 
* @param client        Client index.
* @param Type          Timer type.
* @param Style         Timer style.
*/
forward OnTimerStart_Post(client, Type, Style);

/*
* Called when times have been deleted.
* 
* @param Type          The timer type of the times deleted.
* @param Style         The timer style of the times deleted.
* @param RecordOne     The first record in the range of records deleted. RecordOne - 1 is the index in the Times param.
* @param RecordRwo     The last record in the range of records deleted. RecordTwo - 1 is the index in the Times param.
* @param Times         The adt_array of all the map times before the times have been deleted.
*/
forward OnTimesDeleted(Type, Style, RecordOne, RecordTwo, Handle:Times);

/*
* Called when times have been updated in the database.
* 
* @param Type          The timer type of the times updated.
* @param Style         The timer style of the times updated.
* @param Times         The adt_array of all the map times before the times have been updated.
*/
forward OnTimesUpdated(const String:sMapName[], Type, Style, Handle:Times);

/*
* Called when the style have been read from the styles.cfg file
*/
forward OnStylesLoaded();

/*
* Called when a map's times have been loaded
*/
forward OnMapTimesLoaded();

/**
* Called when a client changes their style. (Can be called if a client switches the to the style they were already on)
* 
* @param client        Client index.
* @param OldStyle      The previous style a player was on.
* @param NewStyle      The new style a player is on.
* @param Type          The timer type the styles are being changed for.
*/
forward OnStyleChanged(client, OldStyle, NewStyle, Type);


//public SharedPlugin:__pl_bTimes_timer =
//{
//    name = "bTimes-timer",
//    file = "bTimes-timer.smx",
//#if defined REQUIRE_PLUGIN
//    required = 1,
//#else
//    required = 0,
//#endif
//};

//#if defined REQUIRE_PLUGIN
//public __pl_bTimes_timer_SetNTVOptional()
//{
//	MarkNativeAsOptional("StopTimer");	
//	MarkNativeAsOptional("StartTimer");  	
//	MarkNativeAsOptional("IsBeingTimed");
//	MarkNativeAsOptional("FinishTimer");
//	MarkNativeAsOptional("GetClientStyle");
//	MarkNativeAsOptional("GetClientTimerType");
//	
//	MarkNativeAsOptional("IsTimerPaused");
//	MarkNativeAsOptional("IsStyleAllowed");
//	
//	MarkNativeAsOptional("GetStyleAbbr");
//	MarkNativeAsOptional("GetStyleName");
//	
//	MarkNativeAsOptional("Style_GetConfig");
//	MarkNativeAsOptional("Style_IsEnabled");
//	MarkNativeAsOptional("Style_IsTypeAllowed");
//	
//	MarkNativeAsOptional("Style_GetTotal");
//	
//	MarkNativeAsOptional("Style_IsFreestyleAllowed");
//	MarkNativeAsOptional("Style_CalculateStrafeStats");
//	
//	MarkNativeAsOptional("Style_CanUseReplay");
//	MarkNativeAsOptional("Style_CanReplaySave");
//	
//	MarkNativeAsOptional("GetTypeStyleFromCommand");
//	
//	MarkNativeAsOptional("Timer_GetButtons");
//	
//	MarkNativeAsOptional("Store_RegisterItemType"); 
//	MarkNativeAsOptional("Store_IsItemTypeRegistered");
//	
//	MarkNativeAsOptional("Store_CallItemAttrsCallback");
//}
//#endif