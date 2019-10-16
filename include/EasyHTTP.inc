#if defined _easyhttp_included
 #endinput
#endif
#define _easyhttp_included

#if defined REQUIRE_EXTENSIONS
#undef REQUIRE_EXTENSIONS
#endif

#include <curl>
#include <socket>
#include <steamtools>

new bool:g_bExtensions = false;
new bool:g_bCURL = false;
new bool:g_bSteamTools = false;
new bool:g_bSockets = false;

new String:g_szInterfaceIP[16];

stock EasyHTTPCheckExtensions()
{
	g_bExtensions = true;
	g_bSockets = (GetExtensionFileStatus("socket.ext")==1?true:false);
	g_bCURL = (GetExtensionFileStatus("curl.ext")==1?true:false);
	g_bSteamTools = (GetExtensionFileStatus("steamtools.ext")==1?true:false);
}

stock bool:EasyHTTP(const String:url[], Function:complete=INVALID_FUNCTION, any:data=0, const String:path[]="")
{
	if(!g_bExtensions)
		EasyHTTPCheckExtensions();
	if(g_szInterfaceIP[0]==0)
	{
		new Handle:m_hHostIP = FindConVar("hostip");
		if(m_hHostIP == INVALID_HANDLE)
			LogError("EasyHTTP can't determine IP address of the server.");
		new m_iServerIP = GetConVarInt(m_hHostIP);
		Format(STRING(g_szInterfaceIP), "%d.%d.%d.%d", m_iServerIP >>> 24 & 255, m_iServerIP >>> 16 & 255, m_iServerIP >>> 8 & 255, m_iServerIP & 255);
	}

	if(g_bCURL)
	{
		new Handle:m_hCurl = curl_easy_init();
		if(m_hCurl != INVALID_HANDLE)
		{
			new CURL_Default_opt[][2] = {
				{_:CURLOPT_NOPROGRESS,1},
				{_:CURLOPT_TIMEOUT,30},
				{_:CURLOPT_CONNECTTIMEOUT,60},
				{_:CURLOPT_VERBOSE,0}};

			new Handle:m_hData = CreateDataPack();
			new Handle:m_hContents = INVALID_HANDLE;
			if(path[0] == 0)
			{
				m_hContents = CreateDataPack();
				WritePackCell(m_hContents, 0);
				WritePackCell(m_hContents, 0);
				ResetPack(m_hContents);
			}
			else
			{
				m_hContents = OpenFile(path, "wb");
				if(m_hContents == INVALID_HANDLE)
				{
					LogError("EasyHTTP OpenFile error.");
					return false;
				}
			}

			WritePackCell(m_hData, _:complete);
			WritePackCell(m_hData, data);
			WritePackString(m_hData, path);
			WritePackCell(m_hData, _:m_hContents);
			ResetPack(m_hData);
	
			curl_easy_setopt_int_array(m_hCurl, CURL_Default_opt, sizeof(CURL_Default_opt));
			curl_easy_setopt_string(m_hCurl, CURLOPT_URL, url);
			curl_easy_setopt_function(m_hCurl, CURLOPT_WRITEFUNCTION, EasyHTTP_CurlWrite, m_hData);
			curl_easy_setopt_int(m_hCurl, CURLOPT_NOSIGNAL, 1);

			new CURLcode:m_iCode = curl_load_opt(m_hCurl);
			if(m_iCode != CURLE_OK)
			{
				CloseHandle(m_hCurl);
				CloseHandle(m_hContents);
				CloseHandle(m_hData);
				return false;
			}

			curl_easy_perform_thread(m_hCurl, EasyHTTP_CurlComplete, m_hData);
	
			return true;
		}
	} else if(g_bSteamTools)
	{
		new Handle:m_hData = CreateDataPack();
		WritePackCell(m_hData, _:complete);
		WritePackCell(m_hData, data);
		WritePackString(m_hData, path);
		ResetPack(m_hData);

		new m_iLength = strlen(url)+8;
		decl String:m_szURL[m_iLength];
		if(StrContains(url, "http://")==-1)
		{
			strcopy(m_szURL, m_iLength, "http://");
			strcopy(m_szURL[7], m_iLength-7, url);
		}
		else
			strcopy(m_szURL, m_iLength, url);

		new HTTPRequestHandle:m_hRequest = Steam_CreateHTTPRequest(HTTPMethod_GET, m_szURL);
		Steam_SendHTTPRequest(m_hRequest, EasyHTTP_SteamToolsComplete, m_hData);
		return true;
	} else if(g_bSockets)
	{
		new Handle:m_hData = CreateDataPack();
		new Handle:m_hContents = INVALID_HANDLE;
		if(path[0] == 0)
		{
			m_hContents = CreateDataPack();
			WritePackCell(m_hContents, 0);
			WritePackCell(m_hContents, 0);
			ResetPack(m_hContents);
		}
		else
		{
			m_hContents = OpenFile(path, "wb");
			if(m_hContents == INVALID_HANDLE)
			{
				LogError("EasyHTTP OpenFile error.");
				return false;
			}
		}

		new m_iLength = strlen(url)+1;
		new String:m_szBaseURL[m_iLength];
		EasyHTTP_GetBaseURL(url, m_szBaseURL, m_iLength);

		new m_iPos = 0;
		if(StrContains(url, "http://")!=-1)
			m_iPos = 7;
		m_iPos += FindCharInString(url[m_iPos], '/');

		if(m_iPos == -1)
		{
			WritePackCell(m_hData, 1);
			WritePackString(m_hData, "/");
		}
		else
		{
			WritePackCell(m_hData, strlen(url[m_iPos]));
			WritePackString(m_hData, url[m_iPos]);
		}
		WritePackCell(m_hData, strlen(m_szBaseURL));
		WritePackString(m_hData, m_szBaseURL);
		WritePackCell(m_hData, _:complete);
		WritePackCell(m_hData, data);
		WritePackString(m_hData, path);
		WritePackCell(m_hData, _:m_hContents);
		WritePackCell(m_hData, false);
		ResetPack(m_hData);

		new Handle:m_hSocket = SocketCreate(SOCKET_TCP, EasyHTTP_SocketError);
		SocketSetArg(m_hSocket, m_hData);
		if(strncmp(m_szBaseURL, "www.", 4)==0)
			SocketConnect(m_hSocket, EasyHTTP_SocketConnected, EasyHTTP_SocketReceive, EasyHTTP_SocketDisconnected, m_szBaseURL[4], 80);
		else
			SocketConnect(m_hSocket, EasyHTTP_SocketConnected, EasyHTTP_SocketReceive, EasyHTTP_SocketDisconnected, m_szBaseURL, 80);
		return true;
	}

	return false;
}

