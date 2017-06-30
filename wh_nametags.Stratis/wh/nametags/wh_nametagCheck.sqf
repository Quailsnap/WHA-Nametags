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

//	Establish variable that will be used to keep track of Arma's day/night cycle.
WH_NT_VAR_NIGHT = 1;

//	...and one for whether the player is in a vehicle.
WH_NT_VAR_PLAYER_INVEHICLE = false;

//	Spawn a new script that can run parallel to others.
_null = [] spawn
{
	//	The delay of the proceeding loop. Default 3 (seconds).
	_delay = 3;
	
	//	A variable that can be used to kill the loop.
	WH_NT_S_SLOWLOOP_RUN = true;
	
	//	While the above variable is true, run the loop.
	while {WH_NT_S_SLOWLOOP_RUN} do
	{
		//	Check the day night cycle...
		WH_NT_VAR_NIGHT = if ( !(sunOrMoon isEqualTo 1) && {WH_NT_NIGHT} ) then
		{ linearConversion [0, 1, sunOrMoon, 0.25+0.5*(currentVisionMode player),1,true]; } else { 1 };
		
		//	...check if the player is in a vehicle...
		WH_NT_VAR_PLAYER_INVEHICLE = !(isNull objectParent player);
		
		//	...and then wait for the delay before doing it again.
		sleep _delay;
	};
};