void Menu_Joker(int client)
{
    if(IsValidClient(client))
    {
        if(IsClientJoker(client))
        {
            Menu menu = new Menu(mJoker);

            menu.SetTitle("Joker menu\n¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯");

            if(g_bJokerAbility.Speed)
            {
                menu.AddItem("ability", "Ability [Speed]");
            }
            else if(g_bJokerAbility.Bhop)
            {
                menu.AddItem("ability", "Ability [Bhop]");
            }

            if(g_cvFreerun.BoolValue)
            {
                menu.AddItem("freerun", "Freerun", g_bFreerun ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
            }
            
            menu.Display(client, 90);
        }
        else
        {
            CPrintToChat(client, "%s %t", g_szTag, "YoureNotJoker");
        }
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
                    if(g_bJokerAbility.Speed)
                    {
                        g_bJokerAbility.Speed = false;
                        g_bJokerAbility.Bhop = true;

                        CPrintToChat(client, "%s %t", g_szTag, "BhopTurnedOn");
                    }
                    else if(g_bJokerAbility.Bhop)
                    {
                        g_bJokerAbility.Speed = true;
                        g_bJokerAbility.Bhop = false;

                        CPrintToChat(client, "%s %t", g_szTag, "SpeedTurnedOn");
                    }

                    Menu_Joker(client);
                }
                else if(StrEqual(szItem, "freerun"))
                {
                    Command_Freerun(client, 0);
                }
            }
            else
            {
                CPrintToChat(client, "%s %t", g_szTag, "YoureNotJoker");
            }
        }
    }
    else if(action == MenuAction_End)
    {
        delete menu;
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

            if(g_bBatmanAbility[client].Bhop)
            {
                menu.AddItem("ability", "Ability [Bhop]");
            }
            else if(g_bBatmanAbility[client].DoubleJump)
            {
                menu.AddItem("ability", "Ability [DoubleJump]");
            }
            else if(g_bBatmanAbility[client].Gravity)
            {
                menu.AddItem("ability", "Ability [Gravity]");
            }
            else if(!g_bBatmanAbility[client].DoubleJump && !g_bBatmanAbility[client].Bhop && !g_bBatmanAbility[client].Gravity)
            {
                menu.AddItem("ability", "Ability [-/-]");
            }

            if(g_bHideMates[client])
            {
                menu.AddItem("hide", "Hide Teammates [ON]");
            }
            else
            {
                menu.AddItem("hide", "Hide Teammates [OFF]");
            }

            if(g_bSaveAbility[client])
            {
                menu.AddItem("save", "Save abilities [ON]");
            }
            else
            {
                menu.AddItem("save", "Save abilities [OFF]");
            }

            menu.Display(client, 90);
        }
        else
        {
            CPrintToChat(client, "%s %t", g_szTag, "YoureNotBatman");
        }
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
                    Menu_Ability(client);
                }
                else if(StrEqual(szItem, "hide"))
                {
                    g_bHideMates[client] = !g_bHideMates[client];

                    CPrintToChat(client, "%s %t", g_szTag, "HidePlayersToggle");

                    Menu_Batman(client);
                }
                else if(StrEqual(szItem, "save"))
                {
                    g_bSaveAbility[client] = !g_bSaveAbility[client];

                    CPrintToChat(client, "%s %t", g_szTag, "SaveAbilityToggle");

                    Menu_Batman(client);
                }
            }
            else
            {
                CPrintToChat(client, "%s %t", g_szTag, "YoureNotBatman");
            }
        }
    }
}

void Menu_Both(int client)
{
    if(IsValidClient(client))
    {
        if(IsClientJoker(client))
        {
            Menu_Joker(client);
        }
        else if(IsClientBatman(client))
        {
            Menu_Batman(client);
        }
    }
}

void Menu_Ability(int client)
{
    if(IsValidClient(client))
    {
        if(IsClientBatman(client))
        {
            Menu menu = new Menu(mAbilityMenu);
            menu.SetTitle("Ability menu");

            menu.AddItem("bhop", "Bunny Hop", g_bBatmanAbility[client].Bhop ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
            menu.AddItem("dj", "Double Jump", g_bBatmanAbility[client].DoubleJump ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
            menu.AddItem("gravity", "Gravity", g_bBatmanAbility[client].Gravity ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

            menu.ExitBackButton = true;
            menu.Display(client, 60);
        }
        else
        {
            CPrintToChat(client, "%s %t", g_szTag, "YoureNotBatman");
        }
    }
}

public int mAbilityMenu(Menu menu, MenuAction action, int client, int index)
{
    if(action == MenuAction_Select)
    {
        if(IsValidClient(client))
        {
            if(IsClientBatman(client))
            {
                char szItem[32];
                menu.GetItem(index, szItem, sizeof(szItem));

                if(StrEqual(szItem, "bhop"))
                {
                    if(!g_bBatmanAbility[client].Bhop)
                    {
                        g_bBatmanAbility[client].Bhop = true;
                        g_bBatmanAbility[client].DoubleJump = false;
                        g_bBatmanAbility[client].Gravity = false;

                        CPrintToChat(client, "%s %t", g_szTag, "BhopTurnedOn");
                    }
                }
                else if(StrEqual(szItem, "dj"))
                {
                    if(!g_bBatmanAbility[client].DoubleJump)
                    {
                        g_bBatmanAbility[client].Bhop = false;
                        g_bBatmanAbility[client].DoubleJump = true;
                        g_bBatmanAbility[client].Gravity = false;

                        CPrintToChat(client, "%s %t", g_szTag, "DoublejumpTurnedOn");
                    }
                }
                else if(StrEqual(szItem, "gravity"))
                {
                    if(!g_bBatmanAbility[client].Gravity)
                    {
                        g_bBatmanAbility[client].Bhop = false;
                        g_bBatmanAbility[client].DoubleJump = false;
                        g_bBatmanAbility[client].Gravity = true;

                        CPrintToChat(client, "%s %t", g_szTag, "GravityTurnedOn");
                    }
                }

                Menu_Batman(client);
            }
        }
    }
    else if(action == MenuAction_End)
    {
        delete menu;
    }
    else if(action == MenuAction_Cancel)
    {
        if(index == MenuCancel_ExitBack)
        {
            Menu_Batman(client);
        }
    }
}