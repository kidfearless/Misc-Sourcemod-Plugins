#include <shavit>
public void OnPluginStart()
{
	RegAdminCmd("sm_reloadreplays", Command_ReloadReplays, ADMFLAG_RCON);
}
public Action Command_ReloadReplays(int client, int args)
{
	Shavit_ReloadReplays(true);
	ReplyToCommand(client, "reloaded replay data");
	return Plugin_Handled;
}