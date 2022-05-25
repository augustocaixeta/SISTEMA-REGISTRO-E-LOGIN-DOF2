#include a_samp
#include dof2
 
// -----------------------------------------------------------------------------
 
#define MAX_PASSWORD                16          // Máximo de caracteres da senha
#define MIN_PASSWORD                4           // Mínimo de caracteres da senha
#define MAX_ATTEMPS_PASSWORD        3           // Tentativas de acertar a senha
 
#define NOVATO_SKIN_MASCULINA       60
#define NOVATO_SKIN_FEMININA        56
#define NOVATO_DINHEIRO_INICIAL     1000
 
#define NOVATO_SPAWN_X              1958.3783
#define NOVATO_SPAWN_Y              1343.1572
#define NOVATO_SPAWN_Z              15.3746
#define NOVATO_SPAWN_A              270.0000
 
// -----------------------------------------------------------------------------
 
enum
{
    DIALOG_CADASTRO,
    DIALOG_CONECTAR,
    DIALOG_SEXUALIDADE
};
 
enum E_PLAYER_DATA
{
    Senha[MAX_PASSWORD],
    UltimoLogin[24],
 
    Sexo,
    Fome,
    Sede,
    Admin,
    Tentativas,
 
    bool:Logado,
    bool:Spawnou,
    bool:Cadastrou,
 
    Float:pX,
    Float:pY,
    Float:pZ,
    Float:pA
};
 
new Player[MAX_PLAYERS][E_PLAYER_DATA];
 
main(){}
 
public OnGameModeExit()
{
    DOF2::Exit();
    return 1;
}
 
public OnPlayerRequestClass(playerid, classid)
{
    if(!Player[playerid][Logado])
    {
        ClearLines(playerid, 30);
        TogglePlayerSpectating(playerid, true);
        InterpolateCameraPos(playerid, 2118.152343, 2142.547363, 43.101249, 2290.450195, 2143.153808, 36.116157, 7500);
        InterpolateCameraLookAt(playerid, 2123.133056, 2142.632324, 42.669498, 2295.448242, 2143.184570, 35.975551, 7500);
 
        // ---------------------------------------------------------------------
 
        if(!DOF2::FileExists(formatFile(playerid)))
            ShowPlayerDialog(playerid, DIALOG_CADASTRO, DIALOG_STYLE_PASSWORD, "Cadastro", "{FFFFFF}Insira uma senha para cadastrar-se:", "Cadastrar", "Sair");
        else
            ShowPlayerDialog(playerid, DIALOG_CONECTAR, DIALOG_STYLE_PASSWORD, "Conectando", "{FFFFFF}Insira sua senha para conectar-se:", "Conectar", "Sair");
    }
    return 1;
}
 
public OnPlayerSpawn(playerid)
{
    if(Player[playerid][Spawnou])
    {
        if(Player[playerid][Cadastrou])
        {
            new string[110];
            ClearLines(playerid, 50);
            Player[playerid][Spawnou] = false;
            Player[playerid][Cadastrou] = false;
 
            format(string, sizeof(string), "{98FB98}* {FFFFFF}Bem-vindo(a) {98FB98}%s{FFFFFF}, pela primeira vez ao nosso servidor.", formatName(playerid));
            SendClientMessage(playerid, -1, string);
            SendClientMessage(playerid, -1, "{98FB98}* {FFFFFF}Caso tenha dúvidas e precisar de ajuda use os comandos {98FB98}/ajuda {FFFFFF}e {98FB98}/comandos{FFFFFF}.");
        }
        else
        {
            new string[135];
            ClearLines(playerid, 50);
            Player[playerid][Spawnou] = false;
 
            format(string, sizeof(string), "{98FB98}* {FFFFFF}Olá {98FB98}%s{FFFFFF}, seu último login no servidor foi: {98FB98}%s{FFFFFF}.", formatName(playerid), Player[playerid][UltimoLogin]);
            SendClientMessage(playerid, -1, string);
            SendClientMessage(playerid, -1, "{98FB98}* {FFFFFF}Caso tenha dúvidas e precisar de ajuda use os comandos {98FB98}/ajuda {FFFFFF}e {98FB98}/comandos{FFFFFF}.");
        }
    }
    return 1;
}
 
