//====================================================================================
//
//	wh_nametagInit.sqf - Initializes values for WH nametags.
//
//	[] execVM "wh\nametags\wh_nametagInit.sqf";
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Initial setup.
//------------------------------------------------------------------------------------

//	Make sure this isn't a dedicated server or headless client.
if (!hasInterface) exitWith {};

//	Global variable that will be flipped on and off using the disableKey and CBA.
WH_NT_NAMETAGS_ON = true; 

//	Determine which mods are active.
#include "wh_nametagCheckMods.sqf";


//------------------------------------------------------------------------------------
//	Configuration and settings import and setup.
//------------------------------------------------------------------------------------

//	Allows for missionmaker configuration of important settings.
#include "wh_nametagCONFIG.sqf"

//	Allows for player (client) configuration of other settings.
#include "wh_nametagSettings.sqf"


//------------------------------------------------------------------------------------
//	More preparation.
//------------------------------------------------------------------------------------

//	Let the player initialize properly.
waitUntil{!isNull player};
waitUntil{player == player};

//	Reset font spacing and size to (possibly) new conditions.
call wh_nt_fnc_nametagResetFont;

//	Setting up cursor cache and fader.
WH_NT_CACHE_CURSOR = objNull;
WH_NT_CACHE_CURSOR_DATA = [];
WH_NT_CACHE_FADE = [[],[],[]];

//	Wait for player to get ingame.
waitUntil {!isNull (findDisplay 46)};

//	Setting up our disableKey (Default '+')
#include "wh_nametagDisableKey.sqf"


//------------------------------------------------------------------------------------
//	Keep an updated cache of all tags to draw.
//------------------------------------------------------------------------------------

#include "wh_nametagCacheLoop.sqf"


//------------------------------------------------------------------------------------
//	Render nametags from the cache every frame.
//------------------------------------------------------------------------------------

WH_NT_EVENTHANDLER = addMissionEventHandler 
["Draw3D", 
{
	if WH_NT_NAMETAGS_ON then
	{	call wh_nt_fnc_nametagUpdate	};
}];