stock EasyHTTP_GetBaseURL(const String:url[], String:output[], maxlen, bool:protocol=false, bool:pathinfo=false)
{
	new m_iPos = 0;
	if(!protocol)
		if(strncmp(url, "http://", 7)==0)
			m_iPos = 7;
	new m_iLength = FindCharInString(url[m_iPos], (pathinfo?'?':'/'))+1;
	if(m_iLength == -1)
		m_iLength = maxlen;
	else if(m_iLength > maxlen)
		m_iLength = maxlen;

	strcopy(output, m_iLength, url[m_iPos]);
	if(output[m_iLength-1]=='/')
		output[m_iLength-1] = 0;
}

public EasyHTTP_CurlWrite(Handle:hndl, const String:buffer[], const bytes, const nmemb, any:data)
{
	ReadPackCell(Handle:data);
	ReadPackCell(Handle:data);
	decl String:m_szPath[PLATFORM_MAX_PATH];
	ReadPackString(Handle:data, STRING(m_szPath));
	new bool:m_bFile = (m_szPath[0]?true:false);
	new Handle:m_hData = Handle:ReadPackCell(Handle:data);
	ResetPack(data);

	if(m_bFile)
	{
		new m_iIdx = 0;
		while(m_iIdx < nmemb)
			WriteFileCell(m_hData, buffer[m_iIdx++], 1);
	}
	else
	{
		new m_iBytes = ReadPackCell(m_hData);
		new m_iStrings = ReadPackCell(m_hData);
		ResetPack(m_hData);
		WritePackCell(m_hData, m_iBytes + nmemb);
		WritePackCell(m_hData, m_iStrings + 1);

		decl String:m_szTmp[1024];
		for(new i=0;i<m_iStrings;++i)
			ReadPackString(m_hData, STRING(m_szTmp));

		WritePackString(m_hData, buffer);
		ResetPack(m_hData);
	}
	return bytes*nmemb;
}