public OnPlayerConnect(playerid)
{
    ResetPlayerData(playerid);
    return 1;
}
 
public OnPlayerDisconnect(playerid, reason)
{
    SavePlayerData(playerid);
    return 1;
}
 
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_CADASTRO:
        {
            if(!response)
                return Kick(playerid);
 
            if(!(MIN_PASSWORD <= strlen(inputtext) <= MAX_PASSWORD))
            {
                new dialog[100];
                format(dialog, sizeof(dialog), "{FFFFFF}Insira uma senha para cadastrar-se:\n\n{FF0000}* Insira uma senha entre %i a %i caracteres.", MIN_PASSWORD, MAX_PASSWORD);
                ShowPlayerDialog(playerid, DIALOG_CADASTRO, DIALOG_STYLE_PASSWORD, "Cadastro", dialog, "Cadastrar", "Sair");
            }
            else
            {
                format(Player[playerid][Senha], MAX_PASSWORD, inputtext);
                format(Player[playerid][UltimoLogin], 24, formatTime());
 
                // -------------------------------------------------------------
 
                DOF2::CreateFile(formatFile(playerid));
                DOF2::SetString(formatFile(playerid), "Senha", Player[playerid][Senha]);
                DOF2::SetString(formatFile(playerid), "ÚltimoLogin", Player[playerid][UltimoLogin]);
                DOF2::SetString(formatFile(playerid), "IP", formatIP(playerid));
                DOF2::SetInt(formatFile(playerid), "Dinheiro", 0);
                DOF2::SetInt(formatFile(playerid), "Level", 0);
                DOF2::SetInt(formatFile(playerid), "Skin", 0);
                DOF2::SetInt(formatFile(playerid), "Interior", 0);
                DOF2::SetInt(formatFile(playerid), "VirtualWorld", 0);
                DOF2::SetInt(formatFile(playerid), "Estrelas", 0);
                DOF2::SetFloat(formatFile(playerid), "Vida", 100.0);
                DOF2::SetFloat(formatFile(playerid), "Colete", 0.0);
 
                DOF2::SetInt(formatFile(playerid), "Sexo", Player[playerid][Sexo] = 0);
                DOF2::SetInt(formatFile(playerid), "Fome", Player[playerid][Fome] = 30);
                DOF2::SetInt(formatFile(playerid), "Sede", Player[playerid][Sede] = 30);
                DOF2::SetInt(formatFile(playerid), "Admin", Player[playerid][Admin] = 0);
 
                DOF2::SetFloat(formatFile(playerid), "X", Player[playerid][pX] = NOVATO_SPAWN_X);
                DOF2::SetFloat(formatFile(playerid), "Y", Player[playerid][pY] = NOVATO_SPAWN_Y);
                DOF2::SetFloat(formatFile(playerid), "Z", Player[playerid][pZ] = NOVATO_SPAWN_Z);
                DOF2::SetFloat(formatFile(playerid), "A", Player[playerid][pA] = NOVATO_SPAWN_A);
                DOF2::SaveFile();
 
                // -------------------------------------------------------------
 
                SendClientMessage(playerid, -1, "{98FB98}* {FFFFFF}Cadastro efetuado com sucesso.");
                ShowPlayerDialog(playerid, DIALOG_SEXUALIDADE, DIALOG_STYLE_MSGBOX, "Sexualidade", "{FFFFFF}Informe seu sexo abaixo:", "Masculino", "Feminino");
            }
        }
        case DIALOG_SEXUALIDADE:
        {
            Player[playerid][Logado] = true;
            Player[playerid][Spawnou] = true;
            Player[playerid][Cadastrou] = true;
            Player[playerid][Sexo] = (response ? 1 : 2);
 
            TogglePlayerSpectating(playerid, false);
            GivePlayerMoney(playerid, NOVATO_DINHEIRO_INICIAL);
            SendClientMessage(playerid, -1, (response ? "{98FB98}* {FFFFFF}Sexo definido como Masculino." : "{98FB98}* {FFFFFF}Sexo definido como Feminino."));
 
            SetSpawnInfo(playerid, NO_TEAM, (response ? NOVATO_SKIN_MASCULINA : NOVATO_SKIN_FEMININA), Player[playerid][pX], Player[playerid][pY], Player[playerid][pZ], Player[playerid][pA], 0, 0, 0, 0, 0, 0);
            SetCameraBehindPlayer(playerid);
            SpawnPlayer(playerid);
        }
        case DIALOG_CONECTAR:
        {
            if(!response)
                return Kick(playerid);
 
            if(!strlen(inputtext))
                return ShowPlayerDialog(playerid, DIALOG_CONECTAR, DIALOG_STYLE_PASSWORD, "Conectando", "{FFFFFF}Insira sua senha para conectar-se:", "Conectar", "Sair");
 
            format(Player[playerid][Senha], MAX_PASSWORD, DOF2::GetString(formatFile(playerid), "Senha"));
            format(Player[playerid][UltimoLogin], 24, DOF2::GetString(formatFile(playerid), "ÚltimoLogin"));
 
            if(!strcmp(Player[playerid][Senha], inputtext))
            {
                GivePlayerMoney(playerid, DOF2::GetInt(formatFile(playerid), "Dinheiro"));
                SetPlayerScore(playerid, DOF2::GetInt(formatFile(playerid), "Level"));
                SetPlayerSkin(playerid, DOF2::GetInt(formatFile(playerid), "Skin"));
                SetPlayerInterior(playerid, DOF2::GetInt(formatFile(playerid), "Interior"));
                SetPlayerVirtualWorld(playerid, DOF2::GetInt(formatFile(playerid), "VirtualWorld"));
                SetPlayerWantedLevel(playerid, DOF2::GetInt(formatFile(playerid), "Estrelas"));
                SetPlayerHealth(playerid, DOF2::GetFloat(formatFile(playerid), "Vida"));
                SetPlayerArmour(playerid, DOF2::GetFloat(formatFile(playerid), "Colete"));
 
                Player[playerid][Sexo] = DOF2::GetInt(formatFile(playerid), "Sexo");
                Player[playerid][Fome] = DOF2::GetInt(formatFile(playerid), "Fome");
                Player[playerid][Sede] = DOF2::GetInt(formatFile(playerid), "Sede");
                Player[playerid][Admin] = DOF2::GetInt(formatFile(playerid), "Admin");
 
                Player[playerid][pX] = DOF2::GetFloat(formatFile(playerid), "X");
                Player[playerid][pY] = DOF2::GetFloat(formatFile(playerid), "Y");
                Player[playerid][pZ] = DOF2::GetFloat(formatFile(playerid), "Z");
                Player[playerid][pA] = DOF2::GetFloat(formatFile(playerid), "A");
 
                Player[playerid][Logado] = true;
                Player[playerid][Spawnou] = true;
                SendClientMessage(playerid, -1, "{98FB98}* {FFFFFF}Entrada efetuada com sucesso.");
 
                SetSpawnInfo(playerid, NO_TEAM, GetPlayerSkin(playerid), Player[playerid][pX], Player[playerid][pY], Player[playerid][pZ], Player[playerid][pA], 0, 0, 0, 0, 0, 0);
                TogglePlayerSpectating(playerid, false);
                SetCameraBehindPlayer(playerid);
                SpawnPlayer(playerid);
            }
            else
            {
                Player[playerid][Tentativas]++;
                if(Player[playerid][Tentativas] >= MAX_ATTEMPS_PASSWORD) return Kick(playerid);
 
                new dialog[90];
                format(dialog, sizeof(dialog), "{FFFFFF}Insira sua senha para conectar-se:\n\n{FF0000}* Senha incorreta (%i/%i).", Player[playerid][Tentativas], MAX_ATTEMPS_PASSWORD);
                ShowPlayerDialog(playerid, DIALOG_CONECTAR, DIALOG_STYLE_PASSWORD, "Conectando", dialog, "Conectar", "Sair");
            }
        }
    }
    return 1;
}
 
