#include <sourcemod>

public void OnPluginStart()
{
	OnMapStart();
}


public void OnMapStart()
{
	FindConVar("nav_quicksave").IntValue = 1;
}