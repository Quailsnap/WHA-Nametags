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
//	Loops every second as long as the scheduler complies.
//------------------------------------------------------------------------------------

WH_NT_CACHE_LOOP = [] spawn
{
	_delay = 1;
	WH_NT_CACHE_LOOP_RUN = true;
	
	//	While the above variable is true, run the loop.
	while {WH_NT_CACHE_LOOP_RUN} do
	{
		//	...Cache all nearby units and their data...
		call wh_nt_fnc_nametagCache;
		
		//	...and then wait for the delay before doing it again.
		sleep _delay;
	};
};