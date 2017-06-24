// ====================================================================================
//
//	wh_nametagInit.sqf - Initializes values for WH nametags.
//
// ====================================================================================

// ------------------------------------------------------------------------------------
//	Initial setup.
// ------------------------------------------------------------------------------------

// Make sure this isn't a dedicated server or headless client.
if (!hasInterface) exitWith {};

// Let the player initialize properly.
waitUntil{!isNull player && {player == player}};
sleep 0.2;


// ------------------------------------------------------------------------------------
//	Configuration import.
// ------------------------------------------------------------------------------------

#include "wh_nametagCONFIG.sqf"


// ------------------------------------------------------------------------------------
//	Setting up CBA_Settings box.
// ------------------------------------------------------------------------------------

// Checks if CBA is present, adds settings if so.
#include "wh_nametagCba.sqf"


// ------------------------------------------------------------------------------------
//	Final steps of preparation.
// ------------------------------------------------------------------------------------

// Reveal all players so cursorTarget won't act up.
{ 
	if ( (side _x == side player) || {(side _x == civilian)} )
	then { player reveal [_x,4]; }
} forEach allPlayers;

// Determine proper text spacing depending on font size.
call wh_nt_fnc_nametagSetFontSpread;
					  
// Wait for player to get in-game.
waitUntil {!isNull (findDisplay 46)};

// Global variable that will be flipped on and off using the disableKey.
WH_NT_NAMETAGS_ON = true; 	

// Setting up our disableKey (Default 'U')
#include "wh_nametagDisableKey.sqf"


// ------------------------------------------------------------------------------------
//	Set player to run main loop each frame, unscheduled.
// ------------------------------------------------------------------------------------

WH_NT_EVENTHANDLER = addMissionEventHandler 
["Draw3D", { call wh_nt_fnc_nametagUpdate }];
//["WH_NT_EVENTHANDLER","onEachFrame",{call wh_nt_fnc_nametagUpdate}] call BIS_fnc_addStackedEventHandler;