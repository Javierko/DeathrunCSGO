#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <colors>
#include <smlib>

#pragma semicolon 1
#pragma newdecls required

#define PL_VER "2.0.0"
#define PL_AUTOR "Javierko"
#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

#include "deathrun/var.sp"
#include "deathrun/func.sp"
#include "deathrun/menu.sp"
#include "deathrun/events.sp"
#include "deathrun/runcmd.sp" 

/*
    > Plugin info <
*/

public Plugin myinfo =
{
    name        = "[CS:GO] Deathrun",
    author      = PL_AUTOR,
    description = "Public Deahtrun gamemode",
    version     = PL_VER,
    url         = "https://github.com/Javierko"
}; 

/*
    > Plugin Start <
*/

public void OnPluginStart()
{
    //Commands
    RegConsoleCmd("sm_freerun", Command_Freerun);
    RegConsoleCmd("sm_fr", Command_Freerun);
    RegConsoleCmd("sm_joker", Command_Joker);
    RegConsoleCmd("sm_batman", Command_Batman);

    //Events
    HookEvent("player_team", Event_PlayerTeam_Pre, EventHookMode_Pre);
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("player_blind", Event_PlayerBlind);
    HookEvent("round_prestart", Event_RoundStart_Pre);
    HookEvent("round_start", Event_RoundStart);
    HookEvent("round_end", Event_RoundEnd);
    HookEvent("player_death", Event_PlayerDeath);

    //Convars
    g_cvTag = CreateConVar("sm_deahtrun_tag", "{darkred}[SM]{default}", "Set tag for messages.");
    g_cvTag.AddChangeHook(OnConVarChanged);
    g_cvTag.GetString(g_szTag, sizeof(g_szTag));

    AutoExecConfig(true, "deathrun");

    //Translations
    LoadTranslations("deathrun.phrases");

    //Sound Hooks
    AddNormalSoundHook(Sound_OnNormalSoundPlayed);
    HookEntityOutput("func_button", "OnPressed", HEO_OnButtonPressed);

    //Download config
    BuildPath(Path_SM, g_szDownloadPath, sizeof(g_szDownloadPath), "configs/Deathrun_Download.txt");
}

//Convar change
public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if(convar == g_cvTag)
    {
        strcopy(g_szTag, sizeof(g_szTag), newValue);
    }
}

//Map start
public void OnMapStart()
{
    g_iJoker = -1;
    g_bFreerun = false;
    g_bJokerAbility[Speed] = false;
    g_bJokerAbility[Bhop] = false;
    
    LoopClients(i)
    {
        if(IsValidClient(i))
        {
            g_bBatmanAbility[i][Bhop] = false;
            g_bBatmanAbility[i][Doublejump] = false;
        }
    }

    Func_SetCvar("mp_teamname_1", "Batmans");
    Func_SetCvar("mp_teamname_2", "Joker");

    Func_DownloadAndPrecacheFiles();
}

/*
    > P. Join || P. Leave <
*/

public void OnClientPutInServer(int client)
{
    if(IsValidClient(client))
    {
        SendConVarValue(client, FindConVar("sv_footsteps"), "0");

        SDKHook(client, SDKHook_PreThink, SDK_PreThink);
        SDKHook(client, SDKHook_SetTransmit, SDK_SetTransmit);
    }
}

public void OnClientDisconnect(int client)
{
    if(IsValidClient(client))
        if(IsClientJoker(client))
            CS_TerminateRound(1.5, CSRoundEnd_CTWin);
}

/*
    > Commands <
*/

public Action Command_Freerun(int client, int args)
{
    if(IsValidClient(client))
    {
        if(IsClientJoker(client))
        {
            if(!g_bFreerun)
            {
                g_bFreerun = true;

                int iIndex = -1;
                char szButton[32];

                while((iIndex = FindEntityByClassname(iIndex, "func_button")) != -1)
                {
                    GetEntPropString(iIndex, Prop_Data, "m_iName", szButton, sizeof(szButton));
                    AcceptEntityInput(iIndex, "Kill");
                }

                CReplyToCommand(client, "%s %t", g_szTag, "FreerunTurnedOn");
            }
            else
                CReplyToCommand(client, "%s %t", g_szTag, "FreerunIsOn");
        }
        else
            CReplyToCommand(client, "%s %t", g_szTag, "YoureNotJoker");
    }

    return Plugin_Handled;
}

