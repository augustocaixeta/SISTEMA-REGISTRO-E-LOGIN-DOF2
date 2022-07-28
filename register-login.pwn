/*

    * Não testado as novas mudanças;
    * Esta versão usa funções das novas atualizações do OPEN.MP;

*/

#include <a_samp>
#include <a_omp>
#include <dof2>

// -----------------------------------------------------------------------------

#define MAX_PASSWORD                		16  	// Máx. caracteres da senha
#define MIN_PASSWORD                		4   	// Mín. caracteres da senha
#define MAX_ATTEMPS_PASSWORD        		3   	// Tentativas de acertar a senha

#define BEGINNER_SKIN_MALE       		60
#define BEGINNER_SKIN_FEMALE        		56
#define BEGINNER_START_MONEY     		1000

#define BEGINNER_START_X              		1958.3783
#define BEGINNER_START_Y              		1343.1572
#define BEGINNER_START_Z              		15.3746
#define BEGINNER_START_A              		270.0000

// -----------------------------------------------------------------------------

enum
{
    DIALOG_PLAYER_REGISTER,
    DIALOG_PLAYER_CONNECT,
    DIALOG_PLAYER_GENDER
};

enum Gender (+=1)
{
    INVALID_GENDER_ID,
    MALE_GENDER_ID,
    FEMALE_GENDER_ID
};

enum Admin (+=1)
{
    INVALID_ADMIN_ID,
    HELPER_ADMIN_ID,
    MOD_ADMIN_ID,
    MANAGER_ADMIN_ID,
    BOSS_ADMIN_ID
};

enum Job (+=1)
{
    INVALID_JOB_ID,
    PIZZABOY_JOB_ID,
    TRUCKER_JOB_ID,
    ELECTRICIAN_JOB_ID,
    POLICE_JOB_ID
};

enum E_PLAYER_DATA
{
    E_PLAYER_PASSWORD[MAX_PASSWORD],
    E_PLAYER_LASTLOGIN[24],

    Gender:E_PLAYER_GENDER,
    Admin:E_PLAYER_ADMIN,
    Job:E_PLAYER_JOB,

    E_PLAYER_HUNGER,
    E_PLAYER_THIRST,
    E_PLAYER_ATTEMPS,

    bool:E_PLAYER_LOGGED,

    Float:E_PLAYER_X,
    Float:E_PLAYER_Y,
    Float:E_PLAYER_Z,
    Float:E_PLAYER_A
};

static player[MAX_PLAYERS][E_PLAYER_DATA];

main(){}