// -----------------------------------------------------------------------------
 
formatFile(playerid)
{
    new file[16 + MAX_PLAYER_NAME];
    format(file, sizeof(file), "Contas/%s.ini", formatName(playerid));
    return file;
}
 
formatName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, MAX_PLAYER_NAME);
    return name;
}
 
formatIP(playerid)
{
    new ip[16];
    GetPlayerIp(playerid, ip, 16);
    return ip;
}
 
Float:formatHealth(playerid)
{
    new Float:health;
    GetPlayerHealth(playerid, health);
    return health;
}
 
Float:formatArmour(playerid)
{
    new Float:armour;
    GetPlayerArmour(playerid, armour);
    return armour;
}
 
formatTime()
{
    new output[24], date[3], hour[3];
    getdate(date[2], date[1], date[0]);
    gettime(hour[0], hour[1], hour[2]);
    format(output, sizeof(output), "%02d/%02d/%04d - %02d:%02d:%02d", date[0], date[1], date[2], hour[0], hour[1], hour[2]);
    return output;
}
 
ClearLines(playerid, lines)
    for(new i; i != lines; i++)
        SendClientMessage(playerid, -1, #);
 
// -----------------------------------------------------------------------------
 
SavePlayerData(playerid)
{
    if(Player[playerid][Logado])
    {
        if(DOF2::FileExists(formatFile(playerid)))
        {
            format(Player[playerid][UltimoLogin], 24, formatTime());
            GetPlayerPos(playerid, Player[playerid][pX], Player[playerid][pY], Player[playerid][pZ]);
            GetPlayerFacingAngle(playerid, Player[playerid][pA]);
 
            DOF2::SetString(formatFile(playerid), "ÚltimoLogin", Player[playerid][UltimoLogin]);
            DOF2::SetString(formatFile(playerid), "IP", formatIP(playerid));
            DOF2::SetInt(formatFile(playerid), "Dinheiro", GetPlayerMoney(playerid));
            DOF2::SetInt(formatFile(playerid), "Level", GetPlayerScore(playerid));
            DOF2::SetInt(formatFile(playerid), "Skin", GetPlayerSkin(playerid));
            DOF2::SetInt(formatFile(playerid), "Interior", GetPlayerInterior(playerid));
            DOF2::SetInt(formatFile(playerid), "VirtualWorld", GetPlayerVirtualWorld(playerid));
            DOF2::SetInt(formatFile(playerid), "Estrelas", GetPlayerWantedLevel(playerid));
            DOF2::SetFloat(formatFile(playerid), "Vida", formatHealth(playerid));
            DOF2::SetFloat(formatFile(playerid), "Colete", formatArmour(playerid));
 
            DOF2::SetInt(formatFile(playerid), "Sexo", Player[playerid][Sexo]);
            DOF2::SetInt(formatFile(playerid), "Fome", Player[playerid][Fome]);
            DOF2::SetInt(formatFile(playerid), "Sede", Player[playerid][Sede]);
            DOF2::SetInt(formatFile(playerid), "Admin", Player[playerid][Admin]);
 
            DOF2::SetFloat(formatFile(playerid), "X", Player[playerid][pX]);
            DOF2::SetFloat(formatFile(playerid), "Y", Player[playerid][pY]);
            DOF2::SetFloat(formatFile(playerid), "Z", Player[playerid][pZ]);
            DOF2::SetFloat(formatFile(playerid), "A", Player[playerid][pA]);
            DOF2::SaveFile();
        }
    }
}
 
ResetPlayerData(playerid)
{
    ResetPlayerMoney(playerid);
    SetPlayerScore(playerid, 0);
    SetPlayerSkin(playerid, 0);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerWantedLevel(playerid, 0);
    SetPlayerHealth(playerid, 100.0);
    SetPlayerArmour(playerid, 0.0);
 
    Player[playerid][Sexo] = Player[playerid][Admin] = Player[playerid][Fome] = Player[playerid][Sede] = Player[playerid][Tentativas] = 0;
    Player[playerid][pX] = Player[playerid][pY] = Player[playerid][pZ] = Player[playerid][pA] = 0.0;
    Player[playerid][Logado] = Player[playerid][Spawnou] = Player[playerid][Cadastrou] = false;
}
 
/*
 
ADICIONAL:
 
GetPlayerGenderName(playerid)
{
    new name[10];
    name = ((Player[playerid][Sexo] == 1) ? "Masculino" : "Feminino");
    return name;
}
 
USANDO:
 
printf("%s", GetPlayerGenderName(playerid));
 
*/
