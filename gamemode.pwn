/*
				       _fortCarson :: GameMode 

		      Jeigu turi ðita gm, reiðkias kaþkas ne taip :/
			 	     Kas be ko, naudok já iðmintingai

	    autorius: Ainis Petkevièius [ Hoonzy_ ] ( maperis, ne coderis )
	    		  mapperis: Ainis Petkevièius [ Hoonzy_ ]
			     		  kûrimo metai: 2016-05-05

		pavieðindamas ðita kodà  árodþiau jog ir maperiai moka codint :*

*/
#include <a_samp>
#include <a_mysql>
#include <sscanf2>
#include <streamer>
#include <foreach>

/*
	#include <YSI\y_inline>
	#include <YSI\y_dialog>
*/
#include <YSI\y_commands>
#include <YSI\y_timers>

#define _host "localhost"
#define _username "root"
#define _database "fortcarson"
#define _password ""

new 
	database;

#define _version "fC v. 0.0.02"
#define _map "Los Santos"
#define _language "Lietuviø"

/*
	//////////////////////////////////////////////////
	• why i added this ?
	//////////////////////////////////////////////////
*/
#define _version_h "v. 0.0.02"
#define _version_g "v. 0.0.00"
#define _version_s "v. 0.0.00"

#if !defined 	MAX_HOUSES
	#define 	MAX_HOUSES 		500
#endif

#if !defined 	MAX_GARAGES
	#define 	MAX_GARAGES 	100
#endif

#if !defined 	MAX_STORAGES
	#define 	MAX_STORAGES 	100
#endif

#if !defined 	MAX_JOBS
	#define 	MAX_JOBS 		10
#endif

#define 		JOB_POLICE		1
#define 		JOB_MEDICS		2
#define 		JOB_TAXI		3
#define 		JOB_MECH		4
#define 		JOB_TRUCK		5
#define 		JOB_LAWYER		6
#define 		JOB_FIRE		7
#define 		JOB_COUR		8

#if !defined 	frmt
	#define 	frmt(%0) (format(lenght_def, sizeof lenght_def, %0), lenght_def) 
#endif
#if !defined 	forLoop
	#define 	forLoop(%0, %1) for(new %0=0; %0 <= %1; %0++)
#endif
#if !defined 	isnull
	#define 	isnull(%1)   ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif
#if !defined 	IsVehicleInRangeOfPoint
#define 		IsVehicleInRangeOfPoint(%0,%1,%2,%3,%4) %1 >= GetVehicleDistanceFromPoint(%0,%2,%3,%4) ? true : false
#endif
new 
	lenght_def[ 1000 ];

#if !defined 	holding
	#define 	holding(%0) 	((newkeys & (%0)) == (%0))
#endif
#if !defined 	pressed
	#define 	pressed(%0) 	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#endif
#if !defined 	released
	#define 	released(%0) 	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#endif

#define 		COL_WHI 		"{FFFFFF}"
#define 		COL_RED 		"{CC0000}"
#define 		COL_YEL 		"{FFCC00}"
#define 		COL_GRE 		"{828282}"
#define 		COL_BLU			"{2980b9}"

#if !defined 	MAX_PLAYER_PASS
	#define 	MAX_PLAYER_PASS	100
#endif	
#if !defined 	MAX_PLAYER_IP
	#define 	MAX_PLAYER_IP 	16
#endif	
#if !defined 	MAX_PLAYER_EMAIL
	#define 	MAX_PLAYER_EMAIL 100
#endif	


#include "modules/player.inc"
#include "modules/map.inc"
#include "modules/dialogs.inc"
#include "modules/drugs.inc"

#include "modules/textdraws/player.inc"

