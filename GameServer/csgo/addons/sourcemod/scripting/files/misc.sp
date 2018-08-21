stock void StripWeapons(int client)
{
	int wepIdx;
	for (new x = 0; x <= 6; x++)
	{
		if (x != 2 && (wepIdx = GetPlayerWeaponSlot(client, x)) != -1)
		{
			RemovePlayerItem(client, wepIdx);
			RemoveEdict(wepIdx);
		}
	}
}

void ShowOverlayToClient(int client, const char[] path)
{
	ClientCommand(client, "r_screenoverlay \"%s\"", path);
}

void ShowOverlayToAll(const char[] path)
{
	LoopClients(client)
	{
		if (IsValidClient(client))
		{
			ShowOverlayToClient(client, path);
		}
	}
}

stock int GetClientWaterLevel(int client)
{
	return GetEntProp(client, Prop_Send, "m_nWaterLevel");
}

stock void SetCvar(char[] scvar, char[] svalue)
{
	Handle cvar = FindConVar(scvar);
	SetConVarString(cvar, svalue, true);
}
