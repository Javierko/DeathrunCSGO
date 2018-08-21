stock bool IsPlayerVIP(int client)
{
	if(CheckCommandAccess(client, "", ADMFLAG_RESERVATION))
	{
		return true;
	}
	return false;
} 

stock bool IsPlayerAdmin(int client)
{
	if(CheckCommandAccess(client, "", ADMFLAG_GENERIC))
	{
		return true;
	}
	return false;
} 

stock bool IsValidClient(int client, bool alive = false)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
	{
		return true;
	}
	return false;
}

stock int CountPlayersInTeam(int team)
{
	int count = 0;
	LoopClients(i)
	{
		if(IsValidClient(i) && GetClientTeam(i) == team)
		{
			count++;
		}
	}
	return count;
}

stock bool IsClientJoker(int client)
{
	if(client == i_DrTerrorist)
	{
		return true;
	}
	return false;
}

stock int GetRandomPlayer(int team, bool alive = false)
{
	new clients[MaxClients+1];
	int clientCount;
	LoopClients(i)
	{
		if(IsValidClient(i, alive) && GetClientTeam(i) == team)
		{
			clients[clientCount++] = i;
		}
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}
