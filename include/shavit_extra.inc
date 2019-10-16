native int Shavit_GetClientMod(int client);
native int Shavit_GetClientWhitelist(int client);

/* Returns the clients current stage 0 if they are in the start zone or map is linear. */
native int Shavit_GetClientStage(int client);

/* Returns the clients time at the target stage. Will return 0.0 if no time is found.
   If stage and/or style is left at -1 then the players current values will be used */
native float Shavit_GetClientStageTime(int client, int stage = -1, int style = -1);

/* Returns the clients pb at the target stage. Will return 0.0 if no time is found.
   If stage and/or style is left at -1 then the players current values will be used */
native float Shavit_GetClientStagePB(int client, int stage = -1, int style = -1);

/* Returns the total stages made by shavit-stages for the current map. */
native int Shavit_GetTotalStageCount(bool maplibonly = false);

/* Adds a new stage in count only. Used to properly save times for 3rd party stages.
   SHOULD ONLY BE USED IF YOU INTEND TO ADD YOUR OWN STAGES */
native void Shavit_AddStageToCount(int stages);

/* Fires the "OnEnterStage" function as if it was called by itself */
native void Shavit_EnterStage(int client, int stage);

/* Called before stage times are processed. returning Plugin_Stop or Plugin_Handled will prevent the player from "activating" the stage. Plugin_Continue to Plugin_Continue to continue normal operations */
forward Action Shavit_OnEnterStage(int client, int& stage);

/* Called after Stages */
forward void Shavit_OnEnterStagePost(int client, int stage);