public EasyHTTP_CurlComplete(Handle:hndl, CURLcode:code, any:data)
{
	CloseHandle(hndl);

	new Function:m_fnCallback = Function:ReadPackCell(Handle:data);
	new any:m_aData = ReadPackCell(Handle:data);
	decl String:m_szPath[PLATFORM_MAX_PATH];
	ReadPackString(Handle:data, STRING(m_szPath));
	new bool:m_bFile = (m_szPath[0]!=0?true:false);

	new Handle:m_hData = Handle:ReadPackCell(Handle:data);
	CloseHandle(data);

	if(code != CURLE_OK)
	{
		if(m_fnCallback != INVALID_FUNCTION)
		{
			Call_StartFunction(INVALID_HANDLE, m_fnCallback);
			Call_PushCell(m_aData);
			Call_PushString("");
			Call_PushCell(false);
			Call_Finish();
		}
		return;
	}


	if(m_fnCallback != INVALID_FUNCTION)
	{
		Call_StartFunction(INVALID_HANDLE, m_fnCallback);
		Call_PushCell(m_aData);

		new m_iBytes = 1;
		new m_iStrings = 0;
		if(!m_bFile)
		{
			m_iBytes = ReadPackCell(m_hData);
			m_iStrings = ReadPackCell(m_hData);
		}

		new String:m_szBuffer[m_iBytes+1];
		if(!m_bFile)
		{
			new m_iPos = 0;
			for(new i=0;i<m_iStrings;++i)
			{
				ReadPackString(m_hData, m_szBuffer[m_iPos], m_iBytes+1-m_iPos);
				m_iPos = strlen(m_szBuffer);
			}
			
		}
		Call_PushString(m_szBuffer);
		Call_PushCell(true);
		Call_Finish();
	}
	CloseHandle(m_hData);
}

public EasyHTTP_SteamToolsComplete(HTTPRequestHandle:request, bool:successful, HTTPStatusCode:code, any:data)
{
	new Function:m_fnCallback = Function:ReadPackCell(Handle:data);
	new any:m_aData = ReadPackCell(Handle:data);
	decl String:m_szPath[PLATFORM_MAX_PATH];
	ReadPackString(Handle:data, STRING(m_szPath));
	CloseHandle(data);

	if(!successful)
	{
		Steam_ReleaseHTTPRequest(request);

		if(m_fnCallback != INVALID_FUNCTION)
		{
			Call_StartFunction(INVALID_HANDLE, m_fnCallback);
			Call_PushCell(m_aData);
			Call_PushString("");
			Call_PushCell(false);
			Call_Finish();
		}

		return;
	}

	new m_iLength = 1;
	if(m_szPath[0] == 0)
		m_iLength = Steam_GetHTTPResponseBodySize(request);

	decl String:m_szBuffer[m_iLength+1];
		
	if(m_szPath[0] == 0)
	{
		Steam_GetHTTPResponseBodyData(request, m_szBuffer, m_iLength);
		m_szBuffer[m_iLength] = 0;
	}
	else
		Steam_WriteHTTPResponseBody(request, m_szPath);

	if(m_fnCallback != INVALID_FUNCTION)
	{
		Call_StartFunction(INVALID_HANDLE, m_fnCallback);
		Call_PushCell(m_aData);
		Call_PushString(m_szBuffer);
		Call_PushCell(true);
		Call_Finish();
	}
	Steam_ReleaseHTTPRequest(request);
}

public EasyHTTP_SocketConnected(Handle:socket, any:data)
{
	new m_iGETLength = ReadPackCell(Handle:data);
	decl String:m_szGET[m_iGETLength+1];
	ReadPackString(Handle:data, m_szGET, m_iGETLength+1);
	new m_iURLLength = ReadPackCell(Handle:data);
	decl String:m_szURL[m_iURLLength+1];
	ReadPackString(Handle:data, m_szURL, m_iURLLength+1);
	ResetPack(Handle:data);


	decl String:m_szRequest[m_iGETLength+m_iURLLength+64];
	Format(m_szRequest, m_iGETLength+m_iURLLength+64, "GET %s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", m_szGET, m_szURL);
	SocketSend(socket, m_szRequest);
}