main() { 
	print("\n\n\n");
	print("			_fortCarson :: GameMode");
	print("			_autorius: Ainis Petkevièius [ Hoonzy_ ]");
	print("			_kûrimo metai: 2016-05-05");
	print("\n\n\n");

	print("			_fortCarson :: gamemode version - "_version"");
	print("			_fortCarson :: gamemode map - "_map"");
	print("			_fortCarson :: gamemode lang - "_language"");
	print("\n\n\n");

	print("			_fortCarson :: house system - "_version_h"");
	print("			_fortCarson :: garage system - "_version_g"");
	print("			_fortCarson :: storage system - "_version_s"");
	print("\n\n\n");
}


public OnGameModeInit()
{
	printf("			_gamemode :: 'OnGameModeInit()' callback execution is in process...");

	mysql_log(LOG_ERROR);
	database = mysql_connect(_host, _username, _database, _password);

	if(mysql_errno() == 0) printf("			_mysql :: connected to "_database" with "_username" access");
	else printf("			_mysql :: failure connecting to "_database" with "_username" access");

	SetGameModeText(_version);
	SendRconCommand("mapname "_map"");
	SendRconCommand("language "_language"");

	ManualVehicleEngineAndLights( );
	SetNameTagDrawDistance(20);
	EnableStuntBonusForAll(false);
	DisableInteriorEnterExits( );

	SetTimer("globaltimer", 1000, true);

	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);

	printf("			_gamemode :: 'OnGameModeInit()' successfully executed\n\n\n");
	return true;
}

public OnGameModeExit()
{
	printf("			_gamemode :: 'OnGameModeExit()' callback execution is in process...");

	for(new i; i < MAX_PLAYERS; i++) {
		if(!status[ i ][ p_connecting ]) {
			if(status[ i ][ p_playing ]) {
				player_data_save(i);
			}
		}
	}

	mysql_close( );

	printf("			_gamemode :: 'OnGameModeExit()' successfully executed\n\n\n");
	return true;
}

public OnPlayerRequestClass(playerid, classid)
{
	printf("			_gamemode :: 'OnPlayerRequestClass(...)' callback execution is in process...");

	new 
		query[ 500 ];

	mysql_format(database, query, sizeof query, "SELECT * FROM `vartotojai` WHERE `vardas` = '%s'", GetName(playerid));
	new 
		Cache: cache = mysql_query(database, query);

	if(cache_get_row_count()) dialog_login(playerid);
	else dialog_reg(playerid);

	cache_delete(cache);

	status[ playerid ][ p_connecting ] = true;
	status[ playerid ][ p_playing ] = false;
	status[ playerid ][ p_isnewbie ] = false;
	status[ playerid ][ p_died ] = false;

	printf("			_gamemode :: 'OnPlayerRequestClass(...)' successfully executed for player '%s'\n\n\n", GetName(playerid));
	return true;
}

public OnPlayerConnect(playerid)
{
	return true;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(!status[ playerid ][ p_connecting ]) {
		if(status[ playerid ][ p_playing ]) {
			player_data_save(playerid);
		}
	}
	return true;
}

public OnPlayerSpawn(playerid)
{
	if(!status[ playerid ][ p_connecting ]) {
		if(status[ playerid ][ p_isnewbie ]) {
			drugs_data_set(playerid);

			status[ playerid ][ p_isnewbie ] = false;
			status[ playerid ][ p_playing ] = true;
		}
		else {
			player_data_use(playerid);
			status[ playerid ][ p_playing ] = true;
		}

		for(new i; i < sizeof Logotipas; i++) PlayerTextDrawShow(playerid, Logotipas[ i ]);
	}
	return true;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return true;
}

public OnVehicleSpawn(vehicleid)
{
	return true;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return true;
}

public OnPlayerText(playerid, text[])
{
	return true;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return true;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return true;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return true;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return true;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return true;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return true;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return true;
}

public OnRconCommand(cmd[])
{
	return true;
}

public OnPlayerRequestSpawn(playerid)
{
	return true;
}

public OnObjectMoved(objectid)
{
	return true;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return true;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return true;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return true;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return true;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return true;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return true;
}

