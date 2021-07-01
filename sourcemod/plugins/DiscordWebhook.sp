#pragma semicolon 1
#include <sourcemod>
#include <SteamWorks>
#include <cstrike>

public Plugin myinfo = {
    name = "Webhook Chat",
    author = "picocode",
    description = "Send CS:GO chat to discord.",
    version = "1.0",
    url = "https://www.pico.codes"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
    RegPluginLibrary("discord");
    return APLRes_Success;
}

public void OnPluginStart() {
    RegConsoleCmd("say", Main);
    RegConsoleCmd("say_team", Main);
}

public Action Main(int client, int args) {
    char TEAM[64];
    char playerName[64];
    char sMessage[512];
    char sBuffer[64];

    switch (GetClientTeam(client)) {
        case CS_TEAM_NONE: {
            TEAM = "NONE";
        }
        case CS_TEAM_SPECTATOR: {
            TEAM = "SPECTATOR";
        }
        case CS_TEAM_T: {
            TEAM = "T";
        }
        case CS_TEAM_CT: {
            TEAM = "CT";
        }
    }

    GetCmdArg(2, sMessage, sizeof(sMessage));
    for (new i = 1; i <= args; i++) {
        GetCmdArg(i, sBuffer, sizeof(sBuffer));
        Format(sMessage, sizeof(sMessage), "%s %s", sMessage, sBuffer);
    }

    ReplaceString(sMessage, sizeof(sMessage), "`", "");
    ReplaceString(sMessage, sizeof(sMessage), "_", "");
    ReplaceString(sMessage, sizeof(sMessage), ">", "");
    ReplaceString(sMessage, sizeof(sMessage), "*", "");
    ReplaceString(sMessage, sizeof(sMessage), "@", "");
    ReplaceString(sMessage, sizeof(sMessage), "~", "");
    ReplaceString(sMessage, sizeof(sMessage), "'", "");

    ReplaceString(playerName, sizeof(playerName), "`", "");
    ReplaceString(playerName, sizeof(playerName), "_", "");
    ReplaceString(playerName, sizeof(playerName), ">", "");
    ReplaceString(playerName, sizeof(playerName), "*", "");
    ReplaceString(playerName, sizeof(playerName), "@", "");
    ReplaceString(playerName, sizeof(playerName), "~", "");
    ReplaceString(playerName, sizeof(playerName), "'", "");

    GetClientName(client, playerName, 64);

	char buffer[512];
	Format(buffer, sizeof(buffer), "> %s - %s: %s", TEAM, playerName, sMessage);
    DiscordWebook(buffer);
    return Plugin_Continue;
}

public void DiscordWebook(const char[] message) {
    Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, "YOUR_WEBHOOK_HERE");
    SteamWorks_SetHTTPRequestGetOrPostParameter(request, "content", message);
    SteamWorks_SetHTTPRequestHeaderValue(request, "Content-Type", "application/x-www-form-urlencoded");

    if (request == null || !SteamWorks_SetHTTPCallbacks(request, Callback) || !SteamWorks_SendHTTPRequest(request)) {
        PrintToServer("[DISCORDWEBHOOK] Failed");
        delete request;
    }
}

public Callback(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode) {
    if (!bFailure && bRequestSuccessful) {
        if (eStatusCode != k_EHTTPStatusCode200OK && eStatusCode != k_EHTTPStatusCode204NoContent) {
            LogError("[CALLBACK] FAILED: [%i]", eStatusCode);
            SteamWorks_GetHTTPResponseBodyCallback(hRequest, Callback_Response);
        }
    }
    delete hRequest;
}

public Callback_Response(const char[] sData) {
    PrintToServer("[CALLBACK RESPONSE] %s", sData);
}