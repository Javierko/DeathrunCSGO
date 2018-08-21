public void ShowJokerMenu(int client)
{
	char buffer[256];
	Format(buffer,sizeof(buffer),"--- Joker Menu --- \n-------------------------------");
	Menu JokerMenu = CreateMenu(h_JokerMenu);
	JokerMenu.SetTitle(buffer);
	
	if(!joker_speedup && joker_bhop) JokerMenu.AddItem("toggle", "Ability [AutoBhop]\n -------------------------------");
	if(joker_speedup && !joker_bhop) JokerMenu.AddItem("toggle", "Ability [SpeedUp+]\n -------------------------------");
	
	if(!fr_enable) JokerMenu.AddItem("fr", "FreeRUN");
	else if(fr_enable) JokerMenu.AddItem("fr", "FreeRUN",ITEMDRAW_DISABLED);
	JokerMenu.Display(client, MENU_TIME_FOREVER);
	JokerMenu.ExitButton = false;
}

public int h_JokerMenu(Handle JokerMenu, MenuAction action, int client, int index)
{
	if(action == MenuAction_Select && GetClientTeam(client) == CS_TEAM_T && IsValidClient(client) && IsClientJoker(client))
	{
		char Item[20];
		GetMenuItem(JokerMenu, index, Item, sizeof(Item));
		{
			if(StrEqual(Item, "toggle"))
			{
				if(joker_bhop) joker_bhop = false, joker_speedup = true;
				else joker_bhop = true, joker_speedup = false;
			}
			if(StrEqual(Item, "fr"))
			{
				Event_Freerun(client);
			}
		}
		ShowJokerMenu(client);
	}
}

public void ShowBatmanMenu(int client)
{
	char buffer[256];
	Format(buffer,sizeof(buffer),"--- Batman Menu --- \n --------------------");
	Menu Batmanmenu = CreateMenu(h_Batmanmenu);
	Batmanmenu.SetTitle(buffer);
	
	if(!b_CTDoubleJump[client] && !b_CTBhop[client]) Batmanmenu.AddItem("bhop", "AutoBhop");
	if(!b_CTDoubleJump[client] && b_CTBhop[client]) Batmanmenu.AddItem("bhop", "AutoBhop [Activated]",ITEMDRAW_DISABLED);
	if(b_CTDoubleJump[client] && !b_CTBhop[client]) Batmanmenu.AddItem("bhop", "AutoBhop",ITEMDRAW_DISABLED);
	
	Format(buffer,sizeof(buffer),"DoubleJump \n --------------------");
	if(!b_CTDoubleJump[client] && !b_CTBhop[client]) Batmanmenu.AddItem("doublejump", buffer);
	Format(buffer,sizeof(buffer),"DoubleJump [Activated]\n --------------------");
	if(b_CTDoubleJump[client] && !b_CTBhop[client]) Batmanmenu.AddItem("doublejump", buffer,ITEMDRAW_DISABLED)
	Format(buffer,sizeof(buffer),"DoubleJump \n --------------------");
	if(!b_CTDoubleJump[client] && b_CTBhop[client]) Batmanmenu.AddItem("doublejump", buffer,ITEMDRAW_DISABLED);
	if(!b_HidePlayers[client]) Batmanmenu.AddItem("hide", "Hide TeamMates [OFF]");
	else Batmanmenu.AddItem("hide", "Hide TeamMates [ON]");
	Batmanmenu.Display(client, MENU_TIME_FOREVER);
	Batmanmenu.ExitButton = false;
}

