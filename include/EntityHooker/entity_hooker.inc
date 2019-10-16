#if defined _entity_hooker_included
 #endinput
#endif
#define _entity_hooker_included


public SharedPlugin:__pl_entity_hooker = 
{
	name = "entity_hooker",
	file = "API_EntityHooker.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};


// WARNING: Never change the value on these defines.
#define EH_TYPE_CSGO_TO_CSS_GRAVITY_FIX		1
#define EH_TYPE_TRIGGER_PUSH_NO_COOLDOWN	2
#define EH_TYPE_REMOVE_ENTITIES				3
#define EH_TYPE_AUTO_USE					4
#define EH_TYPE_MULTIGAMES_GAME_SELECT		5
#define EH_TYPE_TRIGGER_PUSH_NO_EMULATION	6
#define EH_TYPE_LOCK_STATE					7


forward EntityHooker_OnRegisterReady();
forward EntityHooker_OnEntityHooked(eh_type, entity);
forward EntityHooker_OnEntityUnhooked(eh_type, entity);
forward EntityHooker_OnInitialHooksReady();


native bool:EntityHooker_Register(eh_type, const String:hook_name[], any:...);
native bool:EntityHooker_RegisterAdditional(eh_type, any:...);
native bool:EntityHooker_RegisterProperty(eh_type, PropType:type, PropFieldType:field_type, const String:property[]);
native bool:EntityHooker_IsEntityHooked(eh_type, ent);


#if !defined REQUIRE_PLUGIN
public __pl_entity_hooker_SetNTVOptional()
{
	MarkNativeAsOptional("EntityHooker_Register");
	MarkNativeAsOptional("EntityHooker_RegisterAdditional");
	MarkNativeAsOptional("EntityHooker_RegisterProperty");
	MarkNativeAsOptional("EntityHooker_IsEntityHooked");
}
#endif