public OnPlayerExitedMenu(playerid)
{
	return true;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return true;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return true;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return true;
}

public OnPlayerUpdate(playerid)
{
	return true;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return true;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return true;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return true;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	/*
		//////////////////////////////////////////////////
		• Prisijungimas
		//////////////////////////////////////////////////
	*/
	if(dialogid == 1) {
		if(response) {
			new 
				entered_password[ MAX_PLAYER_PASS ],
				fails;

			if(fails == 3) msg_failure(playerid, "Buvote iðmestas nes bandëte prisijungti ne prie savo paskyros!"), Kick(playerid);

			if(sscanf(inputtext, "s[100]", entered_password)) return fails++, msg_failure(playerid, "Blogas slaptaþodis"), dialog_login(playerid);
			else if(strlen(entered_password) <= 3) return fails++, msg_failure(playerid, "Blogas slaptaþodis"), dialog_login(playerid);
			else if(strfind(entered_password, "%", true) != -1) return fails++, msg_failure(playerid, "Blogas slaptaþodis"), dialog_login(playerid);

			new 
				query[ 500 ];

			mysql_format(database, query, sizeof query, "SELECT * FROM `vartotojai` WHERE `vardas` = '%s' AND `slaptazodis` = '%i'", GetName(playerid), password_hash(entered_password));
			new 
				Cache: cache = mysql_query(database, query);

			if(cache_get_row_count())  msg_good(playerid, "Sëkmingai prisijungëte!"), status[ playerid ][ p_connecting ] = false;
			else fails++, msg_failure(playerid, "Blogas slaptaþodis"), dialog_login(playerid);
			cache_delete(cache);
		}
		else Kick(playerid);
	}
	/*
		//////////////////////////////////////////////////
		• Registracija
		//////////////////////////////////////////////////
	*/
	else if(dialogid == 2) {
		if(response) {
			new 
				entered_password[ MAX_PLAYER_PASS ];

			if(sscanf(inputtext, "s[100]", entered_password)) return msg_failure(playerid, "Áveskite slaptaþodá"), dialog_reg(playerid);
			else if(strlen(entered_password) <= 3) return msg_failure(playerid, "Atleiskite, taèiau slaptaþodis yra per trumpas!"), dialog_reg(playerid);
			else if(strlen(entered_password) >= 100) return msg_failure(playerid, "Atleiskite, taèiau slaptaþodis yra per ilgas!"), dialog_reg(playerid);
			else if(strfind(entered_password, "%", true) != -1) return msg_failure(playerid, "Blogas slaptaþodis"), dialog_reg(playerid);
		
			new 
				query[ 500 ];

			mysql_format(database, query, sizeof query, "INSERT INTO `vartotojai` (vardas, slaptazodis, ip) VALUES ('%s', '%i', '%s')", GetName(playerid), password_hash(entered_password), GetIp(playerid));
			mysql_query(database, query);

			dialog_gender(playerid);
		}
		else Kick(playerid);
	}
	/*
		//////////////////////////////////////////////////
		• Lyties pasirinkimas
		//////////////////////////////////////////////////
	*/
	else if(dialogid == 3) {
		if(response) {
			if(listitem == 0) {
				player[ playerid ][ p_gender ] = 1;
				status[ playerid ][ p_isnewbie ] = true;

				SendClientMessage(playerid, 0xFFFFFFFF, " ");
				msg_good(playerid, "Pasirinkta lytis - {008000}Vyras{D4D4D4}!");
				msg_good(playerid, "Galite spausti '{008000}SPAWN{D4D4D4}' ir pradëti þaidimà!");
			}
			if(listitem == 1) {
				player[ playerid ][ p_gender ] = 2;
				status[ playerid ][ p_isnewbie ] = true;

				SendClientMessage(playerid, 0xFFFFFFFF, " ");
				msg_good(playerid, "Pasirinkta lytis - {008000}Moteris{D4D4D4}!");
				msg_good(playerid, "Galite spausti '{008000}SPAWN{D4D4D4}' ir pradëti þaidimà!");
			}
		}
		else dialog_gender(playerid);
	}
	return true;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return true;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) 
{
	return true;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) 
{
	return true;
}

