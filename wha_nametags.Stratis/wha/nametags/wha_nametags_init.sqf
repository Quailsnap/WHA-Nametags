//====================================================================================
//
//	wha_nametags_init.sqf - Initializes values for WHA nametags.
//
//	[] execVM "wha\nametags\wha_nametags_init.sqf";
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Initial setup.
//------------------------------------------------------------------------------------

//	Make sure this isn't a dedicated server or headless client.
if (!hasInterface) exitWith {};

//	Global variable that will be flipped on and off using the disableKey and CBA.
WHA_NAMETAGS_ON = true; 

//	Determine which mods are active.
#include "include\wha_nametags_checkMods.sqf";


//------------------------------------------------------------------------------------
//	Configuration and settings import and setup.
//------------------------------------------------------------------------------------

//	Allows for missionmaker configuration of important settings.
#include "wha_nametags_CONFIG.sqf"

//	Allows for player (client) configuration of other settings.
#include "include\wha_nametags_settings.sqf"


//------------------------------------------------------------------------------------
//	More preparation.
//------------------------------------------------------------------------------------

//	Let the player initialize properly.
waitUntil{!isNull player};
waitUntil{player == player};

//	Variable that will be used to keep track of Arma's day/night cycle.
WHA_NAMETAGS_VAR_NIGHT = 1;

//	Reset font spacing and size to (possibly) new conditions.
call wha_nametags_fnc_resetFont;

//	Setting up cursor cache and fader.
WHA_NAMETAGS_CACHE_CURSOR = objNull;
WHA_NAMETAGS_CACHE_CURSOR_DATA = [];
WHA_NAMETAGS_CACHE_FADE = [[],[],[]];

//	Wait for player to get ingame.
waitUntil {!isNull (findDisplay 46)};

//	Setting up our disableKey (Default '+')
#include "include\wha_nametags_disableKey.sqf"


//------------------------------------------------------------------------------------
//	Keep an updated cache of all tags to draw.
//------------------------------------------------------------------------------------

#include "include\wha_nametags_cacheLoop.sqf"


//------------------------------------------------------------------------------------
//	Render nametags from the cache every frame.
//------------------------------------------------------------------------------------

WHA_NAMETAGS_EVENTHANDLER = addMissionEventHandler 
["Draw3D", 
{
	if WHA_NAMETAGS_ON then
	{	call wha_nametags_fnc_onEachFrame	};
}];