//====================================================================================
//
//	wha_nametag_cacheLoop.sqf - Checks near entities and processes them for tag data.
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Initial setup.
//------------------------------------------------------------------------------------

//	Array that will hold all cache data.
WHA_NAMETAG_CACHE = [];

//	Variable that will be used to keep track of Arma's day/night cycle.
WHA_NAMETAG_VAR_NIGHT = 1;


//------------------------------------------------------------------------------------
//	Loops every 0.5 seconds using CBA PFH.
//------------------------------------------------------------------------------------

WHA_NAMETAG_CACHE_LOOP =
[
	{ 
		if WHA_NAMETAG_ON then
		{	call wha_nametag_fnc_cache	};
	},
	0.5,
	[]
] call CBA_fnc_addPerFrameHandler;