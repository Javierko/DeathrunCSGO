#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <colors>
#include <smlib>

#pragma semicolon 1
#pragma newdecls required

#define PL_VER "2.1.0"
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
    g_cvModels = CreateConVar("sm_deathrun_models", "1", "1 - Enable inplugin models, 0 - disable inplugin models", _, true, 0.0, true, 1.0);
    g_cvRespawn = CreateConVar("sm_deathrun_respawn", "1", "1 - Enable respawns, 0 - disable respawns", _, true, 0.0, true, 1.0);
    g_cvLifesNonVIP = CreateConVar("sm_deathrun_lifes_novip", "1", "Non-VIP lifes >= 1", _, true, 1.0, false);
    g_cvLifesVIP = CreateConVar("sm_deathrun_lifes_vip", "3", "VIP lifes >= 1", _, true, 1.0, false);
    g_cvMenu = CreateConVar("sm_deathrun_menu", "0", "0 - Default /joker, /batman, 1 - using /menu for both, 2 - works /batman; /joker and /menu", _, true, 0.0, true, 1.0);
    g_cvFreerun = CreateConVar("sm_deathrun_freerun", "1", "1 - Enable freerun, 0 - disable freerun", _, true, 0.0, true, 1.0);
    g_cvRandomFreerun = CreateConVar("sm_deathrun_random_freerun", "1", "1 - Enable random freeruns (sm_deathrun_freerun must be 1), 0 - disable random freeruns", _, true, 0.0, true, 1.0);

    AutoExecConfig(true, "deathrun");

    //Commands
    RegConsoleCmd("sm_freerun", Command_Freerun);
    RegConsoleCmd("sm_fr", Command_Freerun);

    //Translations
    LoadTranslations("deathrun.phrases");

    //Hooks
    AddNormalSoundHook(Sound_OnNormalSoundPlayed);
    HookEntityOutput("func_button", "OnPressed", HEO_OnButtonPressed);
    AddCommandListener(Event_OnPlayerTeamJoin, "jointeam");

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
    g_bJokerAbility.Speed = false;
    g_bJokerAbility.Bhop = false;
    
    LoopClients(i)
    {
        if(IsValidClient(i))
        {
            g_bBatmanAbility[i].Bhop = false;
            g_bBatmanAbility[i].DoubleJump = false;
            g_bBatmanAbility[i].Gravity = false;
        }
    }

    Func_SetCvar("mp_teamname_1", "Batmans");
    Func_SetCvar("mp_teamname_2", "Joker");

    if(g_cvModels.BoolValue)
    {
        Func_DownloadAndPrecacheFiles();
    }
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
    {
        if(IsClientJoker(client))
        {
            CS_TerminateRound(1.5, CSRoundEnd_CTWin);
        }
    }
}

/*
    > Commands
*/

public Action OnClientSayCommand(int client, const char[] command, const char[] args)
{
    if(IsValidClient(client))
    {
        static char szBatmanCmds[][] =  {"/batman", "!batman", ".batman"};
        static char szJokerCmds[][] =  {"/joker", "!joker", ".joker"};
        static char szMenuCmds[][] =  {"/menu", "!menu", ".menu"};
        static char szBoth[][] = {"/joker", "!joker", ".joker", "/batman", "!batman", ".batman", "/menu", "!menu", ".menu"};
        
        if(g_cvMenu.IntValue == 0)
        {
            for(int i = 0; i < sizeof(szBatmanCmds); i++)
            {
                if(strcmp(args[0], szBatmanCmds[i], false) == 0)
                {
                    Menu_Batman(client);

                    break;
                }
            }

            for(int i = 0; i < sizeof(szJokerCmds); i++)
            {
                if(strcmp(args[0], szJokerCmds[i], false) == 0)
                {
                    Menu_Joker(client);

                    break;
                }
            }
        }
        else if(g_cvMenu.IntValue == 1)
        {
            for(int i = 0; i < sizeof(szMenuCmds); i++)
            {
                if(strcmp(args[0], szMenuCmds[i], false) == 0)
                {
                    Menu_Both(client);

                    break;
                }
            }
        }
        else if(g_cvMenu.IntValue == 2)
        {
            for(int i = 0; i < sizeof(szBoth); i++)
            {
                if(strcmp(args[0], szBoth[i], false) == 0)
                {
                    Menu_Both(client);

                    break;
                }
            }
        }
    }

    return Plugin_Continue;
}

public Action Command_Freerun(int client, int args)
{
    if(IsValidClient(client))
    {
        if(IsClientJoker(client))
        {
            if(!g_bFreerun)
            {
                if(g_cvFreerun.BoolValue)
                {
                    g_bFreerun = true;

                    CReplyToCommand(client, "%s %t", g_szTag, "FreerunTurnedOn");
                }
            }
            else
            {
                CReplyToCommand(client, "%s %t", g_szTag, "FreerunIsOn");
            }
        }
        else
        {
            CReplyToCommand(client, "%s %t", g_szTag, "YoureNotJoker");
        }
    }

    return Plugin_Handled;
}

/*
    > Timers <
*/

public Action Timer_RemoveRadar(Handle timer, any client)
{
    if(IsValidClient(client))
    {
        SetEntProp(client, Prop_Send, "m_iHideHUD", ENT_RADAR);
    }

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
        {
            return Plugin_Handled;
        }

        if(iTargetTeam == CS_TEAM_T)
        {
            return Plugin_Handled;
        }
        else if(iTargetTeam != CS_TEAM_T)
        {
            return Plugin_Continue;
        }
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
public Action HEO_OnButtonPressed(const char[] output, int caller, int activator, float delay)
{
    if(IsValidEntity(caller) && IsValidClient(activator))
    {
        if(g_bFreerun)
        {
            CPrintToChat(activator, "%s %t", g_szTag, "ItsFreerun");

            return Plugin_Handled;
        }
    }

    return Plugin_Continue;
}

//Think
public void SDK_PreThink(int client)
{
    if(IsValidClient(client))
    {
        if(IsClientJoker(client))
        {
            if(g_bJokerAbility.Speed)
            {
                SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 2.5);
            }
            else
            {
                SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
            }
        }
        else if(IsClientBatman(client))
        {
            if(g_bBatmanAbility[client].Gravity)
            {
                SetEntityGravity(client, 0.6);
            }
            else
            {
                SetEntityGravity(client, 1.0);
            }
        }
    }
}

//Transmit
public Action SDK_SetTransmit(int entity, int client)
{
    if(client != entity)
    {
        if(GetClientTeam(client) == CS_TEAM_CT && GetClientTeam(entity) == CS_TEAM_CT)
        {
            if(IsValidClient(entity))
            {
                if(g_bHideMates[client])
                {
                    return Plugin_Handled;
                }
            }
        }
    }
                    
    return Plugin_Continue;
}

//Sound hook
public Action Sound_OnNormalSoundPlayed(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{  
    if(entity && entity <= MaxClients && StrContains(sample, "footsteps") != -1)
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