public int h_Batmanmenu(Handle Batmanmenu, MenuAction action, int client, int index)
{
	if(action == MenuAction_Select && GetClientTeam(client) == CS_TEAM_CT && IsValidClient(client))
	{
		char Item[20];
		GetMenuItem(Batmanmenu, index, Item, sizeof(Item));
		{
			if(StrEqual(Item, "bhop"))
			{
				b_CTBhop[client] = true;
				CPrintToChat(client, "{Darkred}(!){Default} You activated BHOP!", s_Tag);
			}
			if(StrEqual(Item, "doublejump"))
			{
				b_CTDoubleJump[client] = true;
				CPrintToChat(client, "{Darkred}(!){Default} You activated DoubleJump!", s_Tag);
			}
			if(StrEqual(Item, "hide"))
			{
				if(!b_HidePlayers[client])
				{
					b_HidePlayers[client] = true;
					CPrintToChat(client, "{Darkred}(!){Default} TeamMates are disabled!", s_Tag);
				}
				else
				{
					b_HidePlayers[client] = false;
					CPrintToChat(client, "{Darkred}(!){Default} TeamMates are enabled!", s_Tag);
				}
			}
		}
	}
}

public void ShowHelpMenu(int client)
{
	char buffer[256];
	Format(buffer,sizeof(buffer),"--- Help --- \n --------------------------------------------");
	Format(buffer,sizeof(buffer),"%s \n !joker - Shows joker´s menu",buffer);
	Format(buffer,sizeof(buffer),"%s \n !batman - Shows batman´s menu",buffer);
	Format(buffer,sizeof(buffer),"%s \n !fr/!freerun - Start Freerun round",buffer);
	//Format(buffer,sizeof(buffer),"%s \n !music - Vypne nebo Zapne roundsounds",buffer);
	Format(buffer,sizeof(buffer),"%s \n !rs - Reset score \n --------------------------------------------",buffer);
	Menu HelpMenu = CreateMenu(h_HelpMenu);
	HelpMenu.SetTitle(buffer);
	HelpMenu.AddItem("exit", "Exit");
	HelpMenu.ExitButton = false;
	HelpMenu.Display(client, MENU_TIME_FOREVER);
}

public int h_HelpMenu(Handle HelpMenu, MenuAction action, int client, int index)
{
	if(action == MenuAction_Select && GetClientTeam(client) == CS_TEAM_T && IsValidClient(client) && IsClientJoker(client))
	{
		char Item[20];
		GetMenuItem(HelpMenu, index, Item, sizeof(Item));
		{
			//
		}
	}
}

public void ShowPravidlaMenu(int client)
{
	char buffer[1024];
	Format(buffer,sizeof(buffer),"--- Rules --- \n--------------------------------------------");
	Format(buffer,sizeof(buffer),"%s \n - Dont blame or humiliate other players in any way.",buffer);
	Format(buffer,sizeof(buffer),"%s \n - Hacking/Cheating is not allowed.",buffer);
	Format(buffer,sizeof(buffer),"%s \n - You cant use map bugs to your advantage.",buffer);
	Format(buffer,sizeof(buffer),"%s \n - You cant spam traps.",buffer);
	Format(buffer,sizeof(buffer),"%s \n - You can not shorten the map or attempt it.",buffer);
	Format(buffer,sizeof(buffer),"%s \n - If you found bug, dont forget to tell it to some head admin.",buffer);
	Format(buffer,sizeof(buffer),"%s \n - For CT, therefore Anti-Joker team can not deliberately delay the game.",buffer);
	Format(buffer,sizeof(buffer),"%s \n - The Joker is your duty to run traps and attractions, you must not arbitrarily let CT (Anti-Jokerteam) pass.",buffer);
	Format(buffer,sizeof(buffer),"%s \n - The last and golden rule, never in any way deliberately do not even blow up the game.",buffer);
	Menu PravidlaMenu = CreateMenu(h_PravidlaMenu);
	PravidlaMenu.SetTitle(buffer);
	PravidlaMenu.AddItem("exit", "Exit");
	PravidlaMenu.ExitButton = false;
	PravidlaMenu.Display(client, MENU_TIME_FOREVER);
}

public int h_PravidlaMenu(Handle PravidlaMenu, MenuAction action, int client, int index)
{
	if(action == MenuAction_Select && GetClientTeam(client) == CS_TEAM_T && IsValidClient(client) && IsClientJoker(client))
	{
		char Item[20];
		GetMenuItem(PravidlaMenu, index, Item, sizeof(Item));
		{
			//
		}
	}
}