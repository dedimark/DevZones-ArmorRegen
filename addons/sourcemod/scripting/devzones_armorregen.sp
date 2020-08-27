#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <multicolors>
#include <devzones>
#include <warden>

#pragma semicolon 1
#pragma newdecls required

ConVar ConVar_Regen_armor, ConVar_Regen_Timer, ConVar_Regen_Maxarmor, ConVar_Regen_Helmet;

Handle Handle_armorRegenC_T[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "SM DEV ZONES - Armor Regen",
	author = "ByDexter",
	description = "",
	version = "1.0",
	url = "https://steamcommunity.com/id/ByDexterTR/"
};

public void OnPluginStart()
{
	ConVar_Regen_armor = CreateConVar("sm_armorregen", "5", "Bölgede bulunan oyunculara kaç can verilsin");
	ConVar_Regen_Timer = CreateConVar("sm_timeregen", "1.0", "Bölgede bulunan oyunculara kaç saniyede can verilsin");
	ConVar_Regen_Maxarmor = CreateConVar("sm_maxarmor", "100", "Bölgede bulunan oyunculara kaç versin");
	ConVar_Regen_Helmet = CreateConVar("sm_regen_helmet", "1", "Bölgede bulunan oyunculara kask verilsin");
	AutoExecConfig(true, "DevZones-armorRegen", "ByDexter");
}

public void OnClientDisconnect(int client)
{
	if (Handle_armorRegenC_T[client] != INVALID_HANDLE)
	{
		KillTimer(Handle_armorRegenC_T[client]);
		Handle_armorRegenC_T[client] = INVALID_HANDLE;
	}
}

public void Zone_OnClientEntry(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if(StrContains(zone, "armorregen", false) == 0)
	{
		Handle_armorRegenC_T[client] = CreateTimer(ConVar_Regen_Timer.FloatValue, Timer_Regen, client, TIMER_REPEAT);
	}
}

public void Zone_OnClientLeave(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if(StrContains(zone, "armorregen", false) == 0)
	{
		if (Handle_armorRegenC_T[client] != INVALID_HANDLE)
		{
			KillTimer(Handle_armorRegenC_T[client]);
			Handle_armorRegenC_T[client] = INVALID_HANDLE;
		}
		if (GetClientArmor(client) > ConVar_Regen_Maxarmor.IntValue)
		{
			SetEntityHealth(client, ConVar_Regen_Maxarmor.IntValue);
		}
	}
}

public Action Timer_Regen(Handle timer, any client)
{
	if (GetClientArmor(client) > ConVar_Regen_Maxarmor.IntValue)
	{
		SetEntityHealth(client, ConVar_Regen_Maxarmor.IntValue);
		return Plugin_Stop;
	}
	int armor = GetClientArmor(client);
	SetEntProp(client, Prop_Send, "m_ArmorValue", armor + ConVar_Regen_armor.IntValue, 1);
	if(ConVar_Regen_Helmet.IntValue == 1)
	{
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
	}
	return Plugin_Continue;
}