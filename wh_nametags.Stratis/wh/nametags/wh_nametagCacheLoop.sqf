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

//	Check if CBA is present.
if ( isClass(configFile >> "CfgPatches" >> "cba_settings") ) then
{
	WH_NT_CACHE_LOOP =
	[
		{ call wh_nt_fnc_nametagCache },
		0.5,
		[]
	] call CBA_fnc_addPerFrameHandler;
}
else
{
	WH_NT_CACHE_LOOP = [] spawn
	{
		_delay = 0.5;
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
};