//Player spawn
public Action Event_PlayerSpawn(Handle event, const char[] strName, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    if(IsValidClient(client) && IsPlayerAlive(client))
    {
        if(IsClientBatman(client))
        {
            if(g_cvModels.BoolValue)
            {
                SetEntityModel(client, "models/player/custom_player/kuristaja/ak/batman/batmanv2.mdl");
                SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/player/custom_player/kuristaja/ak/batman/batman_arms.mdl");
            }

            GivePlayerItem(client, "weapon_flashbang");
        }
        else if(IsClientJoker(client))
        {
            if(g_cvModels.BoolValue)
            {
                SetEntityModel(client, "models/player/custom_player/kuristaja/billy/billy_normal.mdl");
                SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/player/custom_player/kuristaja/billy/billy_arms.mdl");
            }

            g_bJokerAbility.Bhop = false;
            g_bJokerAbility.Speed = true;
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
            if(g_cvRespawn.BoolValue)
            {
                if(g_iClientLifes[client] != 0)
                {
                    if(Func_CountTeamPlayers(CS_TEAM_CT) > 1)
                    {
                        g_bClientRespawn[client] = true;
                        g_fRespawnTime[client] = GetGameTime();
                    }
                }
                else
                {
                    if(!g_bSaveAbility[client])
                    {
                        g_bBatmanAbility[client].Bhop = false;
                        g_bBatmanAbility[client].DoubleJump = false;
                        g_bBatmanAbility[client].Gravity = false;
                    }
                }
            }
            else
            {
                if(!g_bSaveAbility[client])
                {
                    g_bBatmanAbility[client].Bhop = false;
                    g_bBatmanAbility[client].DoubleJump = false;
                    g_bBatmanAbility[client].Gravity = false;
                }
            }
        }
    }
}

//Round Start
public void Event_RoundStart(Handle event, const char[] name, bool dontbroadcast)
{
    g_bJokerAbility.Bhop = false;
    g_bJokerAbility.Speed = true;
    g_bFreerun = false;
    
    if(g_cvFreerun.BoolValue)
    {
        if(g_cvRandomFreerun.BoolValue)
        {
            if(!g_bFreerun)
            {
                if(GetRandomInt(1,5) == GetRandomInt(1,5))
                {
                    g_bFreerun = true;

                    CPrintToChatAll("%s %t", g_szTag, "FreerunTurnedOn");
                }
            }
        }
    }
    
    LoopClients(i)
    {
        if(IsValidClient(i) && IsPlayerAlive(i))
        {
            if(!g_bSaveAbility[i])
            {
                g_bBatmanAbility[i].Bhop = false;
                g_bBatmanAbility[i].DoubleJump = false;
                g_bBatmanAbility[i].Gravity = false;
            }

            Func_StripPlayerWeapons(i);

            if(g_cvRespawn.BoolValue)
            {
                char szBuffer[128];

                if(IsPlayerVIP(i))
                {
                    g_cvLifesVIP.GetString(szBuffer, sizeof(szBuffer));

                    g_iClientLifes[i] = StringToInt(szBuffer);
                }
                else
                {
                    g_cvLifesNonVIP.GetString(szBuffer, sizeof(szBuffer));

                    g_iClientLifes[i] = StringToInt(szBuffer);
                }
            }
        }
    }

    LoopClients(i)
    {
        if(IsValidClient(i))
        {
            if(IsClientJoker(i))
            {
                Menu_Joker(i);
            }
            else if(IsClientBatman(i))
            {
                Menu_Batman(i);
            }
        }
    }
}

//Pre round start
public void Event_RoundStart_Pre(Handle event, const char[] name, bool dontbroadcast)
{
    g_bDisabledJoker = false;
    
    if(Func_CountTeamPlayers(CS_TEAM_CT) <= 1)
    {
        g_bDisabledJoker = true;
    }
        
    if(Func_CountTeamPlayers(CS_TEAM_T) == 0 && !g_bDisabledJoker)
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
    
    if(iWinner == CS_TEAM_CT)
    {
        CPrintToChatAll("%s %t", g_szTag, "BatmansWin");
    }
    else if (iWinner == CS_TEAM_T)
    {
        CPrintToChatAll("%s %t", g_szTag, "JokersWin");
    }

    if(Func_CountTeamPlayers(CS_TEAM_T) > 0)
    {
        LoopClients(i)
        {
            if(IsValidClient(i))
            {
                g_iJoker = -1;
                CS_SwitchTeam(i, CS_TEAM_CT);
            }
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