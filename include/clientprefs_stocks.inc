#if defined _client_prefs_stocks_included
	#endinput
#endif
#define _client_prefs_stocks_included

#include <clientprefs>

methodmap Cookie < Handle
{
	public Cookie(const char[] name, const char[] description, CookieAccess access)
	{
		if(name[0] == 0)
			return view_as<Cookie>(INVALID_HANDLE);
		return view_as<Cookie>(RegClientCookie(name, description, access));
	}
	
	property Handle Ref
	{
		public get() { return view_as<Handle>(this); }
	}
	
	public void SetValue(int iClient, const char[] sValue="")
	{
		if(this.Ref != INVALID_HANDLE)
			SetClientCookie(iClient, this.Ref, sValue);
		else
			LogError("[SM] Tried to set a cookie with an invalid cookie handle!");
	}
	
	public void GetValue(int iClient, char[] sValue, int iMaxLen)
	{
		if(this.Ref != INVALID_HANDLE)
			GetClientCookie(iClient, this.Ref, sValue, iMaxLen);
		else
			LogError("[SM] Tried to get a cookie with an invalid cookie handle!");
	}
	
	public void SetInt(int iClient, int iNum=0)
	{
		SetClientCookieInt(iClient, this.Ref, iNum);
	}
	
	public int GetInt(int iClient)
	{
		return GetClientCookieInt(iClient, this.Ref);
	}
	
	public void SetFloat(int iClient, float fFloat=0.0)
	{
		SetClientCookieFloat(iClient, this.Ref, fFloat);
	}
	
	public float GetFloat(int iClient)
	{
		return GetClientCookieFloat(iClient, this.Ref);
	}
	
	public void SetBool(int iClient, bool bEnabled=false)
	{
		SetClientCookieBool(iClient, this.Ref, bEnabled);
	}
	
	public bool GetBool(int iClient)
	{
		return GetClientCookieBool(iClient, this.Ref);
	}
}

stock void SetClientCookieInt(int iClient, Handle hCookie, int iIn=0)
{
	if(hCookie == INVALID_HANDLE)
	{
		LogError("[SM] Tried to set a cookie with an invalid cookie handle!");
		return;
	}
	if(!AreClientCookiesCached(iClient))
	{
		LogError("[SM] Tried to set a cookie for a client that isn't cached yet!");
		return;
	}
	char sCookieVal[65];
	IntToString(iIn, sCookieVal, sizeof(sCookieVal));
	SetClientCookie(iClient, hCookie, sCookieVal);
}

stock void SetClientCookieFloat(int iClient, Handle hCookie, float fIn=0.0)
{
	if(hCookie == INVALID_HANDLE)
	{
		LogError("[SM] Tried to set a cookie with an invalid cookie handle!");
		return;
	}
	if(!AreClientCookiesCached(iClient))
	{
		LogError("[SM] Tried to set a cookie for a client that isn't cached yet!");
		return;
	}
	char sCookieVal[65];
	FloatToString(fIn, sCookieVal, sizeof(sCookieVal));
	SetClientCookie(iClient, hCookie, sCookieVal);
}

stock void SetClientCookieBool(int iClient, Handle hCookie, bool bOn=false)
{
	if(hCookie == INVALID_HANDLE)
	{
		LogError("[SM] Tried to set a cookie with an invalid cookie handle!");
		return;
	}
	if(!AreClientCookiesCached(iClient))
	{
		LogError("[SM] Tried to set a cookie for a client that isn't cached yet!");
		return;
	}
	char sCookieVal[2];
	Format(sCookieVal, sizeof(sCookieVal), "%s", bOn ? "1" : "0");
	SetClientCookie(iClient, hCookie, sCookieVal);
}

stock int GetClientCookieInt(int iClient, Handle hCookie)
{
	if(hCookie == INVALID_HANDLE)
	{
		LogError("[SM] Tried to get a cookie with an invalid cookie handle!");
		return 0;
	}
	if(!AreClientCookiesCached(iClient))
	{
		LogError("[SM] Tried to get a cookie for a client that isn't cached yet!");
		return 0;
	}
	char sCookieVal[65];
	GetClientCookie(iClient, hCookie, sCookieVal, sizeof(sCookieVal));
	return StringToInt(sCookieVal);
}

stock float GetClientCookieFloat(int iClient, Handle hCookie)
{
	if(hCookie == INVALID_HANDLE)
	{
		LogError("[SM] Tried to get a cookie with an invalid cookie handle!");
		return 0.0;
	}
	if(!AreClientCookiesCached(iClient))
	{
		LogError("[SM] Tried to get a cookie for a client that isn't cached yet!");
		return 0.0;
	}
	char sCookieVal[65];
	GetClientCookie(iClient, hCookie, sCookieVal, sizeof(sCookieVal));
	return StringToFloat(sCookieVal);
}

stock bool GetClientCookieBool(int iClient, Handle hCookie)
{
	if(hCookie == INVALID_HANDLE)
	{
		LogError("[SM] Tried to get a cookie with an invalid cookie handle!");
		return false;
	}
	if(!AreClientCookiesCached(iClient))
	{
		LogError("[SM] Tried to get a cookie for a client that isn't cached yet!");
		return false;
	}
	char sCookieVal[2];
	GetClientCookie(iClient, hCookie, sCookieVal, sizeof(sCookieVal));
	return view_as<bool>(StringToInt(sCookieVal));
}
