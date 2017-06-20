// ====================================================================================
//
//	wh_nametagInit.sqf - Initializes values for WH nametags.
//
// ====================================================================================

// ------------------------------------------------------------------------------------
// Initial setup.
// ------------------------------------------------------------------------------------

// Make sure this isn't a dedicated server or headless client.
if (!hasInterface) exitWith {};

// Let the player initialize properly.
waitUntil{!isNull player && {player == player}};
sleep 0.2;


// ------------------------------------------------------------------------------------
// Configuration import.
// ------------------------------------------------------------------------------------

#include "wh_nametagCONFIG.sqf"


// ------------------------------------------------------------------------------------
// Final steps of preparation.
// ------------------------------------------------------------------------------------

// Reveal all players so cursorTarget won't act up.
{ player reveal [_x,4]; } forEach allPlayers;

// Determine proper text spacing depending on font size.
WH_NT_FONT_SPREAD_TOP = WH_NT_FONT_SPREAD_COEF * WH_NT_FONT_SIZE_SEC * 0.5185; //0.5185;
WH_NT_FONT_SPREAD_BOT = WH_NT_FONT_SPREAD_COEF * WH_NT_FONT_SIZE_SEC * 0.6666; //0.6666;
					  
// Wait for player to get in-game.
waitUntil {!isNull (findDisplay 46)};

// Global variable that will be flipped on and off using the disableKey.
WH_NT_NAMETAGS_ON = true; 	

// Setting up our disableKey.
if (!isNil "WH_NT_ACTIONKEY") then
{
	WH_NT_ACTIONKEY_KEY = (actionKeys WH_NT_ACTIONKEY) select 0;// This key, a global variable.
	WH_NT_ACTIONKEY_KEYNAME = actionKeysNames WH_NT_ACTIONKEY;	// Which is named this...
	
	// Function that will determine when the disableKey is depressed.
	WH_NT_KEYDOWN = 
	{
		_key = _this select 1;
		_handled = false;
		if(_key == WH_NT_ACTIONKEY_KEY) then
		{
			WH_NT_NAMETAGS_ON = !WH_NT_NAMETAGS_ON;
			_handled = true;
		};
		_handled;
	};

	// Function that will determine when the disableKey is released.
	WH_NT_KEYUP = 
	{
		_key = _this select 1;
		_handled = false;
		if(_key == WH_NT_ACTIONKEY_KEY) then
		{
			_handled = true;
		};
		_handled;
	};
	
	// Add eventhandlers (functions above).
	(findDisplay 46) displayAddEventHandler   ["keydown", "_this call WH_NT_KEYDOWN"];
	(findDisplay 46) displayAddEventHandler   ["keyup", "_this call WH_NT_KEYUP"];
};


// ------------------------------------------------------------------------------------
// Setting up CBA_Settings box.
// ------------------------------------------------------------------------------------

// Establishing variables for use in settings. Do not delete this.
WH_NT_FONT_SIZE_MULTI = 1;

// Checks if CBA is present, adds settings if so.
#include "wh_nametagCba.sqf"


// ------------------------------------------------------------------------------------
// Set player to run main loop each frame, unscheduled.
// ------------------------------------------------------------------------------------

WH_NT_EVENTHANDLER = addMissionEventHandler 
["Draw3D", { if (alive player) then {	 call wh_nt_fnc_nametagUpdate	}; }];