#include <sourcemod>
#include <shavit>


public void Shavit_OnStyleChanged(int client, int oldstyle, int newstyle)
{
	DataPack styledata = new DataPack();
	styledata.WriteCell(client);
	styledata.WriteCell(oldstyle);
	styledata.WriteCell(newstyle);

	RequestFrame(PostStyleChanged, styledata);
}

public void PostStyleChanged(DataPack styledata)
{
	styledata.Reset();
	int client = styledata.ReadCell();
	int oldstyle = styledata.ReadCell();
	int newstyle = styledata.ReadCell();
	
	if(newstyle == 4)
	{
		CloseClientMenu(client);
		Shavit_RestartTimer(client, Track_Main);
	}

	CloseHandle(styledata);
}

stock int CloseClientMenu(client)
{
	Menu ClearMenu = new Menu(MenuHandler_CloseClientMenu);

	ClearMenu.SetTitle("Clearing Menu");
	ClearMenu.Display(client, 1);
}

public int MenuHandler_CloseClientMenu(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_End)
	{
		delete menu;
	}
}