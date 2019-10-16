#if defined _client_voice_included
 #endinput
#endif
#define _client_voice_included


public Extension:__ext_voice_hook = 
{
	name = "Voice Hook",
	file = "voice_hook.ext",
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


forward OnClientVoice(client);
