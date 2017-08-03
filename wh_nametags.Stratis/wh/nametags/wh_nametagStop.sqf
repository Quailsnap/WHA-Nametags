//====================================================================================
//
//	wh_nametagInit.sqf - Initializes values for WH nametags.
//
//	> [] execVM "wh\nametags\wh_nametagInit.sqf"; <
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//	Global variable that will be flipped on and off using the disableKey and CBA.
WH_NT_NAMETAGS_ON = false; 


#include "wh_nametagCheck.sqf"


//------------------------------------------------------------------------------------
//	Set player to keep an updated cache of all tags to draw.
//------------------------------------------------------------------------------------

#include "wh_nametagCache.sqf"


//------------------------------------------------------------------------------------
//	Set player to render nametags from the cache every frame.
//------------------------------------------------------------------------------------

WH_NT_EVENTHANDLER = addMissionEventHandler 
["Draw3D", 
{
	if WH_NT_NAMETAGS_ON then
	{	call wh_nt_fnc_nametagUpdate	};
}];