public EasyHTTP_SocketReceive(Handle:socket, String:receiveData[], const dataSize, any:data)
{
	decl String:m_szHelper[1];
	ReadPackCell(Handle:data);
	ReadPackString(Handle:data, STRING(m_szHelper));
	ReadPackCell(Handle:data);
	ReadPackString(Handle:data, STRING(m_szHelper));

	ReadPackCell(Handle:data);
	ReadPackCell(Handle:data);
	decl String:m_szPath[PLATFORM_MAX_PATH];
	ReadPackString(Handle:data, STRING(m_szPath));
	new bool:m_bFile = (m_szPath[0]?true:false);
	new Handle:m_hData = Handle:ReadPackCell(Handle:data);
	new m_iHeaders = GetPackPosition(Handle:data);
	new bool:m_bHeaders = bool:ReadPackCell(Handle:data);
	ResetPack(data);

	new m_iPos = 0;
	if(!m_bHeaders)
	{
		if ((m_iPos= StrContains(receiveData, "\r\n\r\n")) == -1)
			m_iPos = 0;
		else
		{
			m_iPos += 4;
			SetPackPosition(Handle:data, m_iHeaders);
			WritePackCell(Handle:data, true);
			ResetPack(data);
		}
	}

	if(m_bFile)
	{
		new m_iIdx = m_iPos;
		while(m_iIdx < dataSize)
			WriteFileCell(m_hData, receiveData[m_iIdx++], 1);
	}
	else
	{
		new m_iBytes = ReadPackCell(m_hData);
		new m_iStrings = ReadPackCell(m_hData);
		ResetPack(m_hData);
		WritePackCell(m_hData, m_iBytes + dataSize);
		WritePackCell(m_hData, m_iStrings + 1);

		decl String:m_szTmp[4096];
		for(new i=0;i<m_iStrings;++i)
			ReadPackString(m_hData, STRING(m_szTmp));

		WritePackString(m_hData, receiveData[m_iPos]);
		ResetPack(m_hData);
	}
}

public EasyHTTP_SocketDisconnected(Handle:socket, any:data)
{
	decl String:m_szHelper[1];
	ReadPackCell(Handle:data);
	ReadPackString(Handle:data, STRING(m_szHelper));
	ReadPackCell(Handle:data);
	ReadPackString(Handle:data, STRING(m_szHelper));
	new Function:m_fnCallback = Function:ReadPackCell(Handle:data);
	new any:m_aData = ReadPackCell(Handle:data);
	decl String:m_szPath[PLATFORM_MAX_PATH];
	ReadPackString(Handle:data, STRING(m_szPath));
	new bool:m_bFile = (m_szPath[0]?true:false);
	new Handle:m_hData = Handle:ReadPackCell(Handle:data);
	CloseHandle(data);

	if(m_fnCallback != INVALID_FUNCTION)
	{
		Call_StartFunction(INVALID_HANDLE, m_fnCallback);
		Call_PushCell(m_aData);
		new m_iBytes = 1;
		new m_iStrings = 0;
		if(!m_bFile)
		{
			m_iBytes = ReadPackCell(m_hData);
			m_iStrings = ReadPackCell(m_hData);
		}

		new String:m_szBuffer[m_iBytes+1];
		if(!m_bFile)
		{
			new m_iPos = 0;
			for(new i=0;i<m_iStrings;++i)
			{
				ReadPackString(m_hData, m_szBuffer[m_iPos], m_iBytes+1-m_iPos);
				m_iPos = strlen(m_szBuffer);
			}
			
		}
		Call_PushString(m_szBuffer);
		Call_PushCell(true);
		Call_Finish();
	}

	CloseHandle(m_hData);
	CloseHandle(socket);
}

public EasyHTTP_SocketError(Handle:socket, const errorType, const errorNum, any:data)
{
	decl String:m_szHelper[1];
	ReadPackCell(Handle:data);
	ReadPackString(Handle:data, STRING(m_szHelper));
	ReadPackCell(Handle:data);
	ReadPackCell(Handle:data);
	ReadPackString(Handle:data, STRING(m_szHelper));

	new Function:m_fnCallback = Function:ReadPackCell(Handle:data);
	new any:m_aData = ReadPackCell(Handle:data);
	CloseHandle(data);

	if(m_fnCallback != INVALID_FUNCTION)
	{
		Call_StartFunction(INVALID_HANDLE, m_fnCallback);
		Call_PushCell(m_aData);
		Call_PushString("");
		Call_PushCell(false);
		Call_Finish();
	}

	CloseHandle(socket);
}