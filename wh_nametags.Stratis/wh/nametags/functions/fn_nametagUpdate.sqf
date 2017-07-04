//====================================================================================
//
//	fn_nametagUpdate.sqf - Updates values for WH nametags (heavily based on F3 and ST)
//						   Intended to be run each frame.
//
//	> 	WH_NT_EVENTHANDLER = addMissionEventHandler 
//		["Draw3D", { call wh_nt_fnc_nametagUpdate }]; <
//
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Initializing variables.
//------------------------------------------------------------------------------------

//	If the script is active...
if !(WH_NT_NAMETAGS_ON) exitWith {};

//	Save the player's variable.
private _player = player;

//	Find player camera's position and the direction their head is facing.
private _cameraPositionAGL = positionCameraToWorld[0,0,0];
private _cameraPositionASL = AGLtoASL _cameraPositionAGL;

//	Get zoom, which will be used to adjust spacing and size of text.
private _zoom = call wh_nt_fnc_getZoom;

//	Initialize other variables to be used in main loop.
private _targetPositionAGL;
private _targetPositionASL;
private _height;

//------------------------------------------------------------------------------------
//	Collecting nearby entities.
//------------------------------------------------------------------------------------

//	Establish _entities array.
//		Get the nearest entities (things that can animate that are not agents) if they
//		belong to the classes CAManBase (soldiers), LandVehicle, Helicopter, Plane, or
//		Ship_F and are within range, which is determined by the max distance to get all
//		entities multiplied by VAR_NIGHT, which will be <1 if visibility is limited due
//		to the time of day (dark or light).

private _entities = 
if !(WH_NT_DRAWCURSORONLY) then
{ _cameraPositionAGL nearEntities [["CAManBase","LandVehicle","Helicopter","Plane","Ship_F"], (WH_NT_DRAWDISTANCE_ALL*WH_NT_VAR_NIGHT)] }
else { [] };

//	Make sure cursorTarget is in the entity array.
if !WH_NT_VAR_PLAYER_INVEHICLE then
{
	if ((_player distance cursorTarget) <= (((WH_NT_DRAWDISTANCE_ONE) * WH_NT_VAR_NIGHT) * _zoom))
	then { _entities pushBackUnique cursorTarget; };
}
//	If the player is in a vehicle, use cursorObject.
//	cursorObject can look through windows.
else
{
	if ((_player distance cursorObject) <= (((WH_NT_DRAWDISTANCE_ONE) * WH_NT_VAR_NIGHT) * _zoom))
	then { _entities pushBackUnique cursorObject; };
};

//	Sort entities. Keep only the ones that are on the unit's side, or in their group,
//	and only if they are not the unit itself.
_entities = _entities select 
{
	(
		(side _x isEqualTo side player) || 
		{(_targetGroup isEqualTo group player)}
	) 
	&& {_x != player}
};


