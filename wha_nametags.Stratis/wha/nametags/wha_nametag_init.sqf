//====================================================================================
//
//	wha_nametag_init.sqf - Initializes values for WHA nametags.
//
//	[] execVM "wha\nametags\wha_nametag_init.sqf";
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Initial setup.
//------------------------------------------------------------------------------------

//	Make sure this isn't a dedicated server or headless client.
if (!hasInterface) exitWith {};

//	Global variable that will be flipped on and off using the disableKey and CBA.
WHA_NAMETAG_ON = true; 

//	Determine which mods are active.
#include "include\wha_nametag_checkMods.sqf";


//------------------------------------------------------------------------------------
//	Configuration and settings import and setup.
//------------------------------------------------------------------------------------

//	Allows for missionmaker configuration of important settings.
#include "wha_nametag_CONFIG.sqf"

//	Allows for player (client) configuration of other settings.
#include "include\wha_nametag_settings.sqf"


//------------------------------------------------------------------------------------
//	More preparation.
//------------------------------------------------------------------------------------

//	Let the player initialize properly.
waitUntil{!isNull player};
waitUntil{player == player};

//	Reset font spacing and size to (possibly) new conditions.
call wha_nametag_fnc_resetFont;

//	Setting up cursor cache and fader.
WHA_NAMETAG_CACHE_CURSOR = objNull;
WHA_NAMETAG_CACHE_CURSOR_DATA = [];
WHA_NAMETAG_CACHE_FADE = [[],[],[]];

//	Wait for player to get ingame.
waitUntil {!isNull (findDisplay 46)};

//	Setting up our disableKey (Default '+')
#include "include\wha_nametag_disableKey.sqf"


//------------------------------------------------------------------------------------
//	Keep an updated cache of all tags to draw.
//------------------------------------------------------------------------------------

#include "include\wha_nametag_cacheLoop.sqf"


//------------------------------------------------------------------------------------
//	Render nametags from the cache every frame.
//------------------------------------------------------------------------------------

WHA_NAMETAG_EVENTHANDLER = addMissionEventHandler 
["Draw3D", 
{
	if WHA_NAMETAG_ON then
	{	call wha_nametag_fnc_update	};
}];