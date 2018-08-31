//====================================================================================
//
//	wha_nametags_cacheLoop.sqf - Checks near entities and processes them for tag data.
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Initial setup.
//------------------------------------------------------------------------------------

//	Array that will hold all cache data.
WHA_NAMETAGS_CACHE = [];


//------------------------------------------------------------------------------------
//	Loops every 0.5 seconds using CBA PFH.
//------------------------------------------------------------------------------------

WHA_NAMETAGS_CACHE_LOOP =
[
	{ 
		if WHA_NAMETAGS_ON then
		{ call wha_nametags_fnc_cache };
	},
	0.5,
	[]
] call CBA_fnc_addPerFrameHandler;