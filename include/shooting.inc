#if defined _shooting_included
 #endinput
#endif
#define _shooting_included


enum struct cmd_t
{
	int buttons;
	int impulse;
	float angles_x;
	float angles_y;
	float angles_z;
	int weapon;
	int subtype;
	int cmdnum;
	int tickcount;
	int seed;
	int mouse_x;
	int mouse_y;
}

// previoustick contains and enum stuck of the players previouse cmd tick. shotcount is the number of player ticks that have been recorded since the start of shooting

forward void OnStartShooting(int client, cmd_t previoustick, cmd_t currenttick);
forward void OnShooting(int client, int shotcount, cmd_t previoustick, cmd_t currenttick);
forward void OnStopShooting(int client, int shotcount, cmd_t previoustick, cmd_t currenttick);