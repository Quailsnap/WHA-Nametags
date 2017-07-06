//====================================================================================
//
//	wh_nametagInit.sqf - Initializes values for WH nametags.
//
//	> [] execVM "wh\nametags\wh_nametagInit.sqf"; <
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Initial setup.
//------------------------------------------------------------------------------------

//	Make sure this isn't a dedicated server or headless client.
if (!hasInterface) exitWith {};

//	Let the player initialize properly.
waitUntil{!isNull player && {player == player}};
sleep 0.2;


//------------------------------------------------------------------------------------
//	Configuration import.
//------------------------------------------------------------------------------------

//	Allows for missionmaker configuration of important settings.
#include "wh_nametagCONFIG.sqf"


//------------------------------------------------------------------------------------
//	Setting up CBA_Settings box.
//------------------------------------------------------------------------------------

//	Allows for player (client) configuration of other settings.
#include "wh_nametagCba.sqf"


//------------------------------------------------------------------------------------
//	Final steps of preparation.
//------------------------------------------------------------------------------------

//	Reveal all players (on same side) so cursorTarget won't act up.
{ 
	if ( (side _x getFriend side player) > 0.6 )
	then { player reveal [_x,4]; }
} forEach allPlayers;

//	Reset font spacing and size to (possibly) new conditions.
call wh_nt_fnc_nametagResetFont;
				  
//	Wait for player to get ingame.
waitUntil {!isNull (findDisplay 46)};

//	Global variable that will be flipped on and off using the disableKey.
WH_NT_NAMETAGS_ON = true; 	

//	Setting up our disableKey (Default '+')
#include "wh_nametagDisableKey.sqf"


//------------------------------------------------------------------------------------
//	Initiate a slow loop that will routinely check common values.
//------------------------------------------------------------------------------------

#include "wh_nametagCheck.sqf"


//------------------------------------------------------------------------------------
//	Set player to run main update loop each frame, unscheduled.
//------------------------------------------------------------------------------------

WH_NT_EVENTHANDLER = addMissionEventHandler 
["Draw3D", 
{
	if WH_NT_NAMETAGS_ON then
	{	call wh_nt_fnc_nametagUpdate	};
}];