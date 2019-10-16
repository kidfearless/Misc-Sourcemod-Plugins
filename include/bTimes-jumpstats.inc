//Specmodes
#define SPECMODE_NONE 					0
#define SPECMODE_FIRSTPERSON 			4
#define SPECMODE_3RDPERSON 				5
#define SPECMODE_FREELOOK	 			6

#include <sdktools>
#include <cstrike>
#define M_PI 3.14159265358979323846
stock bool:IsPlayerInCoords(client, const Float:pos_a[3], const Float:pos_b[3])
{
	if(!IsPlayerAlive(client))
	{
		return false;
	}
	new Float:origin[3];
	GetClientAbsOrigin(client, origin);
	new bool:bX, bool:bY, bool:bZ;
	if(pos_a[0] > pos_b[0])
	{
		if(pos_a[0] >= origin[0] >= pos_b[0])
		{
			bX = true;
		}
	}
	else
	{
		if(pos_b[0] >= origin[0] >= pos_a[0])
		{
			bX = true;
		}
	}
	if(pos_a[1] > pos_b[1])
	{
		if(pos_a[1] >= origin[1] >= pos_b[1])
		{
			bY = true;
		}
	}
	else
	{
		if(pos_b[1] >= origin[1] >= pos_a[1])
		{
			bY = true;
		}
	}
	if(pos_a[2] > pos_b[2])
	{
		if(pos_a[2] >= origin[2] >= pos_b[2] - 5.0)
		{
			bZ = true;
		}
	}
	else
	{
		if(pos_b[2] >= origin[2] >= pos_a[2] - 5.0)
		{
			bZ = true;
		}
	}
	if(bX&&bY&&bZ)
	{
		return true;
	}
	else
	{
		return false;
	}
}
stock bool:IsClientInGameAlive(client)
{
	if(client!=0)
	{
		if(IsClientInGame(client))
		{
			if(IsPlayerAlive(client))
			{
				return true;
			}
		}
	}
	return false;
}
stock FormatTime_Record(Float:time, String:strTime[], iSize)
{
	new Float:second, minute, hour;
	decl String:st_sec[128], String:st_min[128], String:st_hr[128];
	new newTime = RoundToZero(time);
	if (newTime >= 3600)
	{
		hour = newTime / 3600;
		minute = (newTime - hour*3600) / 60 ;
		second = time - (hour*3600 + minute*60);
	}
	else if(3600 > newTime >= 60)
	{
		hour = 0;
		minute = newTime / 60;
		second = time - (minute*60);
	}
	else
	{
		hour = 0;
		minute = 0;
		second = time;
	}
	if (hour < 1)
	{
		Format(st_hr, 128, "");
		if(minute >= 1)
			Format(st_min, 128, "%d:", minute);
		else if(minute < 1)
			Format(st_min, 128, "0:");
		if (second < 10.000)
			Format(st_sec, 128, "0%.2f", second);
		else
			Format(st_sec, 128, "%.2f", second);
	}
	else
	{
		Format(st_hr, 128, "%d:", hour);
		if(minute >= 10)
			Format(st_min, 128, "%d:", minute);
		else if(minute < 10)
			Format(st_min, 128, "0%d:", minute);
		else if(minute < 1)
			Format(st_min, 128, "00:");
		if (second < 10.000)
			Format(st_sec, 128, "0%.2f", second);
		else
			Format(st_sec, 128, "%.2f", second);
	}
	Format(strTime, iSize, "%s%s%s", st_hr, st_min, st_sec);
}
stock FormatTime_Hud(time, String:strTime[], iSize)
{
	new second, minute, hour;
	decl String:st_sec[128], String:st_min[128], String:st_hr[128];
	second = time;
	if (second >= 3600)
	{
		hour = second / 3600;
		minute = (second - hour*3600) / 60;
		second = second % 60;
	}
	else if(3600 > second >= 60)
	{
		hour = second / 3600;
		minute = second / 60;
		second = second % 60;
	}
	else
	{
		hour = second / 3600;
		minute = second / 60;
	}
	if (hour < 1)
	{
		Format(st_hr, 128, "");
		if(minute >= 1)
			Format(st_min, 128, "%d:", minute);
		else if(minute < 1)
			Format(st_min, 128, "0:");
		if (second < 10.000)
			Format(st_sec, 128, "0%d", second);
		else
			Format(st_sec, 128, "%d", second);
	}
	else
	{
		Format(st_hr, 128, "%d:", hour);
		if(minute >= 10)
			Format(st_min, 128, "%d:", minute);
		else if(minute < 10)
			Format(st_min, 128, "0%d:", minute);
		else if(minute < 1)
			Format(st_min, 128, "00:");
		if (second < 10.000)
			Format(st_sec, 128, "0%d", second);
		else
			Format(st_sec, 128, "%d", second);
	}
	Format(strTime, iSize, "%s%s%s", st_hr, st_min, st_sec);
}
stock FormatTime_Date(Float:time, String:strTime[], iSize)
{
	new Float:second, minute, hour, day;
	decl String:st_sec[128], String:st_min[128], String:st_hr[128], String:st_day[128];
	new newTime = RoundToZero(time);
	if (newTime >= 86400)
	{
		day = newTime / 86400;
		hour = (newTime - day*86400)/3600;
		minute = (newTime - day*86400 - hour*3600)/60;
		second = time - (day*86400 + hour*3600 + minute*60);
	}
	else if(86400 > newTime >= 3600)
	{
		day = 0;
		hour = newTime/3600;
		minute = (newTime - hour*3600)/60;
		second = time - (hour*3600 + minute*60);
	}
	else if(3600>newTime>=60)
	{
		day = 0;
		hour = 0;
		minute = newTime/60;
		second = time - (minute*60);
	}
	else if(60>newTime)
	{
		day = 0;
		hour = 0;
		minute = 0;
		second = time;
	}
	if (day < 1)
	Format(st_day, 128, "");
	else
	Format(st_day, 128, "%d days,", day);
	if (hour < 1)
	Format(st_hr, 128, "");
	else
	Format(st_hr, 128, "%dh", hour);
	if (minute < 1)
	Format(st_min, 128, "");
	else
	Format(st_min, 128, "%dm", minute);
	Format(st_sec, 128, "%.0fs", second);
	Format(strTime, iSize, "%s %s %s %s", st_day, st_hr, st_min, st_sec);
}
stock BoostJump(client)
{
	new Float:finalvec[3];
	GetEntDataVector(client,FindSendPropOffs("CBasePlayer","m_vecBaseVelocity"),finalvec);
	finalvec[0]=GetEntDataFloat(client,FindSendPropOffs("CBasePlayer","m_vecVelocity[0]"))*0.1;
	finalvec[1]=GetEntDataFloat(client,FindSendPropOffs("CBasePlayer","m_vecVelocity[1]"))*0.05;
	SetEntDataVector(client,FindSendPropOffs("CBasePlayer","m_vecBaseVelocity"),finalvec,true);
}
stock PrintKeyHintText(client, const String:msg[], any:...){
	if(g_GameType != GameType_CSGO){
		decl String:buffer[512];
		SetGlobalTransTarget(client);
		VFormat(buffer, sizeof(buffer), msg, 3);
		new Handle:hBuffer = StartMessageOne("KeyHintText", client);
		BfWriteByte(hBuffer, 1);
		BfWriteString(hBuffer, buffer);
		EndMessage();
	}
}
stock SetPlayerScore(client, score)
{
	if(IsClientInGame(client))
	{
		if(IsPlayerAlive(client))
			SetEntProp(client, Prop_Data, "m_iFrags", score);
	}
}
stock PrintHint2Spec(target, const String:msg[])
{
	for(new i = 1; i<= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(IsClientObserver(i))
			{
				new obTarget = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
				if((obTarget > 0)&&(obTarget==target))
				{
					PrintHintText(i, msg);
				}
			}
		}
	}
}
stock PrintKey2Spec(target, const String:msg[])
{
	for(new i = 1; i<= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(IsClientObserver(i))
			{
				new obTarget = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
				if((obTarget > 0)&&(obTarget==target))
				{
					PrintKeyHintText(i, msg);
				}
			}
		}
	}
}
stock GetLJOrigin(client, Float:origin[3], bool:land)
{
	new Float:vel[3], Float:temp[3];
	GetClientAbsOrigin(client, temp);
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
	NormalizeVector(vel, vel);
	ScaleVector(vel, 16.0);
	if(!land)
	{
		vel[0] = 0.0 - vel[0];
		vel[1] = 0.0 - vel[1];
		vel[2] = 0.0 - vel[2];
	}
	AddVectors(vel, temp, origin);
}
stock GetBoxFromPoint(Float:origin[3], Float:result[2][3])
{
	decl Float:temp[3];
	temp = origin;
	temp[2] += 1.0;
	new Float:ang[4][3];
	ang[1][1] = 90.0;
	ang[2][1] = 180.0;
	ang[3][1] = -90.0;
	new bool:edgefound[4];
	new Float:dist[4];
	decl Float:tempdist[4], Float:position[3], Float:ground[3], Float:Last[4], Float:Edge[4][3];
	for(new i = 0; i < 4; i++)
	{
		TraceWallOrigin(temp, ang[i], Edge[i]);
		tempdist[i] = GetVectorDistance(temp, Edge[i]);
		Last[i] = origin[2];
		while(dist[i] < tempdist[i])
		{
			if(edgefound[i])
				break;
			GetBeamEndOrigin(temp, ang[i], dist[i], position);
			TraceGroundOrigin(position, ground);
			if((Last[i] != ground[2])&&(Last[i] > ground[2]))
			{
				Edge[i] = ground;
				edgefound[i] = true;
			}
			Last[i] = ground[2];
			dist[i] += 10.0;
		}
		if(!edgefound[i])
		{
			TraceGroundOrigin(Edge[i], Edge[i]);
			edgefound[i] = true;
		}
		else
		{
			ground = Edge[i];
			ground[2] = origin[2];
			MakeVectorFromPoints(ground, origin, position);
			GetVectorAngles(position, ang[i]);
			ground[2] -= 1.0;
			GetBeamHitOrigin(ground, ang[i], Edge[i]);
		}
		Edge[i][2] = origin[2];
	}
	if(edgefound[0]&&edgefound[1]&&edgefound[2]&&edgefound[3])
	{
		result[0][2] = origin[2];
		result[1][2] = origin[2];
		result[0][0] = Edge[0][0];
		result[0][1] = Edge[1][1];
		result[1][0] = Edge[2][0];
		result[1][1] = Edge[3][1];
		// decl Beam;
		// Beam = PrecacheModel("materials/sprites/laser.vmt");
		// TE_SetupBeamPoints(origin, Edge[0], Beam, 0, 0, 0, 10.0, 1.0, 1.0, 10, 0.0, {255,0,0,212}, 0);
		// TE_SendToAll();
		// TE_SetupBeamPoints(origin, Edge[1], Beam, 0, 0, 0, 10.0, 1.0, 1.0, 10, 0.0, {0,255,0,212}, 0);
		// TE_SendToAll();
		// TE_SetupBeamPoints(origin, Edge[2], Beam, 0, 0, 0, 10.0, 1.0, 1.0, 10, 0.0, {0,0,255,212}, 0);
		// TE_SendToAll();
		// TE_SetupBeamPoints(origin, Edge[3], Beam, 0, 0, 0, 10.0, 1.0, 1.0, 10, 0.0, {0,255,255,212}, 0);
		// TE_SendToAll();
	}
}
stock GetGapVector(Float:edge[2][3], Float:result[3], Float:offset)
{
	decl Float:vec[3];
	MakeVectorFromPoints(edge[0], edge[1], vec);
	NormalizeVector(vec, vec);
	GetVectorAngles(vec, vec);
	vec[1] += offset;
	result = vec;
}
stock TE_SendBlockPoint(client, const Float:pos1[3], const Float:pos2[3], model)
{
	new Float:buffer[4][3];
	buffer[2] = pos1;
	buffer[3] = pos2;
	buffer[0] = buffer[2];
	buffer[0][1] = buffer[3][1];
	buffer[1] = buffer[3];
	buffer[1][1] = buffer[2][1];
	decl randco[4];
	randco[0] = GetRandomInt(0, 255);
	randco[1] = GetRandomInt(0, 255);
	randco[2] = GetRandomInt(0, 255);
	randco[3] = GetRandomInt(125, 255);
	TE_SetupBeamPoints(buffer[3], buffer[0], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
	TE_SetupBeamPoints(buffer[0], buffer[2], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
	TE_SetupBeamPoints(buffer[2], buffer[1], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
	TE_SetupBeamPoints(buffer[1], buffer[3], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
}
stock bool:IsCoordInBlockPoint(const Float:origin[3], const Float:pos[2][3])
{
	new bool:bX, bool:bY, bool:bZ;
	decl Float:temp[2][3];
	temp[0] = pos[0];
	temp[1] = pos[1];
	temp[0][0] += 16.0;
	temp[0][1] += 16.0;
	temp[1][0] -= 16.0;
	temp[1][1] -= 16.0;
	if(temp[0][0] > temp[1][0])
	{
		if(temp[0][0] >= origin[0] >= temp[1][0])
		{
			bX = true;
		}
	}
	else
	{
		if(temp[1][0] >= origin[0] >= temp[0][0])
		{
			bX = true;
		}
	}
	if(temp[0][1] > temp[1][1])
	{
		if(temp[0][1] >= origin[1] >= temp[1][1])
		{
			bY = true;
		}
	}
	else
	{
		if(temp[1][1] >= origin[1] >= temp[0][1])
		{
			bY = true;
		}
	}
	if(temp[0][2] + 0.002 >= origin[2] >= temp[0][2])
	{
		bZ = true;
	}
	if(bX&&bY&&bZ)
	{
		return true;
	}
	else
	{
		return false;
	}
}
public bool:DoesPlayerBackward(client)
{
	decl Float:vel[3], Float:ang[3], Float:result[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
	GetVectorAngles(vel, vel);
	GetClientEyeAngles(client, ang);
	if(ang[1] < 0)
	{
		ang[1] += 360;
	}
	SubtractVectors(ang, vel, result);
	if(-90 < result[1] < 90)
		return false;
	else
		return true;
}
stock PrintTransAll(const String:msg[], any:...)
{
	decl String:buffer[512];
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			SetGlobalTransTarget(i);
			VFormat(buffer, sizeof(buffer), msg, 2);
			PrintToChat(i, buffer);
		}
	}
}
stock bool:IsClientAdmin(client)
{
	new AdminId:Cl_ID;
	Cl_ID = GetUserAdmin(client);
	if(Cl_ID == INVALID_ADMIN_ID)
	{
		return false;
	}
	else
	{
		return true;
	}
}
stock TE_SendBeamFlagToAll(const Float:pos[3], const Float:ang[3], ModelIndex, model2, model3, bool:clientfound)
{
	new total = 0;
	new clients[MaxClients];
	for(new i = 1; i<= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			clients[total++] = i;
		}
	}
	TE_SendBeamFlag(clients, total, pos, ang, ModelIndex, model2, model3, clientfound);
}
stock TE_SendBeamFlagToClient(client, const Float:pos[3], const Float:ang[3], ModelIndex, model2, model3, bool:clientfound)
{
    new clients[1];
    clients[0] = client;
    TE_SendBeamFlag(clients, 1, pos, ang, ModelIndex, model2, model3, clientfound);
}
stock TE_SendBeamFlag(clients[], numClients, const Float:pos[3], const Float:ang[3], ModelIndex, model2, model3, bool:clientfound)
{
	new Float:buffer[3];
	buffer = pos;
	buffer[2] += 5.0;
	// new Float:flag[3];
	// new Float:rad = DegToRad(ang[1]);
	// flag[0] = up[0] + 25.0*Cosine(rad);
	// flag[1] = up[1] + 25.0*Sine(rad);
	// flag[2] = pos[2] + 58.0;
	// new Float:bottom[3];
	// bottom = up;
	// bottom[2] = pos[2] + 42.0;
	if(!clientfound)
	{
		// TE_SetupBeamPoints(buffer, up, ModelIndex, 0, 0, 0, 0.25, 2.0, 2.0, 5, 0.0, color, 0);
	}
	else
	{
		new Float:up[3];
		up = buffer;
		up[2] = buffer[2]+400;
		new color[4];
		color[0] = GetRandomInt(125, 255);
		color[1] = GetRandomInt(100, 154);
		color[2] = GetRandomInt(50, 84);
		color[3] = GetRandomInt(121, 243);
		TE_SetupBeamPoints(buffer, up, ModelIndex, ModelIndex, 0, 1, 0.25, 2.0, 2.0, 1, 1.0, color, 10);
		TE_Send(clients, numClients);
	}
	// up[2] -= 1.0;
	// TE_SetupBeamPoints(up, flag, ModelIndex, 0, 0, 0, 1.0, 0.5, 0.5, 5, 0.0, color, 0);
	// TE_Send(clients, numClients);
	// TE_SetupBeamPoints(flag, bottom, ModelIndex, 0, 0, 0, 1.0, 0.5, 0.5, 5, 0.0, color, 0);
	// TE_Send(clients, numClients);
	new randco[4];
	randco[0] = GetRandomInt(0, 255);
	randco[1] = GetRandomInt(0, 255);
	randco[2] = GetRandomInt(0, 255);
	randco[3] = 255;
	TE_SetupBeamRingPoint(buffer, 10.0, 75.0, model2, model3, 1, 1, 0.25, 2.25, 0.0, randco, 10, 0);
	TE_Send(clients, numClients);
	TE_SetupBeamRingPoint(buffer, 70.0, 75.0, model2, model3, 1, 1, 0.25, 2.25, 0.0, {125, 148, 212, 255}, 10, 0);
	TE_Send(clients, numClients);
	new Float:vec[3];
	// TE_SetupMetalSparks(pos, vec) 
	TE_SetupEnergySplash(buffer, vec, true);
	TE_Send(clients, numClients);
}
stock TE_SendAkbFlagToAll(const Float:pos[3], const Float:ang[3], ModelIndex, model2, model3)
{
	new total = 0;
	new clients[MaxClients];
	for(new i = 1; i<= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			clients[total++] = i;
		}
	}
	TE_SendAkbFlag(clients, total, pos, ang, ModelIndex, model2, model3);
}
stock TE_SendAkbFlagToClient(client, const Float:pos[3], const Float:ang[3], ModelIndex, model2, model3)
{
    new clients[1];
    clients[0] = client;
    TE_SendAkbFlag(clients, 1, pos, ang, ModelIndex, model2, model3);
}
stock TE_SendAkbFlag(clients[], numClients, const Float:pos[3], const Float:ang[3], ModelIndex, model2, model3)
{
	new Float:buffer[3];
	buffer = pos;
	buffer[2] += 5.0;
	new Float:up[3];
	up = buffer;
	up[2] = buffer[2]+400;
	new color[4];
	color[0] = GetRandomInt(125, 255);
	color[1] = GetRandomInt(100, 154);
	color[2] = GetRandomInt(50, 84);
	color[3] = GetRandomInt(121, 243);
	TE_SetupBeamPoints(buffer, up, ModelIndex, ModelIndex, 0, 1, 1.0, 2.0, 2.0, 1, 1.0, color, 10);
	TE_Send(clients, numClients);
	new randco[4];
	randco[0] = GetRandomInt(0, 255);
	randco[1] = GetRandomInt(0, 255);
	randco[2] = GetRandomInt(0, 255);
	randco[3] = 255;
	TE_SetupBeamRingPoint(buffer, 0.0, 100.0, model2, model3, 1, 1, 1.0, 3.25, 0.0, randco, 10, 0);
	TE_Send(clients, numClients);
	TE_SetupBeamRingPoint(buffer, 99.0, 100.0, model2, model3, 1, 1, 1.0, 3.25, 0.0, {125, 148, 212, 255}, 10, 0);
	TE_Send(clients, numClients);
	new Float:vec[3];
	// TE_SetupMetalSparks(pos, vec) 
	TE_SetupEnergySplash(buffer, vec, true);
	TE_Send(clients, numClients);
}
stock bool:IsPlayerInFlag(client, const Float:pos[3], const Float:radius)
{
	new Float:buffer[3];
	buffer = pos;
	if(!IsPlayerAlive(client))
	{
		return false;
	}
	new Float:origin[3];
	GetClientAbsOrigin(client, origin);
	if(origin[2] < buffer[2]-5.0 || origin[2] > buffer[2] + 64.0)
	{
		return false;
	}
	buffer[2] = 0.0;
	origin[2] = 0.0;
	if(GetVectorDistance(buffer, origin) > radius)
	{
		return false;
	}
	return true;
}
stock GetBotId()
{
	new bool:botfound, botid;
	for(new i = 1; i<= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(IsFakeClient(i))
			{
				botfound = true;
				botid = i;
				break
			}
		}
	}
	if(botfound)
	{
		return botid;
	}
	else
	{
		return -1;
	}
}
stock SayText2ToAll(client, const String:message[], any:...)
{ 
	new Handle:buffer = INVALID_HANDLE;
	new String:txt[255];
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			SetGlobalTransTarget(i);
			VFormat(txt, sizeof(txt), message, 3);	
			buffer = StartMessageOne("SayText2", i);
			if (buffer != INVALID_HANDLE)
			{ 				
				BfWriteByte(buffer, client);
				BfWriteByte(buffer, true);
				BfWriteString(buffer, txt);
				EndMessage(); 
				buffer = INVALID_HANDLE;	
			}	
		}
	}
}
stock SayText2To(client, target, const String:message[], any:...)
{ 	
	new Handle:buffer = StartMessageOne("SayText2", target);		
	new String:txt[255];
	SetGlobalTransTarget(target);
	VFormat(txt, sizeof(txt), message, 4);	
	if (buffer != INVALID_HANDLE)
	{ 		
		BfWriteByte(buffer, client);
		BfWriteByte(buffer, true);
		BfWriteString(buffer, txt);
		EndMessage(); 
	}
}
stock AddFolderToDownloadsTable(const String:sDirectory[])
{
	decl String:sFile[64], String:sPath[512];
	new FileType:iType, Handle:hDir = OpenDirectory(sDirectory);
	while(ReadDirEntry(hDir, sFile, sizeof(sFile), iType))     
	{
		if(iType == FileType_File)
		{
			Format(sPath, sizeof(sPath), "%s/%s", sDirectory, sFile);
			AddFileToDownloadsTable(sPath);
			if(StrContains(sPath, ".mdl") != -1 || StrContains(sPath, ".vmt") != -1)
			{
				PrecacheModel(sPath, true);
			}
			else if(StrContains(sPath, ".mp3") != -1 || StrContains(sPath, ".wav") != -1)
			{
				ReplaceStringEx(sPath, 256, "sound/", "");
				PrecacheSound(sPath);
			}
		}
	}
}
stock GetGroundOrigin(client, Float:pos[3])
{
	new Float:fOrigin[3], Float:result[3];
	GetClientAbsOrigin(client, fOrigin);
	TraceClientGroundOrigin(client, result, 100.0);
	pos = fOrigin;
	pos[2] = result[2];
}
stock GetGroundOrigin2(client, Float:pos[3])
{
	new Float:fOrigin[3], Float:temp[3], Float:result[3];
	GetClientAbsOrigin(client, fOrigin);
	GetClientEyePosition(client, temp);
	TraceClientGroundOrigin(client, result, 200.0);
	pos = fOrigin;
	pos[2] = result[2];
}
stock TraceWallOrigin(Float:fOrigin[3], Float:vAngles[3], Float:result[3])
{
	new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(trace)) 
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}
stock TraceGroundOrigin(Float:fOrigin[3], Float:result[3])
{
	new Float:vAngles[3] = {90.0, 0.0, 0.0};
	new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(trace)) 
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}
stock TraceClientGroundOrigin(client, Float:result[3], Float:offset)
{
	new Float:temp[2][3];
	GetClientEyePosition(client, temp[0]);
	temp[1] = temp[0];
	temp[1][2] -= offset;
	new Float:mins[]={-16.0, -16.0, 0.0};
	new Float:maxs[]={16.0, 16.0, 60.0};
	new Handle:trace = TR_TraceHullFilterEx(temp[0], temp[1], mins, maxs, MASK_SHOT, TraceEntityFilterPlayer);
	if(TR_DidHit(trace)) 
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}
stock GetAimOrigin(client, Float:hOrigin[3]) 
{
    new Float:vAngles[3], Float:fOrigin[3];
    GetClientEyePosition(client,fOrigin);
    GetClientEyeAngles(client, vAngles);

    new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

    if(TR_DidHit(trace)) 
    {
        TR_GetEndPosition(hOrigin, trace);
        CloseHandle(trace);
        return 1;
    }

    CloseHandle(trace);
    return 0;
}

