//Strings
char g_szTag[64];
char g_szDownloadPath[PLATFORM_MAX_PATH];

//Enums
enum g_eJokerAbilitys
{
    Speed,
    Bhop
};

enum g_eBatmanAbilitys
{
    Doublejump,
    Bhop
};

//Booleans
bool g_bFreerun = false;
bool g_bJokerAbility[g_eJokerAbilitys] = false;
bool g_bBatmanAbility[MAXPLAYERS + 1][g_eBatmanAbilitys];
bool g_bHideMates[MAXPLAYERS + 1] = false;
bool g_bClientRespawn[MAXPLAYERS + 1] = false;
bool g_bSaveAbility[MAXPLAYERS + 1] = false;

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

//Custom defines
#define ENT_RADAR 1 << 12