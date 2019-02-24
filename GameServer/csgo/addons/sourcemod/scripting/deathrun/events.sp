//Player spawn
public Action Event_PlayerSpawn(Handle event, const char[] strName, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    if(IsValidClient(client) && IsPlayerAlive(client))
    {
        if(IsClientBatman(client))
        {
            Menu_Batman(client);

            SetEntityModel(client, "models/player/custom_player/kuristaja/ak/batman/batmanv2.mdl");
            SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/player/custom_player/kuristaja/ak/batman/batman_arms.mdl");

            GivePlayerItem(client, "weapon_flashbang");
        }
        else if(IsClientJoker(client))
        {
            SetEntityModel(client, "models/player/custom_player/kuristaja/billy/billy.mdl");
            SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/player/custom_player/kuristaja/billy/billy_arms.mdl");

            g_bJokerAbility[Bhop] = true;
            g_bJokerAbility[Speed] = false;

            Menu_Joker(client);
        }

        Func_StripPlayerWeapons(client);
        CreateTimer(0.0, Timer_RemoveRadar, client);
    }
}

//Player death
public Action Event_PlayerDeath(Handle event, const char[] strName, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    if(IsValidClient(client))
    {
        if(IsClientBatman(client))
        {
            if(g_iClientLifes[client] != 0)
            {
                if(Func_CountTeamPlayers(CS_TEAM_CT) > 1)
                {
                    g_bBatmanAbility[client][Bhop] = false;
                    g_bBatmanAbility[client][Doublejump] = false;
                    g_bClientRespawn[client] = true;
                    g_fRespawnTime[client] = GetGameTime();
                }
            }
        }
    }
}

//Round Start
public void Event_RoundStart(Handle event, const char[] name, bool dontbroadcast)
{
    g_bJokerAbility[Speed] = false;
    g_bJokerAbility[Speed] = true;
    
    if(g_bFreerun)
    {
        if(GetRandomInt(1,3) == GetRandomInt(1,3))
        {
            g_bFreerun = false;
        }
    }
    
    LoopClients(i)
    {
        if(IsValidClient(i) && IsPlayerAlive(i))
        {
            g_bBatmanAbility[i][Bhop] = false;
            g_bBatmanAbility[i][Doublejump] = false;

            Func_StripPlayerWeapons(i);

            if(IsPlayerVIP(i))
                g_iClientLifes[i] = 3;
            else
                g_iClientLifes[i] = 1;
        }
    }
}

//Pre round start
public void Event_RoundStart_Pre(Handle event, const char[] name, bool dontbroadcast)
{
	if(Func_CountTeamPlayers(CS_TEAM_T) == 0)
	{
		g_iJoker = Func_GetRandomPlayer();

		if(IsValidClient(g_iJoker))
		{
			CS_SwitchTeam(g_iJoker, CS_TEAM_T);
			CPrintToChatAll("%s %t", g_szTag, "NewJoker", g_iJoker);
		}
	}
}

//Round end
public void Event_RoundEnd(Handle event, const char[] name, bool dontbroadcast)
{
    int iWinner = GetEventInt(event, "winner");
    
    if (iWinner == CS_TEAM_CT)
        CPrintToChatAll("%s %t", g_szTag, "BatmansWin");
    else if (iWinner == CS_TEAM_T)
        CPrintToChatAll("%s %t", g_szTag, "JokersWin");

    if(Func_CountTeamPlayers(CS_TEAM_T) > 0)
    {
        LoopClients(i)
        {
            if(IsValidClient(i))
                CS_SwitchTeam(i, CS_TEAM_CT);
        }
    }
}

//Player blind
public void Event_PlayerBlind(Handle event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    if(IsValidClient(client) && IsPlayerAlive(client))
    {
        float fDuration = GetEntPropFloat(client, Prop_Send, "m_flFlashDuration");
        CreateTimer(fDuration, Timer_RemoveRadar, client);
    }
}