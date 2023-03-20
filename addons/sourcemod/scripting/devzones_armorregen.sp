#include <sourcemod>
#include <devzones>

#pragma semicolon 1
#pragma newdecls required

ConVar RegenArmor, RegenTime, RegenMaxArmor;

public Plugin myinfo = 
{
	name = "SM DEV ZONES - Armor Regen", 
	author = "ByDexter", 
	description = "", 
	version = "1.1", 
	url = "https://steamcommunity.com/id/ByDexterTR/"
};

public void OnPluginStart()
{
	RegenArmor = CreateConVar("sm_armorregen_armor", "5", "Bölgede bulunan oyunculara kaç ZIRH verilsin?\nHow many ARMOR should be given to players in the zone?");
	RegenTime = CreateConVar("sm_armorregen_time", "1.0", "Bölgede bulunan oyunculara kaç saniyede ZIRH verilsin?\nHow many seconds should ARMOR be given to players in the zone?");
	RegenMaxArmor = CreateConVar("sm_armorregen_maxarmor", "100", "Bölgedeki insanların maksimum ZIRH ne olacak?\nWhat ARMOR will the people in the zone have the maximum?");
	AutoExecConfig(true, "DevZones-HpRegen", "ByDexter");
}

public void Zone_OnClientEntry(int client, const char[] zone)
{
	if (IsValidClient(client) && StrContains(zone, "armorregen", false) != -1 && GetClientHealth(client) < RegenMaxArmor.IntValue)
	{
		CreateTimer(RegenTime.FloatValue, Timer_RegenARMOR, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_RegenARMOR(Handle timer, any client)
{
	if (!IsValidClient(client))
	{
		return Plugin_Stop;
	}
	if (GetClientArmor(client) > RegenMaxArmor.IntValue)
	{
		SetClientArmor(client, RegenMaxArmor.IntValue);
		return Plugin_Stop;
	}
	SetClientArmor(client, GetClientArmor(client) + RegenArmor.IntValue);
	return Plugin_Continue;
}

void SetClientArmor(int client, int amount)
{
	if (IsValidClient(client))
	{
		if (amount < 0)
			SetEntProp(client, Prop_Data, "m_ArmorValue", -amount, 4);
		else
			SetEntProp(client, Prop_Data, "m_ArmorValue", amount, 4);
	}
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
} 