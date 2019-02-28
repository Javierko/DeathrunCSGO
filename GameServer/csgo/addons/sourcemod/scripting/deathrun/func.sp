/*
    > Misc <
*/

stock int Func_CountTeamPlayers(int team)
{
	int count = 0;
	LoopClients(i)
	{
		if(IsValidClient(i) && GetClientTeam(i) == team)
		{
			count++;
		}
	}
	return count;
}

stock void Func_StripPlayerWeapons(int client)
{
    if(IsValidClient(client))
    {
        int iWepIndex;
        for(int x = 0; x <= 5; x++)
        {
            if(x != CS_SLOT_KNIFE && (iWepIndex = GetPlayerWeaponSlot(client, x)) != -1)
            {
                RemovePlayerItem(client, iWepIndex);
                AcceptEntityInput(iWepIndex, "Kill");
            }
        }
        
        int iKnife = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
        
        if(iKnife != -1)
        {
            EquipPlayerWeapon(client, iKnife);
        }
    }
}

stock int Func_GetRandomPlayer()
{
    int clients[MAXPLAYERS  + 1];
    int clientCount;
     
    for (int i = 1; i <= MAXPLAYERS ; i++)
    {
        if(IsValidClient(i) && GetClientTeam(i) == CS_TEAM_CT)
        {
            clients[clientCount++] = i;
        }
    }

    return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
}

stock void Func_SetCvar(char[] scvar, char[] svalue)
{
	Handle cvar = FindConVar(scvar);
	SetConVarString(cvar, svalue, true);
}

public void Func_DownloadAndPrecacheFiles() /* Credits: ESK0's blockmaker */
{
    if(FileExists(g_szDownloadPath) == false)
    {
        SetFailState("There is not download file: %s", g_szDownloadPath);
        
        return;
    }
    
    File fileDownloadFile = OpenFile(g_szDownloadPath, "r");
    char szDownloadFile[PLATFORM_MAX_PATH];
    int iLen;
    
    while(fileDownloadFile.ReadLine(szDownloadFile, sizeof(szDownloadFile)))
    {
        iLen = strlen(szDownloadFile);
        if(szDownloadFile[iLen - 1] == '\n')
            szDownloadFile[--iLen] = '\0';
            
        TrimString(szDownloadFile);
        
        if(FileExists(szDownloadFile) == true)
        {
            int iNamelen = strlen(szDownloadFile) - 4;
            if(StrContains(szDownloadFile,".mdl",false) == iNamelen)
                PrecacheModel(szDownloadFile, true);

            AddFileToDownloadsTable(szDownloadFile);
        }
        
        if(fileDownloadFile.EndOfFile())
            break;
    }
    
    delete fileDownloadFile;
}

stock int GetClientWaterLevel(int client)
{
	return GetEntProp(client, Prop_Send, "m_nWaterLevel");
}

/*
    > Player stocks <
*/

stock bool IsValidClient(int client)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
    {
        return false;
    }
    
    return true;
}

stock bool IsClientJoker(int client)
{
    if(GetClientTeam(client) == CS_TEAM_T)
    {
        if(client == g_iJoker)
        {
            return true;
        }
    }

    return false;
}

stock bool IsClientBatman(int client)
{
    if(GetClientTeam(client) == CS_TEAM_CT)
    {
        return true;
    }

    return false;
}

stock bool IsPlayerVIP(int client)
{
    return CheckCommandAccess(client, "", ADMFLAG_RESERVATION);
}