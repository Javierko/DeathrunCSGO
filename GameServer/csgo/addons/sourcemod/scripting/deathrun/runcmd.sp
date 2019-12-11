public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
    if(IsValidClient(client))
    {
        if(IsClientBatman(client))
        {
            if(g_cvRespawn.BoolValue)
            {
                if(g_bClientRespawn[client])
                {
                    if(g_iClientLifes[client] > 0)
                    {
                        float fTimeleft = ((g_fRespawnTime[client] - GetGameTime()) + 5.0);
                        
                        if(fTimeleft > 0.01)
                        {
                            PrintHintText(client, "%t", "DeathHud", fTimeleft);
                        }
                        else if(fTimeleft < 0.01)
                        {
                            CS_RespawnPlayer(client);
                            g_iClientLifes[client]--;
                            g_bClientRespawn[client] = false;
                            PrintToChat(client, "%s %t", g_szTag, "YourLifes", g_iClientLifes[client]);
                        }
                    }
                }
            }
        }
    }
    
    if(IsValidClient(client) && IsPlayerAlive(client))
    {
        if(IsClientBatman(client))
        {
            if(g_bBatmanAbility[client].Bhop)
            {
                int iIndex = GetEntProp(client, Prop_Data, "m_nWaterLevel");
                int iWater = EntIndexToEntRef(iIndex);
                
                if(iWater != INVALID_ENT_REFERENCE)
                {
                    if(buttons & IN_JUMP)
                    {
                        if(!(GetClientWaterLevel(client) > 1))
                        {
                            if(!(GetEntityMoveType(client) & MOVETYPE_LADDER))
                            {
                                SetEntPropFloat(client, Prop_Send, "m_flStamina", 0.0);
                                
                                if(!(GetEntityFlags(client) & FL_ONGROUND))
                                {
                                    buttons &= ~IN_JUMP;
                                }
                            }
                        }
                    }
                }
            }
            else if(g_bBatmanAbility[client].DoubleJump)
            {
                int iCurFlags = GetEntityFlags(client);
                int iCurButtons = GetClientButtons(client);

                if(g_iLastFlags[client] & FL_ONGROUND)
                {
                    if(!(iCurFlags & FL_ONGROUND) && !(g_iLastButtons[client] & IN_JUMP) && iCurButtons & IN_JUMP)
                    {
                        g_iJumpsCount[client]++;
                    }
                }
                else if(iCurFlags & FL_ONGROUND)
                {
                    g_iJumpsCount[client] = 0;
                }
                else if(!(g_iLastButtons[client] & IN_JUMP) && iCurButtons & IN_JUMP)
                {
                    int iMaxjump = 1;
                    
                    if(1 <= g_iJumpsCount[client] <= iMaxjump)
                    {
                        g_iJumpsCount[client]++;
                        
                        float fVel[3];
                        
                        GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVel);
                        fVel[2] = 250.0;
                        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVel);
                    }
                }
                
                g_iLastFlags[client] = iCurFlags;
                g_iLastButtons[client] = iCurButtons;
            }
        }
        else if(IsClientJoker(client))
        {
            if(g_bJokerAbility.Bhop && !g_bJokerAbility.Speed)
            {
                int iIndex = GetEntProp(client, Prop_Data, "m_nWaterLevel");
                int iWater = EntIndexToEntRef(iIndex);
                
                if(iWater != INVALID_ENT_REFERENCE)
                {
                    if(buttons & IN_JUMP)
                    {
                        if(!(GetClientWaterLevel(client) > 1))
                        {
                            if(!(GetEntityMoveType(client) & MOVETYPE_LADDER))
                            {
                                SetEntPropFloat(client, Prop_Send, "m_flStamina", 0.0);
                                
                                if(!(GetEntityFlags(client) & FL_ONGROUND))
                                {
                                    buttons &= ~IN_JUMP;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}