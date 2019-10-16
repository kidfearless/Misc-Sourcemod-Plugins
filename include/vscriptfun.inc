public Extension:__ext_vscriptfun = {
	name = "VScript Functions",
	file = "vscriptfun.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};

enum HScript {
	HSCRIPT_NULL = 0,
	HSCRIPT_INVALID = -1
}

methodmap VSF {
	//Generate a random floating point number within a range, inclusive
	//float RandomFloat(float, float);
	public static native float RandomFloat(float a, float b);

	//Generate a random integer within a range, inclusive
	//integer RandomInt(integer, integer);
	public static native int RandomInt(int a, int b);

	//Print a hud message on all clients
	//void ShowMessage(cstring);
	public static native void ShowMessage(char[] a);

	//Send a string to the console as a command
	//void SendToConsole(cstring);
	public static native void SendToConsole(char[] a);

	//Send a string that gets executed on the server as a ServerCommand
	//void SendToConsoleServer(cstring);
	public static native void SendToConsoleServer(char[] a);

	//Get the name of the map.
	//cstring GetMapName();
	public static native void GetMapName(char[] retVal, int maxLength);

	//Run the single player maps in a continuous loop.
	//boolean LoopSinglePlayerMaps();
	public static native bool LoopSinglePlayerMaps();

	//given 2 points & ent to ignore, return fraction along line that hits world or models
	//float TraceLine(vector, vector, hscript);
	public static native float TraceLine(float[] a, float[] b, HScript c);

	//Get the current server time
	//float Time();
	public static native float Time();

	//Get the time spent on the server in the last frame
	//float FrameTime();
	public static native float FrameTime();

	//#EntFire:Generate and entity i/o event
	//void DoEntFire(cstring, cstring, cstring, float, hscript, hscript);
	public static native void DoEntFire(char[] a, char[] b, char[] c, float d, HScript e, HScript f);

	//Generate and entity i/o event. First parameter is an entity instance.
	//void EntFireByHandle(hscript, cstring, cstring, float, hscript, hscript);
	public static native void EntFireByHandle(HScript a, char[] b, char[] c, float d, HScript e, HScript f);

	//#UniqueString:Generate a string guaranteed to be unique across the life of the script VM, with an optional root string. Useful for adding data to tables when not sure what keys are already in use in that table.
	//cstring DoUniqueString(cstring);
	public static native void DoUniqueString(char[] a, char[] retVal, int maxLength);

	//Create a scene entity to play the specified scene.
	//hscript CreateSceneEntity(cstring);
	public static native HScript CreateSceneEntity(char[] a);

	//Draw a debug overlay box
	//void DebugDrawBox(vector, vector, vector, integer, integer, integer, integer, float);
	public static native void DebugDrawBox(float[] a, float[] b, float[] c, int d, int e, int f, int g, float h);

	//Draw a debug overlay box
	//void DebugDrawLine(vector, vector, integer, integer, integer, boolean, float);
	public static native void DebugDrawLine(float[] a, float[] b, int c, int d, int e, bool f, float g);

	//Execute a script (internal)
	//boolean DoIncludeScript(cstring, hscript);
	public static native bool DoIncludeScript(char[] a, HScript b);

	//Create a physics prop
	//hscript CreateProp(cstring, vector, cstring, integer);
	public static native HScript CreateProp(char[] a, float[] b, char[] c, int d);

	//Records achievement event or progress
	//void RecordAchievementEvent(cstring, integer);
	public static native void RecordAchievementEvent(char[] a, int b);

	//Gets the level of 'developer'
	//integer GetDeveloperLevel();
	public static native int GetDeveloperLevel();

	//Dispatches a one-off particle system
	//void DispatchParticleEffect(cstring, vector, vector);
	public static native void DispatchParticleEffect(char[] a, float[] b, float[] c);

	//Sets whether the player has completed the initial portion of the training map.
	//void ScriptSetPlayerCompletedTraining(boolean);
	public static native void ScriptSetPlayerCompletedTraining(bool a);

	//Returns true if the player has completed the initial portion of the training map.
	//boolean ScriptGetPlayerCompletedTraining();
	public static native bool ScriptGetPlayerCompletedTraining();

	//Sets the player's best time for completing the timed course.
	//void ScriptSetBestTrainingCourseTime(integer);
	public static native void ScriptSetBestTrainingCourseTime(int a);

	//Gets the player's best time for completing the timed course.
	//integer ScriptGetBestTrainingCourseTime();
	public static native int ScriptGetBestTrainingCourseTime();

	//Gets Valve's best time for completing the timed course.
	//integer ScriptGetValveTrainingCourseTime();
	public static native int ScriptGetValveTrainingCourseTime();

	//Refills ammo to max for all weapons the player has (only works in training).
	//void ScriptTrainingGivePlayerAmmo();
	public static native void ScriptTrainingGivePlayerAmmo();

	//Toggles the visibility of the miniscoreboard hud element.
	//void ScriptSetMiniScoreHidden(boolean);
	public static native void ScriptSetMiniScoreHidden(bool a);

	//Toggles the visibility of the radar hud element.
	//void ScriptSetRadarHidden(boolean);
	public static native void ScriptSetRadarHidden(bool a);

	//Sends an event that is just used by the instructor system to show a hint highlighting the ammo counter.
	//void ScriptHighlightAmmoCounter();
	public static native void ScriptHighlightAmmoCounter();

	//Shows a message box to let players know what to do next after finishing the training course.
	//void ScriptShowFinishMsgBox();
	public static native void ScriptShowFinishMsgBox();

	//Shows a message box in trainign when the player exits through the exit door
	//void ScriptShowExitDoorMsg();
	public static native void ScriptShowExitDoorMsg();

	//Returns whether the player is playing with a controller or not.
	//boolean ScriptIsLocalPlayerUsingController();
	public static native bool ScriptIsLocalPlayerUsingController();

	//Prints an alert message in the center print method to all players.
	//void ScriptPrintMessageCenterAll(cstring);
	public static native void ScriptPrintMessageCenterAll(char[] a);

	//Prints an alert message in the center print method to all players. Needs to pass token/message. param1, param2, param3. Can pass null if you need less than 3.
	//void ScriptPrintMessageCenterAllWithParams(cstring, cstring, cstring, cstring);
	public static native void ScriptPrintMessageCenterAllWithParams(char[] a, char[] b, char[] c, char[] d);

	//Prints a message in chat to all players.
	//void ScriptPrintMessageChatAll(cstring);
	public static native void ScriptPrintMessageChatAll(char[] a);

	//Prints an alert message in the center print method to the specified team.
	//void ScriptPrintMessageCenterTeam(integer, cstring);
	public static native void ScriptPrintMessageCenterTeam(int a, char[] b);

	//Prints a message in chat to the specified team.
	//void ScriptPrintMessageChatTeam(integer, cstring);
	public static native void ScriptPrintMessageChatTeam(int a, char[] b);

	//Gets the current game mode.
	//integer ScriptGetGameMode();
	public static native int ScriptGetGameMode();

	//Gets the current game type.
	//integer ScriptGetGameType();
	public static native int ScriptGetGameType();

	//Get the number of rounds played so far.
	//integer ScriptGetRoundsPlayed();
	public static native int ScriptGetRoundsPlayed();

	//Is it warmup or not.
	//boolean ScriptIsWarmupPeriod();
	public static native bool ScriptIsWarmupPeriod();

	//Sets the bot quota considering the # of players connected and refreshes the spawns.
	//void ScriptCoopSetBotQuotaAndRefreshSpawns(integer);
	public static native void ScriptCoopSetBotQuotaAndRefreshSpawns(int a);

	//Spawns the first wave of enemies in coop.
	//void ScriptCoopMissionSpawnFirstEnemies(integer);
	public static native void ScriptCoopMissionSpawnFirstEnemies(int a);

	//Set the next respawn wave to happen in this many seconds.
	//void ScriptCoopMissionSetNextRespawnIn(float, boolean);
	public static native void ScriptCoopMissionSetNextRespawnIn(float a, bool b);

	//Tells the next wave of enemies to spawn in coop.  Also respawns player.
	//void ScriptCoopMissionSpawnNextWave(integer);
	public static native void ScriptCoopMissionSpawnNextWave(int a);

	//Respawns players only.
	//void ScriptCoopMissionRespawnDeadPlayers();
	public static native void ScriptCoopMissionRespawnDeadPlayers();

	//Gets the mission number for the current map - maps can have multiple missions on them.
	//integer ScriptCoopMissionGetMissionNumber();
	public static native int ScriptCoopMissionGetMissionNumber();

	//Resets the round time and starts the mission.
	//void ScriptCoopResetRoundStartTime();
	public static native void ScriptCoopResetRoundStartTime();

	//Will give the number of specified C4s to all alive CT players.
	//void ScriptCoopGiveC4sToCTs(integer);
	public static native void ScriptCoopGiveC4sToCTs(int a);

	//Marks one of the bonus coins as collected.
	//void ScriptCoopCollectBonusCoin();
	public static native void ScriptCoopCollectBonusCoin();

}

//Wrapper class over KeyValues instance
methodmap VSF_CScriptKeyValues {
	public VSF_CScriptKeyValues(HScript handle) { return view_as<VSF_CScriptKeyValues>(handle); }

	//Given a KeyValues object and a key name, find a KeyValues object associated with the key name
	//hscript FindKey(cstring);
	public native HScript FindKey(char[] a);

	//Given a KeyValues object, return the first sub key object
	//hscript GetFirstSubKey();
	public native HScript GetFirstSubKey();

	//Given a KeyValues object, return the next key object in a sub key group
	//hscript GetNextKey();
	public native HScript GetNextKey();

	//Given a KeyValues object and a key name, return associated integer value
	//integer GetKeyInt(cstring);
	public native int GetKeyInt(char[] a);

	//Given a KeyValues object and a key name, return associated float value
	//float GetKeyFloat(cstring);
	public native float GetKeyFloat(char[] a);

	//Given a KeyValues object and a key name, return associated bool value
	//boolean GetKeyBool(cstring);
	public native bool GetKeyBool(char[] a);

	//Given a KeyValues object and a key name, return associated string value
	//cstring GetKeyString(cstring);
	public native void GetKeyString(char[] a, char[] retVal, int maxLength);

	//Given a KeyValues object and a key name, return true if key name has no value
	//boolean IsKeyEmpty(cstring);
	public native bool IsKeyEmpty(char[] a);

	//Given a root KeyValues object, release its contents
	//void ReleaseKeyValues();
	public native void ReleaseKeyValues();

}

//!The global list of entities
methodmap VSF_CEntities {
	//Begin an iteration over the list of entities
	//hscript First();
	public static native HScript First();

	//Continue an iteration over the list of entities, providing reference to a previously found entity
	//hscript Next(hscript);
	public static native HScript Next(HScript a);

	//Creates an entity by classname
	//hscript CreateByClassname(cstring);
	public static native HScript CreateByClassname(char[] a);

	//Find entities by class name. Pass 'null' to start an iteration, or reference to a previously found entity to continue a search
	//hscript FindByClassname(hscript, cstring);
	public static native HScript FindByClassname(HScript a, char[] b);

	//Find entities by name. Pass 'null' to start an iteration, or reference to a previously found entity to continue a search
	//hscript FindByName(hscript, cstring);
	public static native HScript FindByName(HScript a, char[] b);

	//Find entities within a radius. Pass 'null' to start an iteration, or reference to a previously found entity to continue a search
	//hscript FindInSphere(hscript, vector, float);
	public static native HScript FindInSphere(HScript a, float[] b, float c);

	//Find entities by targetname. Pass 'null' to start an iteration, or reference to a previously found entity to continue a search
	//hscript FindByTarget(hscript, cstring);
	public static native HScript FindByTarget(HScript a, char[] b);

	//Find entities by model name. Pass 'null' to start an iteration, or reference to a previously found entity to continue a search
	//hscript FindByModel(hscript, cstring);
	public static native HScript FindByModel(HScript a, char[] b);

	//Find entities by name nearest to a point.
	//hscript FindByNameNearest(cstring, vector, float);
	public static native HScript FindByNameNearest(char[] a, float[] b, float c);

	//Find entities by name within a radius. Pass 'null' to start an iteration, or reference to a previously found entity to continue a search
	//hscript FindByNameWithin(hscript, cstring, vector, float);
	public static native HScript FindByNameWithin(HScript a, char[] b, float[] c, float d);

	//Find entities by class name nearest to a point.
	//hscript FindByClassnameNearest(cstring, vector, float);
	public static native HScript FindByClassnameNearest(char[] a, float[] b, float c);

	//Find entities by class name within a radius. Pass 'null' to start an iteration, or reference to a previously found entity to continue a search
	//hscript FindByClassnameWithin(hscript, cstring, vector, float);
	public static native HScript FindByClassnameWithin(HScript a, char[] b, float[] c, float d);

}

//!Player voice listeners
methodmap VSF_CPlayerVoiceListener {
	public VSF_CPlayerVoiceListener(HScript handle) { return view_as<VSF_CPlayerVoiceListener>(handle); }

	//Returns whether the player specified is speaking.
	//boolean IsPlayerSpeaking(integer);
	public native bool IsPlayerSpeaking(int a);

	//Returns the number of seconds the player has been continuously speaking.
	//float GetPlayerSpeechDuration(integer);
	public native float GetPlayerSpeechDuration(int a);

}

//Root class of all server-side entities
methodmap VSF_CBaseEntity {
	public static VSF_CBaseEntity FromEntIndex(int entindex) { return view_as<VSF_CBaseEntity>(GetEntityAddress(entindex)); }

	//Adds an I/O connection that will call the named function when the specified output fires
	//void ConnectOutput(cstring, cstring);
	public static native void ConnectOutput(char[] a, char[] b);

	//Removes a connected script function from an I/O event.
	//void DisconnectOutput(cstring, cstring);
	public static native void DisconnectOutput(char[] a, char[] b);

	//integer GetHealth();
	public static native int GetHealth();

	//void SetHealth(integer);
	public static native void SetHealth(int a);

	//integer GetMaxHealth();
	public static native int GetMaxHealth();

	//void SetMaxHealth(integer);
	public static native void SetMaxHealth(int a);

	//void SetModel(cstring);
	public static native void SetModel(char[] a);

	//Returns the name of the model
	//cstring GetModelName();
	public static native void GetModelName(char[] retVal, int maxLength);

	//Plays a sound from this entity.
	//void EmitSound(cstring);
	public static native void EmitSound(char[] a);

	//Stops a sound on this entity.
	//void StopSound(cstring);
	public static native void StopSound(char[] a);

	//Precache a sound for later playing.
	//void PrecacheSoundScript(cstring);
	public static native void PrecacheSoundScript(char[] a);

	//Returns float duration of the sound. Takes soundname and optional actormodelname.
	//float GetSoundDuration(cstring, cstring);
	public static native float GetSoundDuration(char[] a, char[] b);

	//cstring GetClassname();
	public static native void GetClassname(char[] retVal, int maxLength);

	//cstring GetName();
	public static native void GetName(char[] retVal, int maxLength);

	//Get the entity name stripped of template unique decoration
	//cstring GetPreTemplateName();
	public static native void GetPreTemplateName(char[] retVal, int maxLength);

	//vector GetOrigin();
	public static native void GetOrigin(float[] retVal);

	//SetAbsOrigin
	//void SetAbsOrigin(vector);
	public static native void SetAbsOrigin(float[] a);

	//void SetOrigin(vector);
	public static native void SetOrigin(float[] a);

	//Get the forward vector of the entity
	//vector GetForwardVector();
	public static native void GetForwardVector(float[] retVal);

	//Get the left vector of the entity
	//vector GetLeftVector();
	public static native void GetLeftVector(float[] retVal);

	//Get the up vector of the entity
	//vector GetUpVector();
	public static native void GetUpVector(float[] retVal);

	//Set the orientation of the entity to have this forward vector
	//void SetForwardVector(vector);
	public static native void SetForwardVector(float[] a);

	//vector GetVelocity();
	public static native void GetVelocity(float[] retVal);

	//void SetVelocity(vector);
	public static native void SetVelocity(float[] a);

	//Set the local angular velocity - takes float pitch,yaw,roll velocities
	//void SetAngularVelocity(float, float, float);
	public static native void SetAngularVelocity(float a, float b, float c);

	//Get the local angular velocity - returns a vector of pitch,yaw,roll
	//vector GetAngularVelocity();
	public static native void GetAngularVelocity(float[] retVal);

	//Get vector to center of object - absolute coords
	//vector GetCenter();
	public static native void GetCenter(float[] retVal);

	//Get vector to eye position - absolute coords
	//vector EyePosition();
	public static native void EyePosition(float[] retVal);

	//Set entity pitch, yaw, roll
	//void SetAngles(float, float, float);
	public static native void SetAngles(float a, float b, float c);

	//Get entity pitch, yaw, roll as a vector
	//vector GetAngles();
	public static native void GetAngles(float[] retVal);

	//void SetSize(vector, vector);
	public static native void SetSize(float[] a, float[] b);

	//Get a vector containing min bounds, centered on object
	//vector GetBoundingMins();
	public static native void GetBoundingMins(float[] retVal);

	//Get a vector containing max bounds, centered on object
	//vector GetBoundingMaxs();
	public static native void GetBoundingMaxs(float[] retVal);

	//void Destroy();
	public static native void Destroy();

	//Sets this entity's owner
	//void SetOwner(hscript);
	public static native void SetOwner(HScript a);

	//integer GetTeam();
	public static native int GetTeam();

	//void SetTeam(integer);
	public static native void SetTeam(int a);

	//If in hierarchy, retrieves the entity's parent
	//hscript GetMoveParent();
	public static native HScript GetMoveParent();

	//If in hierarchy, walks up the hierarchy to find the root parent
	//hscript GetRootMoveParent();
	public static native HScript GetRootMoveParent();

	//hscript FirstMoveChild();
	public static native HScript FirstMoveChild();

	//hscript NextMovePeer();
	public static native HScript NextMovePeer();

	//@
	//boolean __KeyValueFromString(cstring, cstring);
	public static native bool __KeyValueFromString(char[] a, char[] b);

	//@
	//boolean __KeyValueFromFloat(cstring, float);
	public static native bool __KeyValueFromFloat(char[] a, float b);

	//@
	//boolean __KeyValueFromInt(cstring, integer);
	public static native bool __KeyValueFromInt(char[] a, int b);

	//@
	//boolean __KeyValueFromVector(cstring, vector);
	public static native bool __KeyValueFromVector(char[] a, float[] b);

	//Get a KeyValue class instance on this entity's model
	//hscript GetModelKeyValues();
	public static native HScript GetModelKeyValues();

	//void PrecacheModel(cstring);
	public static native void PrecacheModel(char[] a);

	//void PrecacheScriptSound(cstring);
	public static native void PrecacheScriptSound(char[] a);

	//Ensure that an entity's script scope has been created
	//boolean ValidateScriptScope();
	public static native bool ValidateScriptScope();

	//Retrieve the script-side data associated with an entity
	//hscript GetScriptScope();
	public static native HScript GetScriptScope();

	//Retrieve the unique identifier used to refer to the entity within the scripting system
	//cstring GetScriptId();
	public static native void GetScriptId(char[] retVal, int maxLength);

	//Gets this entity's owner
	//hscript GetOwner();
	public static native HScript GetOwner();

	//integer entindex();
	public static native int entindex();

}

//Animating models
methodmap VSF_CBaseAnimating < VSF_CBaseEntity {
	public VSF_CBaseAnimating(HScript handle) { return view_as<VSF_CBaseAnimating>(handle); }

	public static VSF_CBaseAnimating FromEntIndex(int entindex) { return view_as<VSF_CBaseAnimating>(GetEntityAddress(entindex)); }

	//Get the named attachement id
	//integer LookupAttachment(cstring);
	public native int LookupAttachment(char[] a);

	//Get the attachement id's origin vector
	//vector GetAttachmentOrigin(integer);
	public native void GetAttachmentOrigin(int a, float[] retVal);

	//Get the attachement id's angles as a p,y,r vector
	//vector GetAttachmentAngles(integer);
	public native void GetAttachmentAngles(int a, float[] retVal);

	//Ask whether the main sequence is done playing
	//boolean IsSequenceFinished();
	public native bool IsSequenceFinished();

	//Sets a bodygroup
	//void SetBodygroup(integer, integer);
	public native void SetBodygroup(int a, int b);

}

//hostage_carriable_prop
methodmap VSF_CHostage < VSF_CBaseEntity {
	public VSF_CHostage(HScript handle) { return view_as<VSF_CHostage>(handle); }

	public static VSF_CHostage FromEntIndex(int entindex) { return view_as<VSF_CHostage>(GetEntityAddress(entindex)); }

	//Get whether the hostage is currently being carried or not
	//boolean IsBeingCarried();
	public native bool IsBeingCarried();

}

//Server-side camera entity
methodmap VSF_CTriggerCamera < VSF_CBaseEntity {
	public VSF_CTriggerCamera(HScript handle) { return view_as<VSF_CTriggerCamera>(handle); }

	public static VSF_CTriggerCamera FromEntIndex(int entindex) { return view_as<VSF_CTriggerCamera>(GetEntityAddress(entindex)); }

	//get camera's current fov setting as integer
	//integer GetFov();
	public native int GetFov();

	//set camera's current fov in integer degrees and fov change rate as float
	//void SetFov(integer, float);
	public native void SetFov(int a, float b);

}

//func_train
methodmap VSF_CFuncTrackTrain < VSF_CBaseEntity {
	public VSF_CFuncTrackTrain(HScript handle) { return view_as<VSF_CFuncTrackTrain>(handle); }

	public static VSF_CFuncTrackTrain FromEntIndex(int entindex) { return view_as<VSF_CFuncTrackTrain>(GetEntityAddress(entindex)); }

	//Get a position on the track x seconds in the future
	//vector GetFuturePosition(float, float);
	public native void GetFuturePosition(float a, float b, float[] retVal);

}

//Choreographed scene which controls animation and/or dialog on one or more actors.
methodmap VSF_CSceneEntity < VSF_CBaseEntity {
	public VSF_CSceneEntity(HScript handle) { return view_as<VSF_CSceneEntity>(handle); }

	public static VSF_CSceneEntity FromEntIndex(int entindex) { return view_as<VSF_CSceneEntity>(GetEntityAddress(entindex)); }

	//Returns length of this scene in seconds.
	//float EstimateLength();
	public native float EstimateLength();

	//If this scene is currently playing.
	//boolean IsPlayingBack();
	public native bool IsPlayingBack();

	//If this scene is currently paused.
	//boolean IsPaused();
	public native bool IsPaused();

	//Adds a team (by index) to the broadcast list
	//void AddBroadcastTeamTarget(integer);
	public native void AddBroadcastTeamTarget(int a);

	//Removes a team (by index) from the broadcast list
	//void RemoveBroadcastTeamTarget(integer);
	public native void RemoveBroadcastTeamTarget(int a);

	//given an entity reference, such as !target, get actual entity from scene object
	//hscript FindNamedEntity(cstring);
	public native HScript FindNamedEntity(char[] a);

	//given a dummy scene name and a vcd string, load the scene
	//boolean LoadSceneFromString(cstring, cstring);
	public native bool LoadSceneFromString(char[] a, char[] b);

}

//The player entity.
methodmap VSF_CBasePlayer < VSF_CBaseAnimating {
	public VSF_CBasePlayer(HScript handle) { return view_as<VSF_CBasePlayer>(handle); }

	public static VSF_CBasePlayer FromEntIndex(int entindex) { return view_as<VSF_CBasePlayer>(GetEntityAddress(entindex)); }

	//Returns true if the player is in noclip mode.
	//boolean IsNoclipping();
	public native bool IsNoclipping();

}

//game_coopmission_manager
methodmap VSF_CGameCoopMissionManager < VSF_CBaseEntity {
	public VSF_CGameCoopMissionManager(HScript handle) { return view_as<VSF_CGameCoopMissionManager>(handle); }

	public static VSF_CGameCoopMissionManager FromEntIndex(int entindex) { return view_as<VSF_CGameCoopMissionManager>(GetEntityAddress(entindex)); }

	//Get the number of waves the players have completed
	//integer GetWaveNumber();
	public native int GetWaveNumber();

}

//env_entity_maker
methodmap VSF_CEnvEntityMaker < VSF_CBaseEntity {
	public VSF_CEnvEntityMaker(HScript handle) { return view_as<VSF_CEnvEntityMaker>(handle); }

	public static VSF_CEnvEntityMaker FromEntIndex(int entindex) { return view_as<VSF_CEnvEntityMaker>(GetEntityAddress(entindex)); }

	//Create an entity at the location of the maker
	//void SpawnEntity();
	public native void SpawnEntity();

	//Create an entity at the location of a specified entity instance
	//void SpawnEntityAtEntityOrigin(hscript);
	public native void SpawnEntityAtEntityOrigin(HScript a);

	//Create an entity at the location of a named entity
	//void SpawnEntityAtNamedEntityOrigin(cstring);
	public native void SpawnEntityAtNamedEntityOrigin(char[] a);

	//Create an entity at a specified location and orientaton, orientation is Euler angle in degrees (pitch, yaw, roll)
	//void SpawnEntityAtLocation(vector, vector);
	public native void SpawnEntityAtLocation(float[] a, float[] b);

}

//Player
methodmap VSF_CBaseMultiplayerPlayer < VSF_CBasePlayer {
	public VSF_CBaseMultiplayerPlayer(HScript handle) { return view_as<VSF_CBaseMultiplayerPlayer>(handle); }

	public static VSF_CBaseMultiplayerPlayer FromEntIndex(int entindex) { return view_as<VSF_CBaseMultiplayerPlayer>(GetEntityAddress(entindex)); }

}

//Animated characters who have vertex flex capability.
methodmap VSF_CBaseFlex < VSF_CBaseAnimating {
	public VSF_CBaseFlex(HScript handle) { return view_as<VSF_CBaseFlex>(handle); }

	public static VSF_CBaseFlex FromEntIndex(int entindex) { return view_as<VSF_CBaseFlex>(GetEntityAddress(entindex)); }

	//Returns the instance of the oldest active scene entity (if any).
	//hscript GetCurrentScene();
	public native HScript GetCurrentScene();

	//Returns the instance of the scene entity at the specified index.
	//hscript GetSceneByIndex(integer);
	public native HScript GetSceneByIndex(int a);

}