//------------------------------------------------------------------------------------
//	Loop through entities collected, sorting them to see what tags need rendering.
//------------------------------------------------------------------------------------
{
//	For every entity in the array...
	
	//	....If the entity is a man...
	if( _x isKindOf "Man" ) then 
	{
		//	Get the man's position. Add the height from their stance.
		//	If the option that places tags above target heads is enabled, get the
		//	position of the man's head.
		_targetPositionASL = 
		if !WH_NT_FONT_HEIGHT_ONHEAD
		then { (getPosASLVisual _x) vectorAdd [0,0,(_x call wh_nt_fnc_getHeight)] } 
		else { AGLtoASL ( _x modelToWorldVisual ((_x selectionPosition "head")   vectorAdd [0,0,0.5])) };
		
		_targetPositionAGL = ASLToAGL _targetPositionASL;

		//	And if that man can be seen...
		if
		(
			// ( If the man is within the boundaries of the screen )
			!(worldToScreen _targetPositionAGL isEqualTo []) &&
			// AND ( If the game can draw a line from the player to the man without hitting anything )
			{ lineIntersectsSurfaces [_cameraPositionASL, _targetPositionASL, _player, _x] isEqualTo [] }
		)

		//	... Then draw a nametag for him.
		//		Also, pass some extra info to the draw function, like whether the man
		//		is in the same group as the player, and also pass in a blank role
		//		so the draw function will get a non-crew role (ie: 'Autorifleman').
		then 
		{
			[_player,_cameraPositionAGL,(group _x isEqualTo group player),_x,_targetPositionAGL,_zoom,""]
			call wh_nt_fnc_nametagDraw;
		};
	}
	else 
	{
		//	Otherwise (if the entity is a vehicle)...

		//	Save the a variable reference to the vehicle for later.
		private _vehicle = _x;

		//	For every crew in the vehicle that's not the player...
		{
			//	The target's position is his real position.
			_targetPositionAGL = 
			if !WH_NT_FONT_HEIGHT_ONHEAD
			then { ASLtoAGL (getPosASLVisual _x) vectorAdd [0,0,(_x call wh_nt_fnc_getHeight)]  } 
			else { AGLtoASL ( _x modelToWorldVisual ((_x selectionPosition "head")   vectorAdd [0,0,0.5]))};

			//	...If they are on-screen...
			if ( !(worldToScreen _targetPositionAGL isEqualTo []) ) then
			{
				//	Check if the player and target are in the same group.
				private _sameGroup = (group _x isEqualTo group player);
				
				//	Get the crew's role, if present.
				private _role = call
				{
					if ( commander _vehicle isEqualTo _x ) exitWith {"Commander"};
					if ( gunner	   _vehicle isEqualTo _x ) exitWith {"Gunner"};
					if ( !(driver  _vehicle isEqualTo _x)) exitWith {""};
					if ( driver	   _vehicle isEqualTo _x && {!(_vehicle isKindOf "helicopter") && {!(_vehicle isKindOf "plane")}} ) exitWith {"Driver"};
					if ( driver	   _vehicle isEqualTo _x && { (_vehicle isKindOf "helicopter") || { (_vehicle isKindOf "plane")}} ) exitWith {"Pilot"};
					""
				};

				//	Only display the driver, commander, and members of the players group unless the player is up close.
				if (effectiveCommander _vehicle isEqualTo _x || {_sameGroup} || {(_cameraPositionAGL distance _targetPositionAGL) <= WH_NT_DRAWDISTANCE_ALL}) then
				{
					//	If the unit is the commander, pass the vehicle he's driving and draw the tag.
					if (effectiveCommander _vehicle isEqualTo _x) then 
					{ [_player,_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_zoom,_role,_vehicle] call wh_nt_fnc_nametagDraw; }
					else
					{
						//	If the unit is the driver but not the commander, or far enough from the driver that the tags will not overlap each other, draw the tags on them normally.
						if (driver _vehicle isEqualTo _x || {_targetPositionAGL distance (ASLToAGL getPosASLVisual(driver _vehicle)) > 0.2}) then
						{
							if (driver _vehicle isEqualTo _x || {gunner _vehicle isEqualTo _x}) then
							{
								[_player,_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_zoom,_role] call wh_nt_fnc_nametagDraw;
							}
							else
							{
								//	This case is for passengers.
								//	Check if the passenger is occluded before drawing the tag.
								if (lineIntersectsSurfaces [_cameraPositionASL, AGLtoASL _targetPositionAGL, _player, _x] isEqualTo []) then
								{
									[_player,_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_zoom,_role] call wh_nt_fnc_nametagDraw;
								};
							};
						}
						else
						{
							//	If the unit is in a gunner slot and not the commander, display the tag at the gun's position.
							if(_x isEqualTo gunner _vehicle) then
							{
								_targetPositionAGL = [_vehicle modeltoworld (_vehicle selectionPosition "gunnerview") select 0,_vehicle modeltoworld (_vehicle selectionPosition "gunnerview") select 1,(_targetPositionAGL) select 2];
								
								[_player,_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_zoom,_role] call wh_nt_fnc_nametagDraw;
							};
							//	A tag will NOT be displayed for passengers that are within 0.2m
							//	of the driver (a common occurrence in vehicles without interiors).
						};
					};
				};
			};
		} forEach (crew _vehicle select {!(_x isEqualTo _player)});
	};
} count _entities;