public Action Command_Joker(int client, int args)
{
    if(IsValidClient(client))
        if(IsClientJoker(client))
            Menu_Joker(client);
        else
            CReplyToCommand(client, "%s %t", g_szTag, "YoureNotJoker");

    return Plugin_Handled;
}

public Action Command_Batman(int client, int args)
{
    if(IsValidClient(client))
        if(IsClientBatman(client))
            Menu_Batman(client);
        else
            CReplyToCommand(client, "%s %t", g_szTag, "YoureNotBatman");

    return Plugin_Handled;
} 

/*
    > Timers <
*/

public Action Timer_RemoveRadar(Handle timer, any client)
{
    if(IsValidClient(client))
        SetEntProp(client, Prop_Send, "m_iHideHUD", ENT_RADAR);

    return Plugin_Stop;
}   

/*
    > Jointeam listener <
*/

public Action Event_OnPlayerTeamJoin(int client, const char[] command, int args)
{
    char szTeamString[3]; 
    GetCmdArg(1, szTeamString, sizeof(szTeamString)); 

    int iTargetTeam = StringToInt(szTeamString);
    int iCurrTeam = GetClientTeam(client);

    if(IsValidClient(client))
    {
        if(iCurrTeam == iTargetTeam)
            return Plugin_Handled;

        if(iTargetTeam == CS_TEAM_T)
            return Plugin_Handled;
        else if(iTargetTeam != CS_TEAM_T)
            return Plugin_Continue;
    }

    return Plugin_Handled;
}

public Action Event_PlayerTeam_Pre(Handle event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    int iTeam = GetEventInt(event, "team");

    if(!dontBroadcast)
    {
        Handle hNewEvent = CreateEvent("player_team", true);	

        SetEventInt(hNewEvent, "userid", GetEventInt(event, "userid"));
        SetEventInt(hNewEvent, "team", GetEventInt(event, "team"));
        SetEventInt(hNewEvent, "oldteam", GetEventInt(event, "oldteam"));
        SetEventBool(hNewEvent, "disconnect", GetEventBool(event, "disconnect"));	

        FireEvent(hNewEvent, true);		

        return Plugin_Handled;
	} 

    if(IsValidClient(client))
    {
        if(iTeam == CS_TEAM_T) 
        {
            CS_SwitchTeam(client, CS_TEAM_CT);
        }
    }	  
    
    return Plugin_Continue;
}

public void OnGameFrame()
{
    if(Func_CountTeamPlayers(CS_TEAM_T) > 1)
    {
        LoopClients(i)
        {
            if(IsValidClient(i))
            {
                if(GetClientTeam(i) == CS_TEAM_T && !IsClientJoker(i))
                {
                    CS_SwitchTeam(i, CS_TEAM_CT);
                }
            }
        }
    }
}

/*
    > Hooks <
*/

//Button
public void HEO_OnButtonPressed(const char[] output, int caller, int activator, float delay)
{
    if(IsValidClient(caller) || IsValidClient(activator))
    {
        if(IsClientJoker(caller) || IsClientJoker(activator))
        {
            if(!g_bFreerun)
                g_bFreerun = true;
        }
    }
}

//Think
public void SDK_PreThink(int client)
{
    if(IsValidClient(client))
    {
        if(IsClientJoker(client))
        {
            if(g_bJokerAbility[Speed])
                SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 2.5);
            else
                SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
        }
    }
}

//Transmit
public Action SDK_SetTransmit(int entity, int client)
{
    if(client != entity)
        if(GetClientTeam(client) == CS_TEAM_CT && GetClientTeam(entity) == CS_TEAM_CT)
            if(IsValidClient(entity))
                if(g_bHideMates[client])  
                    return Plugin_Handled;
                    
    return Plugin_Continue;
}

//Sound hook
public Action Sound_OnNormalSoundPlayed(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
    if (entity && entity <= MaxClients && StrContains(sample, "footsteps") != -1)
    {
        if(GetClientTeam(entity) == CS_TEAM_T)
            return Plugin_Handled;
        else
        {
            if(StrContains(sample, "footsteps/new/") != -1)
                return Plugin_Stop;
                
            EmitSoundToAll(sample, entity, SNDCHAN_AUTO,SNDLEVEL_NORMAL,SND_NOFLAGS,0.5);
            
            return Plugin_Handled;
        }
    }
    
    return Plugin_Continue;
}