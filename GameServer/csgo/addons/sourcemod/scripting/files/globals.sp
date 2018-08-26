#define s_Tag "[{Lightblue}SM{default}]"
#define JokerModel "models/player/mapeadores/morell/joker/joker.mdl"
#define CTModel "models/player/kuristaja/ak/batman/batman.mdl"
#define JokerVyhral "overlays/deathrun/jokervyhral"
#define ENT_RADAR 1 << 12
#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

int i_DrTerrorist = -1;

float fr_enabletime = 6.0;
float RoundStartTime;

bool fr_enable = false;
bool joker_speedup = false;
bool joker_bhop = false;
bool b_HidePlayers[MAXPLAYERS+1] = {false,...};

bool b_CTBhop[MAXPLAYERS+1] = {false,...};
bool b_CTDoubleJump[MAXPLAYERS+1] = {false,...};

int i_LastFlags[MAXPLAYERS+1];
int i_LastButtons[MAXPLAYERS+1];
int i_JumpsCount[MAXPLAYERS+1];

int i_ClientLifes[MAXPLAYERS+1] = {1,...};
bool b_ClientRespawn[MAXPLAYERS+1] = {false,...};
float f_ClientRespawnTime[MAXPLAYERS+1];

ConVar g_cvBetterBhop;
