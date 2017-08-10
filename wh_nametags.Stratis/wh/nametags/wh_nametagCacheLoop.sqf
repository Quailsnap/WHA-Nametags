//====================================================================================
//
//	wh_nametagCacheLoop.sqf - Checks near entities and processes them for tag data.
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Initial setup.
//------------------------------------------------------------------------------------

//	Array that will hold all cache data.
WH_NT_CACHE = [];

//	Variable that will be used to keep track of Arma's day/night cycle.
WH_NT_VAR_NIGHT = 1;


//------------------------------------------------------------------------------------
//	Loops every 0.5 seconds using CBA PFH.
//------------------------------------------------------------------------------------

WH_NT_CACHE_LOOP =
[
	{ call wh_nt_fnc_nametagCache },
	0.5,
	[]
] call CBA_fnc_addPerFrameHandler;