public OnGameModeExit()
{
    DOF2::Exit();
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    if(!IsPlayerLogged(playerid))
    {
        ClearLines(playerid, 30);
        TogglePlayerSpectating(playerid, true);
        InterpolateCameraPos(playerid, 2118.152343, 2142.547363, 43.101249, 2290.450195, 2143.153808, 36.116157, 7500);
        InterpolateCameraLookAt(playerid, 2123.133056, 2142.632324, 42.669498, 2295.448242, 2143.184570, 35.975551, 7500);

        if(!DOF2::FileExists(formatFile(playerid)))
            ShowPlayerDialog(playerid, DIALOG_PLAYER_REGISTER, DIALOG_STYLE_PASSWORD, "Cadastro", "{FFFFFF}Insira uma senha para cadastrar-se:", "Cadastrar", "Sair");
        else
            ShowPlayerDialog(playerid, DIALOG_PLAYER_CONNECT, DIALOG_STYLE_PASSWORD, "Conectando", "{FFFFFF}Insira sua senha para conectar-se:", "Conectar", "Sair");
    }
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if(!IsPlayerSpawned(playerid))
    {
    	ClearLines(playerid, 50);
        SendClientMessagef(playerid, -1, "{98FB98}* {FFFFFF}Olá {98FB98}%s{FFFFFF}, seu último login no servidor foi: {98FB98}%s{FFFFFF}.", formatName(playerid), player[playerid][E_PLAYER_LASTLOGIN]);
        SendClientMessage(playerid, -1, "{98FB98}* {FFFFFF}Caso tenha dúvidas e precisar de ajuda use os comandos {98FB98}/ajuda {FFFFFF}e {98FB98}/comandos{FFFFFF}.");
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
        case DIALOG_PLAYER_REGISTER:
        {
            if(!response)
                return Kick(playerid);

            if(!(MIN_PASSWORD <= strlen(inputtext) <= MAX_PASSWORD))
            {
                new dialog[100];
                format(dialog, sizeof(dialog), "{FFFFFF}Insira uma senha para cadastrar-se:\n\n{FF0000}* Insira uma senha entre %i a %i caracteres.", MIN_PASSWORD, MAX_PASSWORD);
                ShowPlayerDialog(playerid, DIALOG_PLAYER_REGISTER, DIALOG_STYLE_PASSWORD, "Cadastro", dialog, "Cadastrar", "Sair");
            }
            else
            {
                format(player[playerid][E_PLAYER_PASSWORD], MAX_PASSWORD, inputtext);
                format(player[playerid][E_PLAYER_LASTLOGIN], 24, formatTime());

                // -------------------------------------------------------------

                DOF2::CreateFile(formatFile(playerid));
                DOF2::SetString(formatFile(playerid), "password", player[playerid][E_PLAYER_PASSWORD]);
                DOF2::SetString(formatFile(playerid), "last_login", player[playerid][E_PLAYER_LASTLOGIN]);
                DOF2::SetString(formatFile(playerid), "ip", formatIP(playerid));
                DOF2::SetInt(formatFile(playerid), "money", 0);
                DOF2::SetInt(formatFile(playerid), "score", 0);
                DOF2::SetInt(formatFile(playerid), "skin", 0);
                DOF2::SetInt(formatFile(playerid), "interior", 0);
                DOF2::SetInt(formatFile(playerid), "world", 0);
                DOF2::SetInt(formatFile(playerid), "wanted", 0);
                DOF2::SetFloat(formatFile(playerid), "health", 100.0);
                DOF2::SetFloat(formatFile(playerid), "armour", 0.0);

                DOF2::SetInt(formatFile(playerid), "gender", _:(player[playerid][E_PLAYER_GENDER] = INVALID_GENDER_ID));
                DOF2::SetInt(formatFile(playerid), "admin", _:(player[playerid][E_PLAYER_ADMIN] = INVALID_ADMIN_ID));
                DOF2::SetInt(formatFile(playerid), "job", _:(player[playerid][E_PLAYER_JOB] = INVALID_JOB_ID));

                DOF2::SetInt(formatFile(playerid), "hunger", player[playerid][E_PLAYER_HUNGER] = 30);
                DOF2::SetInt(formatFile(playerid), "thirst", player[playerid][E_PLAYER_THIRST] = 30);

                DOF2::SetFloat(formatFile(playerid), "x", player[playerid][E_PLAYER_X] = BEGINNER_START_X);
                DOF2::SetFloat(formatFile(playerid), "y", player[playerid][E_PLAYER_Y] = BEGINNER_START_Y);
                DOF2::SetFloat(formatFile(playerid), "z", player[playerid][E_PLAYER_Z] = BEGINNER_START_Z);
                DOF2::SetFloat(formatFile(playerid), "a", player[playerid][E_PLAYER_A] = BEGINNER_START_A);
                DOF2::SaveFile();

                // -------------------------------------------------------------

                SendClientMessage(playerid, -1, "{98FB98}* {FFFFFF}Cadastro efetuado com sucesso.");
                ShowPlayerDialog(playerid, DIALOG_PLAYER_GENDER, DIALOG_STYLE_MSGBOX, "Sexualidade", "{FFFFFF}Informe seu sexo abaixo:", "Masculino", "Feminino");
            }
        }
        case DIALOG_PLAYER_GENDER:
        {
            ClearLines(playerid, 50);
            SendClientMessagef(playerid, -1, "{98FB98}* {FFFFFF}Bem-vindo(a) {98FB98}%s{FFFFFF}, pela primeira vez ao nosso servidor.", formatName(playerid));
            SendClientMessage(playerid, -1, "{98FB98}* {FFFFFF}Caso tenha dúvidas e precisar de ajuda use os comandos {98FB98}/ajuda {FFFFFF}e {98FB98}/comandos{FFFFFF}.");

            SetPlayerLogged(playerid, true);
            TogglePlayerSpectating(playerid, false);
            GivePlayerMoney(playerid, BEGINNER_START_MONEY);
            SetPlayerGender(playerid, ((response) ? (MALE_GENDER_ID) : (FEMALE_GENDER_ID)));

            SetSpawnInfo(playerid, NO_TEAM, ((response) ? (BEGINNER_SKIN_MALE) : (BEGINNER_SKIN_FEMALE)), player[playerid][E_PLAYER_X], player[playerid][E_PLAYER_Y], player[playerid][E_PLAYER_Z], player[playerid][E_PLAYER_A], 0, 0, 0, 0, 0, 0);
            SetCameraBehindPlayer(playerid);
            SpawnPlayer(playerid);
        }
        case DIALOG_PLAYER_CONNECT:
        {
            if(!response)
                return Kick(playerid);

            if(!strlen(inputtext))
                return ShowPlayerDialog(playerid, DIALOG_PLAYER_CONNECT, DIALOG_STYLE_PASSWORD, "Conectando", "{FFFFFF}Insira sua senha para conectar-se:", "Conectar", "Sair");

            format(player[playerid][E_PLAYER_PASSWORD], MAX_PASSWORD, DOF2::GetString(formatFile(playerid), "password"));
            format(player[playerid][E_PLAYER_LASTLOGIN], 24, DOF2::GetString(formatFile(playerid), "last_login"));

            if(!strcmp(player[playerid][E_PLAYER_PASSWORD], inputtext))
            {
                GivePlayerMoney(playerid, DOF2::GetInt(formatFile(playerid), "money"));
                SetPlayerScore(playerid, DOF2::GetInt(formatFile(playerid), "score"));
                SetPlayerSkin(playerid, DOF2::GetInt(formatFile(playerid), "skin"));
                SetPlayerInterior(playerid, DOF2::GetInt(formatFile(playerid), "interior"));
                SetPlayerVirtualWorld(playerid, DOF2::GetInt(formatFile(playerid), "world"));
                SetPlayerWantedLevel(playerid, DOF2::GetInt(formatFile(playerid), "wanted"));
                SetPlayerHealth(playerid, DOF2::GetFloat(formatFile(playerid), "health"));
                SetPlayerArmour(playerid, DOF2::GetFloat(formatFile(playerid), "armour"));

                player[playerid][E_PLAYER_GENDER] = Gender:DOF2::GetInt(formatFile(playerid), "gender");
                player[playerid][E_PLAYER_ADMIN] = Admin:DOF2::GetInt(formatFile(playerid), "admin");
                player[playerid][E_PLAYER_JOB] = Job:DOF2::GetInt(formatFile(playerid), "job");

                player[playerid][E_PLAYER_HUNGER] = DOF2::GetInt(formatFile(playerid), "hunger");
                player[playerid][E_PLAYER_THIRST] = DOF2::GetInt(formatFile(playerid), "thirst");

                player[playerid][E_PLAYER_X] = DOF2::GetFloat(formatFile(playerid), "x");
                player[playerid][E_PLAYER_Y] = DOF2::GetFloat(formatFile(playerid), "y");
                player[playerid][E_PLAYER_Z] = DOF2::GetFloat(formatFile(playerid), "z");
                player[playerid][E_PLAYER_A] = DOF2::GetFloat(formatFile(playerid), "a");

                SetPlayerLogged(playerid, true);
                TogglePlayerSpectating(playerid, false);

                SetSpawnInfo(playerid, NO_TEAM, GetPlayerSkin(playerid), player[playerid][E_PLAYER_X], player[playerid][E_PLAYER_Y], player[playerid][E_PLAYER_Z], player[playerid][E_PLAYER_A], 0, 0, 0, 0, 0, 0);
                SetCameraBehindPlayer(playerid);
                SpawnPlayer(playerid);
            }
            else
            {
                if(++player[playerid][E_PLAYER_ATTEMPS] >= MAX_ATTEMPS_PASSWORD)
                {
                    SendClientMessagef(playerid, -1, "* Você foi expulso do servidor por errar a senha %i vezes.", MAX_ATTEMPS_PASSWORD);
                    return Kick(playerid);
                }
                new dialog[90];
                format(dialog, sizeof(dialog), "{FFFFFF}Insira sua senha para conectar-se:\n\n{FF0000}* Senha incorreta (%i/%i).", player[playerid][E_PLAYER_ATTEMPS], MAX_ATTEMPS_PASSWORD);
                ShowPlayerDialog(playerid, DIALOG_PLAYER_CONNECT, DIALOG_STYLE_PASSWORD, "Conectando", dialog, "Conectar", "Sair");
            }
        }
    }
    return 1;
}

