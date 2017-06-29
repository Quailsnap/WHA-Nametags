// ====================================================================================
//
//	wh_nametagSlowLoop.sqf - Routinely checks common values for nametagUpdate.
//
//	> [] execVM "wh\nametags\wh_nametagSlowLoopsqf"; <
//	@ /u/Whalen207 | Whale #5963
//
//	Things to Check:
//	- WH_NT_VAR_PLAYER_INVEHICLE = (bool) whether player is in vehicle
//	- WH_NT_VAR_NIGHT = (number 0-1) outside brightness level
//
// ====================================================================================

// ------------------------------------------------------------------------------------
//	Spawn a new script to run parallel to others.
// ------------------------------------------------------------------------------------

WH_NT_VAR_NIGHT = 1;
WH_NT_VAR_PLAYER_INVEHICLE = false;

_null = [] spawn
{
	_delay = 3;
	
	WH_NT_S_SLOWLOOP_RUN = true;
	
	while {WH_NT_S_SLOWLOOP_RUN} do
	{
		WH_NT_VAR_NIGHT = if ( !(sunOrMoon isEqualTo 1) && {WH_NT_NIGHT} ) then
		{ linearConversion [0, 1, sunOrMoon, 0.25+0.5*(currentVisionMode player),1,true]; } else { 1 };
		
		WH_NT_VAR_PLAYER_INVEHICLE = (isNull objectParent player);
		
		sleep _delay;
	};
};