#if defined _dice_included
  #endinput
#endif
#define _dice_included

native void Dice_ResetClient(int client);

stock bool IsDiceLoaded()
{
	return LibraryExists("dice");
}