#include "modules/commands/admins.inc"

stock GetName(playerid) {
	new 
		name[ MAX_PLAYER_NAME ];

	GetPlayerName(playerid, name, sizeof name);
	return name;
}

stock GetIp(playerid) {
	new 
		ip[ 16 ];

	GetPlayerIp(playerid, ip, sizeof ip);
	return ip;
}

stock msg_good(playerid, text[]) {
	new 
		text_string[ 500 char ];

	format(text_string, sizeof text_string, "{008000}[ » ] {D4D4D4}%s", text);
	SendClientMessage(playerid, 0xFFFFFFFF, text_string);
	return true;
}

stock msg_failure(playerid, text[]) {
	new 
		text_string[ 500 char ];

	format(text_string, sizeof text_string, "{FF0000}[ ! ] {D4D4D4}%s", text);
	SendClientMessage(playerid, 0xFFFFFFFF, text_string);
	return true;
}

stock msg_admins(text[]) {
	new 
		text_string[ 500 char ];

	format(text_string, sizeof text_string, "{2E5077}[ admin chat ]{4DA1A9}: %s", text);
	for(new i; i < MAX_PLAYERS; i++) {
		SendClientMessage(i, 0xFFFFFFFF, text_string);
	}
	return true;
}

stock StrFind(searchingFor[]) {
    for(new i; i < MAX_PLAYERS; i++) {
    	new 
    		nameWeHave[ MAX_PLAYER_NAME ];

        GetPlayerName(i, nameWeHave, MAX_PLAYER_NAME);
        if(strfind(nameWeHave, searchingFor, true) != -1) return i;
	}
    return INVALID_PLAYER_ID;
}

stock IsNumeric(const string[]) {
	for(new i = 0, j = strlen(string); i < j; i++) {
	    if(string[ i ] > '9' || string[ i ] < '0') return 0;
	}
	return 1;
}

stock password_hash(buf[]) {
	new length = strlen(buf), s1 = 1, s2 = 0, n;
	for(n = 0; n < length; n++) {
		s1 = (s1 + buf[n]) % 65521;
		s2 = (s2 + s1)     % 65521;
	}
	return (s2 << 16) + s1;
}

forward globaltimer( );
public globaltimer( ) {
	new 
		years, month, day,
		hours, minutes, seconds,
		len_format[ 100 ],
		var_month[ 50 ];

	getdate(years, month, day);
	gettime(hours, minutes, seconds);

	switch(month) {
		case 1: var_month = "Sausio";
		case 2: var_month = "Vasario";
		case 3: var_month = "Kovo";
		case 4: var_month = "Balandzio";
		case 5: var_month = "Geguzes";
		case 6: var_month = "Birzelio";
		case 7: var_month = "Liepos";
		case 8: var_month = "Rugpjucio";
		case 9: var_month = "Rugsejio";
		case 10: var_month = "Spalio";
		case 11: var_month = "Lapkricio";
		case 12: var_month = "Gruodzio";
	}

	for(new i; i < MAX_PLAYERS; i++) {
		if(!status[ i ][ p_connecting ]) {
			if(status[ i ][ p_playing ]) {
				format(len_format, sizeof len_format, "%02d %s %02d", years, var_month, day);
				PlayerTextDrawSetString(i, Laikrodis[ 0 ], len_format);
				PlayerTextDrawShow(i, Laikrodis[ 0 ]);
				format(len_format, sizeof len_format, "%02d:%02d:%02d", hours, minutes, seconds);
				PlayerTextDrawSetString(i, Laikrodis[ 1 ], len_format);
				PlayerTextDrawShow(i, Laikrodis[ 1 ]);
			}
		}
	}
	return true;
}