public bool:TraceEntityFilterPlayer(entity, contentsMask) 
{
    return entity > MaxClients;
}
stock GetBeamEndOrigin(Float:fOrigin[3], Float:vAngles[3], Float:distance, Float:result[3])
{
	decl Float:AngleVector[3];
	GetAngleVectors(vAngles, AngleVector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(AngleVector, AngleVector);
	ScaleVector(AngleVector, distance);	
	AddVectors(fOrigin, AngleVector, result);
}
stock GetBeamHitOrigin(Float:fOrigin[3], Float:vAngles[3], Float:result[3])
{
    new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
    if(TR_DidHit(trace)) 
    {
        TR_GetEndPosition(result, trace);
        CloseHandle(trace);
    }
}
stock bool:GetClientAimPosition(client, Float:maxtracedistance, Float:resultvecpos[3], Float:resultvecnormal[3])
{		
	decl Float:cleyepos[3], Float:cleyeangle[3], Float:eyeanglevector[3];
	GetClientEyePosition(client, cleyepos); 
	GetClientEyeAngles(client, cleyeangle);
	new Handle:traceresulthandle = INVALID_HANDLE;
	traceresulthandle = TR_TraceRayFilterEx(cleyepos, cleyeangle, MASK_SOLID, RayType_Infinite, TraceEntityFilterAll);						
	if(TR_DidHit(traceresulthandle) == true)
	{
		decl Float:endpos[3];
		TR_GetEndPosition(endpos, traceresulthandle);
		TR_GetPlaneNormal(traceresulthandle, resultvecnormal);
		//거리가 일정 이하일 경우
		if((GetVectorDistance(cleyepos, endpos) <= maxtracedistance) || maxtracedistance <= 0)
		{
			resultvecpos[0] = endpos[0];
			resultvecpos[1] = endpos[1];
			resultvecpos[2] = endpos[2];
			CloseHandle(traceresulthandle);
			return true;
		}
		else
		{
			GetAngleVectors(cleyeangle, eyeanglevector, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(eyeanglevector, eyeanglevector);
			ScaleVector(eyeanglevector, maxtracedistance);
			
			AddVectors(cleyepos, eyeanglevector, resultvecpos);
			
			CloseHandle(traceresulthandle);
			return true;
		}
	}
	CloseHandle(traceresulthandle);
	return false;
}
public bool:TraceEntityFilterAll(entity, contentsMask)
{
	return true;
}
stock TE_SendBeamBoxToAll(const Float:uppercorner[3], const Float:bottomcorner[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life, Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, const Color[4], Speed)
{
    new total = 0;
    new clients[MaxClients];
    for (new i=1; i<=MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            clients[total++] = i;
        }
    }
    TE_SendBeamBox(clients, total, uppercorner, bottomcorner, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
}
stock TE_SendBeamBoxToClient(client, const Float:uppercorner[3], const Float:bottomcorner[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life, Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, const Color[4], Speed)
{
    new clients[1];
    clients[0] = client;
    TE_SendBeamBox(clients, 1, uppercorner, bottomcorner, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
}
//TE_SendBeamBoxToClient(i, g_fCheckCoord_A[drawbox[i]], g_fCheckCoord_B[drawbox[i]], g_Beam, 0, 0, 0, 0.1, 3.0, 3.0, 10, 0.0, {0,255,255,255}, 0);
stock TE_SendBeamBox(clients[], numClients, const Float:uppercorner[3], const Float:bottomcorner[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life, Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, const Color[4], Speed)
{
    // Create the additional corners of the box
    new Float:tc1[3];
    AddVectors(tc1, uppercorner, tc1);
    tc1[0] = bottomcorner[0];
    new Float:tc2[3];
    AddVectors(tc2, uppercorner, tc2);
    tc2[1] = bottomcorner[1];
    new Float:tc3[3];
    AddVectors(tc3, uppercorner, tc3);
    tc3[2] = bottomcorner[2];
    new Float:tc4[3];
    AddVectors(tc4, bottomcorner, tc4);
    tc4[0] = uppercorner[0];
    new Float:tc5[3];
    AddVectors(tc5, bottomcorner, tc5);
    tc5[1] = uppercorner[1];
    new Float:tc6[3];
    AddVectors(tc6, bottomcorner, tc6);
    tc6[2] = uppercorner[2];
    
    // Draw all the edges
    TE_SetupBeamPoints(uppercorner, tc1, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
    TE_Send(clients, numClients);
    TE_SetupBeamPoints(uppercorner, tc2, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
    TE_Send(clients, numClients);
    TE_SetupBeamPoints(uppercorner, tc3, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
    TE_Send(clients, numClients);
    TE_SetupBeamPoints(tc6, tc1, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
    TE_Send(clients, numClients);
    TE_SetupBeamPoints(tc6, tc2, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
    TE_Send(clients, numClients);
    TE_SetupBeamPoints(tc6, bottomcorner, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
    TE_Send(clients, numClients);
    TE_SetupBeamPoints(tc4, bottomcorner, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
    TE_Send(clients, numClients);
    TE_SetupBeamPoints(tc5, bottomcorner, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
    TE_Send(clients, numClients);
    TE_SetupBeamPoints(tc5, tc1, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
    TE_Send(clients, numClients);
    TE_SetupBeamPoints(tc5, tc3, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
    TE_Send(clients, numClients);
    TE_SetupBeamPoints(tc4, tc3, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
    TE_Send(clients, numClients);
    TE_SetupBeamPoints(tc4, tc2, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
    TE_Send(clients, numClients);
}