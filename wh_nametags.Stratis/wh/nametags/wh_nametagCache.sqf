WH_NT_CACHE = [];

//	Establish variable that will be used to keep track of Arma's day/night cycle.
WH_NT_VAR_NIGHT = 1;

//	...and one for whether the player is in a vehicle.
WH_NT_VAR_INVEHICLE = false;

WH_NT_CACHE_LOOP =
[
	{
		if WH_NT_NAMETAGS_ON then
		{
			WH_NT_CACHE = 
			if !WH_NT_DRAWCURSORONLY then
			{ player nearEntities [["CAManBase","LandVehicle","Helicopter","Plane","Ship_F"], 
			((WH_NT_DRAWDISTANCE_NEAR+(WH_NT_DRAWDISTANCE_NEAR*0.25))*WH_NT_VAR_NIGHT)] }
			else { [] };
			
			//	Check the day night cycle...
			WH_NT_VAR_NIGHT = if ( !(sunOrMoon isEqualTo 1) && {WH_NT_NIGHT} ) then
			{ linearConversion [0, 1, sunOrMoon, 0.25+0.5*(currentVisionMode player),1,true]; } else { 1 };
		
			//	...check if the player is in a vehicle...
			WH_NT_VAR_INVEHICLE = !(isNull objectParent player);
		};
	},
	0.5,
	[]
] call CBA_fnc_addPerFrameHandler;