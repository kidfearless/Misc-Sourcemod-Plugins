native GetOutputCount(ent, const String:sOutput[]);
native GetOutputTarget(ent, const String:sOutput[], num, String:sTarget[]);
native GetOutputTargetInput(ent, const String:sOutput[], num, String:sTargetInput[]);
native GetOutputParameter(ent, const String:sOutput[], num, String:sParameter[]);
native Float:GetOutputDelay(ent, const String:sOutput[], num);

/**
 * Do not edit below this line!
 */
public Extension:__ext_outputinfo = 
{
	name = "OutputInfo",
	file = "outputinfo.ext",
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
