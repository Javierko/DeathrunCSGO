#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <emitsoundany>
#include <multicolors>

#include "files/globals.sp"
#include "files/misc.sp"
#include "files/clients.sp"
#include "files/menus.sp"
#include "files/PrecacheFiles.sp"
#include "files/teams.sp"
#include "files/OnPlayerRunCmd.sp"

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
    name = "[CS:GO] Deathrun",
    author = "ESK0, Javierko",
    description = "CS:GO Deathrun plugin",
    version = "1.3",
};

public void OnPluginStart()
{
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("round_prestart", Event_OnRoundStartPre);
	HookEvent("player_blind", Event_PlayerBlind);
	HookEvent("round_start", Event_OnRoundStart);
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Pre);	
	
	HookEntityOutput("func_button", "OnPressed", OnButtonPressed);
	
	AddNormalSoundHook(OnNormalSoundPlayed);
	AddCommandListener(Event_OnPlayerTeamJoin, "jointeam");
	
	//For better bhoping
	SetCvar("sv_enablebunnyhopping", "1");
	SetCvar("sv_staminamax", "200");
	SetCvar("sv_airaccelerate", "400");
	SetCvar("sv_staminajumpcost", ".1");
	SetCvar("sv_staminalandcost", "0");
	
	RegConsoleCmd("sm_freerun", EventCMD_Freerun);
	//RegAdminCmd("sm_frtest", Event_test, ADMFLAG_ROOT);	
	RegConsoleCmd("sm_fr", EventCMD_Freerun);
	RegConsoleCmd("sm_help", EventCMD_Help);
	RegConsoleCmd("sm_rules", EventCMD_Pravidla);
	RegConsoleCmd("sm_joker", EventCMD_Joker);
	RegConsoleCmd("sm_batman", EventCMD_Batman);
}

public void OnMapStart()
{
	LoopClients(clients)
	{
		b_CTBhop[clients] = false;
		b_CTDoubleJump[clients] = false;
		b_ClientRespawn[clients] = false;
		i_ClientLifes[clients] = 1;
	}
	
	SetCvar("mp_teamname_1", "Batmans");
	SetCvar("mp_teamname_2", "Joker");
	AddFilesToDownloadList();
	PrecacheModels();
}

public void OnButtonPressed(const char[] output, int caller, int activator, float delay)
{
	if(IsClientJoker(caller) || IsClientJoker(activator))
	{
		if(!fr_enable) fr_enable = true;
	}
}

public void OnGameFrame()
{
	float timeleft = RoundStartTime - GetGameTime() + fr_enabletime + GetConVarFloat(FindConVar("mp_freezetime"));
	if(timeleft < 0.01)
	{
		fr_enable = true;
	}
}

public Action EventCMD_Joker(int client, int args)
{
	if(IsClientJoker(client)) ShowJokerMenu(client);
}

public Action EventCMD_Batman(int client, int args)
{
	if(GetClientTeam(client) == CS_TEAM_CT && IsValidClient(client, true)) ShowBatmanMenu(client);
}

public Action EventCMD_Help(int client, int args)
{
	ShowHelpMenu(client);
}

public Action EventCMD_Pravidla(int client, int args)
{
	ShowPravidlaMenu(client);
}

public Action EventCMD_Freerun(int client, int args)
{
	Event_Freerun(client);
	
	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	SendConVarValue(client, FindConVar("sv_footsteps"), "0");
	
	SDKHook(client, SDKHook_PreThink, EventSDK_OnClientThink);
	SDKHook(client, SDKHook_SetTransmit, EventSDK_SetTransmit);
	
	b_HidePlayers[client] = false;
}

public void OnClientDisconnect(int client)
{
	if(client == i_DrTerrorist)
	{
		CS_TerminateRound(1.5, CSRoundEnd_CTWin);
	}
}

public void EventSDK_OnClientThink(int client)
{
	if(IsValidClient(client, true))
	{
		if(GetClientTeam(client) == CS_TEAM_T && IsClientJoker(client))
		{
			if(joker_speedup) SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 2.5);
			else SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
	}
}

public Action EventSDK_SetTransmit(int entity, int client)
{
	if (client != entity && GetClientTeam(client) == CS_TEAM_CT && GetClientTeam(entity) == CS_TEAM_CT && (0 < entity <= MaxClients) && b_HidePlayers[client]) return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action Event_OnPlayerDeath(Handle event, const char[] strName, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidClient(client) && GetClientTeam(client) == CS_TEAM_CT)
	{
		if(i_ClientLifes[client] != 0 && CountPlayersInTeam(CS_TEAM_CT) > 1)
		{
			b_CTBhop[client] = false;
			b_CTDoubleJump[client] = false;
			b_ClientRespawn[client] = true;
			f_ClientRespawnTime[client] = GetGameTime();
		}
	}
}