// -----------------------------------------------------------------------------

// UTILS:

ClearLines(playerid, lines)
    for(new i; i != lines; ++i)
        SendClientMessage(playerid, -1, #);

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

// STOCKS:

stock SetPlayerLogged(playerid, bool:value)
{
    player[playerid][E_PLAYER_LOGGED] = value;
}

stock bool:IsPlayerLogged(playerid)
{
    return player[playerid][E_PLAYER_LOGGED];
}

stock SetPlayerGender(playerid, Gender:id)
{
    player[playerid][E_PLAYER_GENDER] = id;
}

stock Gender:GetPlayerGender(playerid)
{
    return player[playerid][E_PLAYER_GENDER];
}

stock GetPlayerGenderName(playerid, bool:lower = false)
{
    new name[16];

    switch(GetPlayerGender(playerid))
    {
        case MALE_GENDER_ID:
            name = "Masculino";

        case FEMALE_GENDER_ID:
            name = "Feminino";

        default:
            name = "Não Informado";
    }

    if(lower)
        name[0] = tolower(name[0]);

    return name;
}

// SAVE & RESET:

SavePlayerData(playerid)
{
    if(IsPlayerLogged(playerid))
    {
        if(DOF2::FileExists(formatFile(playerid)))
        {
            format(player[playerid][E_PLAYER_LASTLOGIN], 24, formatTime());
            GetPlayerPos(playerid, player[playerid][E_PLAYER_X], player[playerid][E_PLAYER_Y], player[playerid][E_PLAYER_Z]);
            GetPlayerFacingAngle(playerid, player[playerid][E_PLAYER_A]);

            DOF2::SetString(formatFile(playerid), "last_login", player[playerid][E_PLAYER_LASTLOGIN]);
            DOF2::SetString(formatFile(playerid), "ip", formatIP(playerid));
            DOF2::SetInt(formatFile(playerid), "money", GetPlayerMoney(playerid));
            DOF2::SetInt(formatFile(playerid), "score", GetPlayerScore(playerid));
            DOF2::SetInt(formatFile(playerid), "skin", GetPlayerSkin(playerid));
            DOF2::SetInt(formatFile(playerid), "interior", GetPlayerInterior(playerid));
            DOF2::SetInt(formatFile(playerid), "world", GetPlayerVirtualWorld(playerid));
            DOF2::SetInt(formatFile(playerid), "wanted", GetPlayerWantedLevel(playerid));
            DOF2::SetFloat(formatFile(playerid), "health", formatHealth(playerid));
            DOF2::SetFloat(formatFile(playerid), "armour", formatArmour(playerid));

            DOF2::SetInt(formatFile(playerid), "gender", _:player[playerid][E_PLAYER_GENDER]);
            DOF2::SetInt(formatFile(playerid), "admin", _:player[playerid][E_PLAYER_ADMIN]);
            DOF2::SetInt(formatFile(playerid), "job", _:player[playerid][E_PLAYER_JOB]);

            DOF2::SetInt(formatFile(playerid), "hunger", player[playerid][E_PLAYER_HUNGER]);
            DOF2::SetInt(formatFile(playerid), "thirst", player[playerid][E_PLAYER_THIRST]);

            DOF2::SetFloat(formatFile(playerid), "x", player[playerid][E_PLAYER_X]);
            DOF2::SetFloat(formatFile(playerid), "y", player[playerid][E_PLAYER_Y]);
            DOF2::SetFloat(formatFile(playerid), "z", player[playerid][E_PLAYER_Z]);
            DOF2::SetFloat(formatFile(playerid), "a", player[playerid][E_PLAYER_A]);
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
    SetPlayerLogged(playerid, false);

    player[playerid][E_PLAYER_GENDER] = INVALID_GENDER_ID;
    player[playerid][E_PLAYER_ADMIN] = INVALID_ADMIN_ID;
    player[playerid][E_PLAYER_JOB] = INVALID_JOB_ID;

    player[playerid][E_PLAYER_HUNGER] = player[playerid][E_PLAYER_THIRST] = player[playerid][E_PLAYER_ATTEMPS] = 0;
    player[playerid][E_PLAYER_X] = player[playerid][E_PLAYER_Y] = player[playerid][E_PLAYER_Z] = player[playerid][E_PLAYER_A] = 0.0;
}
