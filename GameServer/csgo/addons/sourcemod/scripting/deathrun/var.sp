//Strings
char g_szTag[64];
char g_szDownloadPath[PLATFORM_MAX_PATH];

//Enum
enum struct g_eAbility {
    bool DoubleJump;
    bool Bhop;
    bool Gravity;
    bool Speed;
}

//Booleans
bool g_bFreerun = false;
bool g_bHideMates[MAXPLAYERS + 1] = false;
bool g_bClientRespawn[MAXPLAYERS + 1] = false;
bool g_bSaveAbility[MAXPLAYERS + 1] = false;
bool g_bDisabledJoker = false;
g_eAbility g_bJokerAbility;
g_eAbility g_bBatmanAbility[MAXPLAYERS + 1];

//Integers
int g_iJoker = -1;
int g_iClientLifes[MAXPLAYERS + 1];
int g_iLastFlags[MAXPLAYERS + 1];
int g_iLastButtons[MAXPLAYERS + 1];
int g_iJumpsCount[MAXPLAYERS + 1];

//Floats
float g_fRespawnTime[MAXPLAYERS + 1];

//Convars
ConVar g_cvTag;
ConVar g_cvModels;
ConVar g_cvRespawn;
ConVar g_cvLifesNonVIP;
ConVar g_cvLifesVIP;
ConVar g_cvMenu;
ConVar g_cvFreerun;
ConVar g_cvRandomFreerun;

//Custom defines
#define ENT_RADAR 1 << 12