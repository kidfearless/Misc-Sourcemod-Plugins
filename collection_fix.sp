#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.4"

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Subscribed_collection_ids fix",
	author = "kid fearless",
	description = "Workshop Management Plugin",
	version = PLUGIN_VERSION
}

public void OnPluginStart()
{
	char collections[PLATFORM_MAX_PATH];
	char authKey[PLATFORM_MAX_PATH];

	if(FileExists("workshop_collections.txt"))
	{
		File collectionHandle = OpenFile("workshop_collections.txt", "r");
		collectionHandle.ReadLine(collections, sizeof(collections));
		collectionHandle.Close();
	}
	else
	{
		File collectionHandle = OpenFile("workshop_collections.txt", "a");
		collectionHandle.Close();
	}

	if(!FileExists("subscribed_collection_ids.txt"))
	{
		File dataFileHandle = OpenFile("subscribed_collection_ids.txt", "a");
		dataFileHandle.WriteLine(collections);
		dataFileHandle.Close();
	}
	
	if(FileExists("workshop_authkey.txt"))
	{
		File authHandle = OpenFile("workshop_authkey.txt", "r");
		authHandle.ReadLine(authKey, sizeof(authKey));
		authHandle.Close();
	}

	if(!FileExists("webapi_authkey.txt"))
	{
		File authKeyHandle = OpenFile("webapi_authkey.txt", "a");
		authKeyHandle.WriteLine(authKey);
		authKeyHandle.Close();
	}


	ServerCommand("ds_get_newest_subscribed_files");
	RegAdminCmd("updateworkshop", Command_Workshop, ADMFLAG_ROOT, "ds_get_newest_subscribed_files");
	RegAdminCmd("update_workshop", Command_Workshop, ADMFLAG_ROOT, "ds_get_newest_subscribed_files");
}

public Action Command_Workshop(int client, int args)
{
	ServerCommand("ds_get_newest_subscribed_files");
	ReplyToCommand(client, "Workshop Updated");
	return Plugin_Handled;
}