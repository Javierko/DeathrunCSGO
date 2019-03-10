void Menu_Joker(int client)
{
    if(IsValidClient(client))
    {
        if(IsClientJoker(client))
        {
            Menu menu = new Menu(mJoker);

            menu.SetTitle("Joker menu\n¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯");

            if(g_bJokerAbility[Speed])
                menu.AddItem("ability", "Ability [Speed]");
            else if(g_bJokerAbility[Bhop])
                menu.AddItem("ability", "Ability [Bhop]");

            menu.AddItem("freerun", "Freerun", g_bFreerun ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
            
            menu.Display(client, 90);
        }
        else
            CPrintToChat(client, "%s %t", g_szTag, "YoureNotJoker");
    }
}

public int mJoker(Menu menu, MenuAction action, int client, int index)
{
    if(action == MenuAction_Select)
    {
        if(IsValidClient(client))
        {
            if(IsClientJoker(client))
            {
                char szItem[32];
                menu.GetItem(index, szItem, sizeof(szItem));

                if(StrEqual(szItem, "ability"))
                {
                    if(g_bJokerAbility[Speed])
                    {
                        g_bJokerAbility[Speed] = false;
                        g_bJokerAbility[Bhop] = true;

                        CPrintToChat(client, "%s %t", g_szTag, "BhopTurnedOn");
                    }
                    else if(g_bJokerAbility[Bhop])
                    {
                        g_bJokerAbility[Speed] = true;
                        g_bJokerAbility[Bhop] = false;

                        CPrintToChat(client, "%s %t", g_szTag, "SpeedTurnedOn");
                    }

                    menu.Display(client, 90);
                }
                else if(StrEqual(szItem, "freerun"))
                {
                    Command_Freerun(client, 0);
                }
            }
            else
                CPrintToChat(client, "%s %t", g_szTag, "YoureNotJoker");
        }
    }
}

//Batman
void Menu_Batman(int client)
{
    if(IsValidClient(client))
    {
        if(IsClientBatman(client))
        {
            Menu menu = new Menu(mBatman);
            menu.SetTitle("Batman menu\n¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯");

            if(g_bBatmanAbility[client][Bhop])
                menu.AddItem("ability", "Ability [Bhop]");
            else if(g_bBatmanAbility[client][Doublejump])
                menu.AddItem("ability", "Ability [Doublejump]");
            else if(!g_bBatmanAbility[client][Doublejump] && !g_bBatmanAbility[client][Bhop])
                menu.AddItem("ability", "Ability [-/-]");

            if(g_bHideMates[client])
                menu.AddItem("hide", "Hide Teammates [ON]");
            else if(!g_bHideMates[client])
                menu.AddItem("hide", "Hide Teammates [OFF]");

            if(g_bSaveAbility[client])
                menu.AddItem("save", "Save abilities [ON]");
            else if(!g_bSaveAbility[client])
                menu.AddItem("save", "Save abilities [OFF]");

            menu.Display(client, 90);
        }
        else
            CPrintToChat(client, "%s %t", g_szTag, "YoureNotBatman");
    }
}

public int mBatman(Menu menu, MenuAction action, int client, int index)
{
    if(action == MenuAction_Select)
    {
        if(IsValidClient(client))
        {
            if(IsClientBatman(client))
            {
                char szItem[32];
                menu.GetItem(index, szItem, sizeof(szItem));

                if(StrEqual(szItem, "ability"))
                {
                    if(g_bBatmanAbility[client][Bhop])
                    {
                        g_bBatmanAbility[client][Bhop] = false;
                        g_bBatmanAbility[client][Doublejump] = true;

                        CPrintToChat(client, "%s %t", g_szTag, "DoublejumpTurnedOn");
                    }
                    else if(g_bBatmanAbility[client][Doublejump])
                    {
                        g_bBatmanAbility[client][Bhop] = true;
                        g_bBatmanAbility[client][Doublejump] = false;

                        CPrintToChat(client, "%s %t", g_szTag, "BhopTurnedOn");
                    }
                    else if(!g_bBatmanAbility[client][Doublejump] && !g_bBatmanAbility[client][Bhop])
                    {
                        int iRand = GetRandomInt(0, 1);

                        switch(iRand)
                        {
                            case 0:
                            {
                                g_bBatmanAbility[client][Doublejump] = true;

                                CPrintToChat(client, "%s %t", g_szTag, "DoublejumpTurnedOn");
                            }
                            case 1:
                            {
                                g_bBatmanAbility[client][Bhop] = true;

                                CPrintToChat(client, "%s %t", g_szTag, "BhopTurnedOn");
                            }
                        }
                    }
                }
                else if(StrEqual(szItem, "hide"))
                {
                    g_bHideMates[client] = !g_bHideMates[client];

                    CPrintToChat(client, "%s %t", g_szTag, "HidePlayersToggle");
                }
                else if(StrEqual(szItem, "save"))
                {
                    g_bSaveAbility[client] = !g_bSaveAbility[client];

                    CPrintToChat(client, "%s %t", g_szTag, "SaveAbilityToggle");
                }

                Menu_Batman(client);
            }
            else
                CPrintToChat(client, "%s %t", g_szTag, "YoureNotBatman");
        }
    }
}