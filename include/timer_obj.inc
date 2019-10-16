#if defined _timer_obj_included
 #endinput
#endif
#define _timer_obj_included

#include <timers>

methodmap TIMER < Handle
{
	public TIMER(Timer func, float interval = 1.0, int flags=0, any data=INVALID_HANDLE)
	{
		Handle obj = CreateTimer(interval, func, data, flags);

		return view_as<TIMER>(obj);

	}

	public bool IsAssigned(int i = 2)
	{
		static bool IsAssigned = false;
		if(i != 2)
		{
			IsAssigned = !!i;
		}
		return IsAssigned;
	}
}