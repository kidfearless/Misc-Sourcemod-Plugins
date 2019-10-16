	#include <sourcemod>
	#include <sdktools>
	 
	public Plugin myinfo =
	{
		name		 = "Radar and loading screen downloader",
		author		 = "Mad",
		description	 = "Adds the radar and loading screen files to the downloads table",
		version		 = "1.0.2",
		url			 = "http://forum.i3d.net/"
	}
	 
	public OnMapStart()
	{
			//Get the name of the current map and add it to download table
			char mapName[PLATFORM_MAX_PATH];
			char currentMap[PLATFORM_MAX_PATH];
			char radarTexture[PLATFORM_MAX_PATH];
			char radarConfig[PLATFORM_MAX_PATH];
		   
			GetCurrentMap(mapName, sizeof(mapName));
			GetMapDisplayName(mapName, mapName, sizeof(mapName));
		   
			Format(radarTexture, sizeof(radarTexture), "resource/overviews/%s_radar.dds", mapName);
			Format(radarConfig, sizeof(radarConfig), "resource/overviews/%s.txt", mapName);
			Format(currentMap, sizeof(currentMap), "maps/%s.bsp", mapName);
		   

			if(FileExists(radarTexture))
				AddFileToDownloadsTable(radarTexture);
			if(FileExists(radarConfig))
				AddFileToDownloadsTable(radarConfig);
			if(FileExists(currentMap))
				AddFileToDownloadsTable(currentMap);
	}