public Action Event_OnPlayerSpawn(Handle event, const char[] strName, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidClient(client))
	{
		if(IsValidClient(client, true))
		{
			if(GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityRenderMode(client, RENDER_TRANSCOLOR);
				SetEntityModel(client, JokerModel);
				CreateTimer(1.0, Timer_ShowMenu, client);
				joker_bhop = true;
			}
			else if(GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityRenderMode(client, RENDER_TRANSCOLOR);
				CreateTimer(0.5, Timer_FixArms, client);
				SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/player/kuristaja/ak/batman/batman_arms.mdl");
				SetEntityModel(client, CTModel);
				CreateTimer(1.0, Timer_ShowMenu, client);
				b_ClientRespawn[client] = false;
				GivePlayerItem(client, "weapon_flashbang");
			}
			StripWeapons(client);
		}
		CreateTimer(0.0, Timer_RemoveRadar, client);
	}
}

public void Event_PlayerBlind(Handle event, const char[] name, bool dontBroadcast)  // from GoD-Tony's "Radar Config" https://forums.alliedmods.net/showthread.php?p=1471473
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidClient(client, true))
	{
		float fDuration = GetEntPropFloat(client, Prop_Send, "m_flFlashDuration");
		CreateTimer(fDuration, Timer_RemoveRadar, client);
	}
}

public Action Event_OnRoundStart(Handle event, const char[] name, bool dontbroadcast)
{
	RoundStartTime = GetGameTime();
	joker_speedup = false;
	joker_bhop = true;
	if(GetRandomInt(1,6) == GetRandomInt(1,6))
	{
		fr_enable = false;
	}
	ShowOverlayToAll("");
	LoopClients(client)
	{
		b_CTBhop[client] = false;
		b_CTDoubleJump[client] = false;
		if(IsValidClient(client, true))
		{
			StripWeapons(client);
			if(IsPlayerVIP(client)) i_ClientLifes[client] = 3;
			else i_ClientLifes[client] = 1;
		}
	}
}

public Action Event_OnRoundEnd(Handle event, const char[] name, bool dontbroadcast)
{
	int winner_team = GetEventInt(event, "winner");
	if (winner_team == CS_TEAM_CT)
	{
		//ShowOverlayToAll(overlaypath);
	}
	else if (winner_team == CS_TEAM_T)
	{
		ShowOverlayToAll(JokerVyhral);
	}
	if(CountPlayersInTeam(CS_TEAM_T) > 0)
	{
		LoopClients(client)
		{
			b_ClientRespawn[client] = false;
			if(IsValidClient(client) && GetClientTeam(client) == CS_TEAM_T) CS_SwitchTeam(client, CS_TEAM_CT);
		}
	}
}

public Action Event_OnRoundStartPre(Handle event, const char[] name, bool dontbroadcast)
{
	if(CountPlayersInTeam(CS_TEAM_T) == 0)
	{
		i_DrTerrorist = GetRandomPlayer(CS_TEAM_CT);
		if(IsValidClient(i_DrTerrorist))
		{
			CS_SwitchTeam(i_DrTerrorist, CS_TEAM_T);
			CPrintToChatAll("%s New Joker is -> {Darkred}%N", s_Tag, i_DrTerrorist);
		}
	}
}

public Action OnNormalSoundPlayed(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (entity && entity <= MaxClients && StrContains(sample, "footsteps") != -1)
	{
		if(GetClientTeam(entity) == CS_TEAM_T)
		{
			return Plugin_Handled;
		}
		else
		{
			if(StrContains(sample, "footsteps/new/") != -1)
			{
				return Plugin_Stop;
			}
			EmitSoundToAll(sample, entity, SNDCHAN_AUTO,SNDLEVEL_NORMAL,SND_NOFLAGS,0.5);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

/*public Action Event_test(int client, int args)
{
	int index = -1;
	char button[32];
	while ((index = FindEntityByClassname(index, "func_button")) != -1)
	{
		GetEntPropString(index, Prop_Data, "m_iName", button, sizeof(button));
		if(!StrEqual(button, "gs_button"))
		{
			AcceptEntityInput(index, "Kill");
		}
	}
	CPrintToChatAll("%s Toto kolo je FREERUN",s_Tag);
}*/

public void Event_Freerun(int client)
{
	if(IsClientJoker(client))
	{
		if(!fr_enable)
		{
			fr_enable = true;
			int index = -1;
			char button[32];
			while ((index = FindEntityByClassname(index, "func_button")) != -1)
			{
				GetEntPropString(index, Prop_Data, "m_iName", button, sizeof(button));
				if(!StrEqual(button, "gs_button"))
				{
					AcceptEntityInput(index, "Kill");
				}
			}
			CPrintToChatAll("%s This round is Freerun!",s_Tag);
		}
		else CPrintToChat(i_DrTerrorist,"%s Freerun can not be activated or its running.",s_Tag);
	}
}

public Action Timer_FixArms(Handle timer, any client)
{
	if(IsValidClient(client, true)) SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/player/kuristaja/ak/batman/batman_arms.mdl");
}

public Action Timer_ShowMenu(Handle timer, any client)
{
	if(IsValidClient(client, true))
	{
		if(GetClientTeam(client) == CS_TEAM_CT) ShowBatmanMenu(client);
		else if(GetClientTeam(client) == CS_TEAM_T) ShowJokerMenu(client);
	}
}

public Action Timer_RemoveRadar(Handle timer, any client)
{
	if(IsValidClient(client))
	{
		SetEntProp(client, Prop_Send, "m_iHideHUD", ENT_RADAR);
	}
}