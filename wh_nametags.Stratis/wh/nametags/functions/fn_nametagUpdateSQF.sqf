//====================================================================================
//
//	fn_nametagUpdate.sqf - Updates values for WH nametags (heavily based on F3 and ST)
//							Intended to be run each frame.
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
//	if !(WH_NT_NAMETAGS_ON) exitWith {};
private _player = player;

//	Find player camera's position and the direction their head is facing.
private _cameraPositionAGL = positionCameraToWorld[0,0,0];
private _cameraPositionASL = AGLtoASL _cameraPositionAGL;

//	Initialize other variables to be used.
private _targetPositionAGL;
private _targetPositionASL;
private _alpha;


//------------------------------------------------------------------------------------
//	Get zoom, which will be used to adjust size and spacing of text.
//------------------------------------------------------------------------------------
	
private _zoom = call wh_nt_fnc_getZoom;
	
	
//------------------------------------------------------------------------------------
//	Collecting nearby entities.
//------------------------------------------------------------------------------------

//	Establish entities array.
//		Get the nearest entities (things that can animate that are not agents) if they
//		belong to the classes CAManBase (soldiers), LandVehicle, Helicopter, Plane, or
//		Ship_F and are within range, which is determined by the max distance to get all
//		entities multiplied by VAR_NIGHT, which will be <1 if visibility is limited due
//		to the time of day (dark or light).

private _entities = WH_NT_CACHE;
//if !WH_NT_DRAWCURSORONLY then
//{ _player nearEntities [["CAManBase","LandVehicle","Helicopter","Plane","Ship_F"], //(WH_NT_DRAWDISTANCE_NEAR*WH_NT_VAR_NIGHT)] } // _cameraPositionAGL
//else { [] };


//------------------------------------------------------------------------------------
//	Collect cursorObject or cursorTarget depending on player mounted state.
//------------------------------------------------------------------------------------

private _cursorObject = 
//	If the player is outside of a vehicle, use cursorTarget.
//	cursorTarget sticks to units better.
if !WH_NT_VAR_INVEHICLE then
{
	if (
		(_player distance cursorTarget) <= (((WH_NT_DRAWDISTANCE_CURSOR) * WH_NT_VAR_NIGHT) * _zoom) &&
		(true)
		) 
	then { cursorTarget }
	else { objNull };
}
//	If the player is in a vehicle, use cursorObject.
//	cursorObject can look through windows.
else
{
	if ((_player distance cursorObject) <= (((WH_NT_DRAWDISTANCE_CURSOR) * WH_NT_VAR_NIGHT) * _zoom))
	then { cursorObject }
	else { objNull }; // nil?
};


//------------------------------------------------------------------------------------
//	Finding tags that need to be faded out, and adding them to fade array.
//------------------------------------------------------------------------------------

if (	!(WH_NT_FADE_TARGET isEqualTo objNull) &&
		{!(WH_NT_FADE_TARGET isEqualTo _cursorObject)} ) then
{
	if ( WH_NT_FADE_TARGET in WH_NT_FADE_NAMES ) then
	{
		private _index = WH_NT_FADE_NAMES find WH_NT_FADE_TARGET;

		WH_NT_FADE_NAMES deleteAt _index;
		WH_NT_FADE_STARTS deleteAt _index;
	};

	WH_NT_FADE_NAMES pushBack WH_NT_FADE_TARGET;
	WH_NT_FADE_STARTS pushBack time;
};

WH_NT_FADE_TARGET = _cursorObject;

//	Merging fade array with array of entities.
//{	_entities pushBackUnique _x} forEach WH_NT_FADE_NAMES;
//_entities append WH_NT_FADE_NAMES;
//	Add our newfound cursor object to the array of things to render nametags for.
_entities pushBackUnique _cursorObject;


//------------------------------------------------------------------------------------
//	Sorting entities.
//------------------------------------------------------------------------------------

//	Sort entities. Keep only the ones that are on the unit's side, or in their group,
//	and only if they are not the unit itself.
_entities = _entities select 	
{
	!(_x isEqualTo _player) &&
	{(
		side group _x isEqualTo side group _player 	// 0.0018ms
		//((side _x getFriend side _player) > 0.6) 		// 0.0024ms
		//|| {(group _x isEqualTo group _player)}
	)} 
};	


//------------------------------------------------------------------------------------
//	Loop through entities collected.
//------------------------------------------------------------------------------------
{
//	For every entity in the array...
	_alpha = if ( _x in WH_NT_FADE_NAMES )
	then { (((WH_NT_FADE_STARTS select (WH_NT_FADE_NAMES find _x)) + WH_NT_FADETIME) - time) / WH_NT_FADETIME }
	else { 1 };
	
	if ( _alpha <= 0 ) then
	{
		private _index = WH_NT_FADE_NAMES find _x;

		WH_NT_FADE_NAMES deleteAt _index;
		WH_NT_FADE_STARTS deleteAt _index;
	};
	
	//	....If the entity is a man...
	if ( _x isKindOf "Man" ) then 
	{
		//	Get the position of the man's upper spine.
		_targetPositionAGL = 
		if !(WH_NT_FONT_HEIGHT_ONHEAD) 
		then { _x modelToWorldVisual (_x selectionPosition "spine3") } 	// 0.0034ms
		else { _x modelToWorldVisual (_x selectionPosition "pilot")		// 0.0072ms
				vectorAdd [0,0,((0.2 + (((_player distance _x) * 1.5 * WH_NT_FONT_SPREAD_BOTTOM_MULTI)/_zoom)))] };

		_targetPositionASL = AGLtoASL _targetPositionAGL;
		
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
			if (_x isEqualTo _cursorObject || {_x in WH_NT_FADE_NAMES}) then
			{
				_alpha = linearConversion[(((WH_NT_DRAWDISTANCE_CURSOR)*(_zoom))/1.3),
				(WH_NT_DRAWDISTANCE_CURSOR*_zoom),(((_cameraPositionAGL distance _targetPositionAGL) / WH_NT_VAR_NIGHT)),1,0,true] * _alpha;
				
				[_cameraPositionAGL,(group _x isEqualTo group _player),_x,_targetPositionAGL,_alpha,_zoom,""] call wh_nt_fnc_nametagDrawCursor;
			}
			else
			{
				_alpha = linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,
				((_cameraPositionAGL distance _targetPositionAGL) / WH_NT_VAR_NIGHT),1,0,true];
				
				[(group _x isEqualTo group _player),_x,_targetPositionAGL,_alpha,""] call wh_nt_fnc_nametagDrawNear;
			};
		};
	}
	else 
	{
		//	Otherwise (if the entity is a vehicle)...

		//	Save the a variable reference to the vehicle for later.
		private _vehicle = _x;
		
		private _isCursor = 
			( (WH_NT_VAR_INVEHICLE && _vehicle isEqualTo vehicle _player) ||
			({_vehicle in WH_NT_FADE_NAMES}) ||
			({_vehicle isEqualTo _cursorObject}) );
		
		//	For every crew in the vehicle that's not the player...
		{
			//	The target's position is his real position.
			_targetPositionAGL = ASLtoAGL (getPosASLVisual _x) vectorAdd [0,0,(0.4)];

			//	...If they are on-screen...
			if ( !(worldToScreen _targetPositionAGL isEqualTo []) ) then
			{
				//	Check if the player and target are in the same group.
				private _sameGroup = (group _x isEqualTo group _player);
				
				// Get the distance from player to target.
				private _distance = _cameraPositionAGL distance _targetPositionAGL;
				
				//	Get the crew's role, if present.
				private _role = call
				{
					if ( commander	_vehicle isEqualTo _x ) exitWith {"Commander"};
					if ( gunner		_vehicle isEqualTo _x ) exitWith {"Gunner"};
					if ( !(driver	_vehicle isEqualTo _x)) exitWith {""};
					if ( driver		_vehicle isEqualTo _x && {!(_vehicle isKindOf "helicopter") && {!(_vehicle isKindOf "plane")}} ) exitWith {"Driver"};
					if ( driver		_vehicle isEqualTo _x && { (_vehicle isKindOf "helicopter") || { (_vehicle isKindOf "plane")}} ) exitWith {"Pilot"};
					""
				};

				//	Only display the driver, commander, and members of the players group unless the player is up close.
				if (effectiveCommander _vehicle isEqualTo _x || {(_distance <= WH_NT_DRAWDISTANCE_NEAR)}) then
				{
					//	If the unit is the commander, pass the vehicle he's driving and draw the tag.
					if (effectiveCommander _vehicle isEqualTo _x) then 
					{
						if _isCursor then
						{
							//	Get the vehicle's friendly name from configs.
							private _vehicleName = format ["%1",getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayname")];
							
							//	Get the maximum number of (passenger) seats from configs.
							private _maxSlots = getNumber(configfile >> "CfgVehicles" >> typeof _vehicle >> "transportSoldier") + (count allTurrets [_vehicle, true] - count allTurrets _vehicle);
							
							//	Get the number of empty seats.
							private _freeSlots = _vehicle emptyPositions "cargo";

							//	If meaningful, append vehicle name.
							if !(_vehicleName isEqualTo "") then
							{ _role = format ["%1 %2",_vehicleName,_role]};
							
							//	If meaningful, append some info on seats onto the vehicle info.
							if (_maxSlots > 0) then 
							{ _role = format["%1 [%2/%3]",_role,(_maxSlots-_freeSlots),_maxSlots]; };
	
							_alpha = linearConversion[(((WH_NT_DRAWDISTANCE_CURSOR)*(_zoom))/1.3),
							(WH_NT_DRAWDISTANCE_CURSOR*_zoom),((_distance / WH_NT_VAR_NIGHT)),1,0,true] * _alpha;
							
							[_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_alpha,_zoom,_role] call wh_nt_fnc_nametagDrawCursor;
						}
						else
						{
							_alpha = linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,
							(_distance / WH_NT_VAR_NIGHT),1,0,true];
							
							[_sameGroup,_x,_targetPositionAGL,_alpha,_role] call wh_nt_fnc_nametagDrawNear;
						};
					}
					else
					{
						//	If the unit is the driver but not the commander, or far enough from the driver that the tags will not overlap each other, draw the tags on them normally.
						if (driver _vehicle isEqualTo _x || {_targetPositionAGL distance (ASLToAGL getPosASLVisual(driver _vehicle)) > 0.5}) then
						{
							if (driver _vehicle isEqualTo _x || {gunner _vehicle isEqualTo _x}) then
							{
								if _isCursor then
								{
									_alpha = linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,
									(_distance / WH_NT_VAR_NIGHT),1,0,true] * _alpha;
									
									[_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_alpha,_zoom,_role] call wh_nt_fnc_nametagDrawCursor;
								}
								else
								{
									_alpha = linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,
									(_distance / WH_NT_VAR_NIGHT),1,0,true];
									
									[_sameGroup,_x,_targetPositionAGL,_alpha,_role] call wh_nt_fnc_nametagDrawNear;
								};
							}
							else
							{
								//	This case is for passengers.
								//	Check if the passenger is occluded before drawing the tag.
								if (lineIntersectsSurfaces [_cameraPositionASL, eyePos _x, _player, _x] isEqualTo []) then
								{
									_alpha = linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,(_distance / WH_NT_VAR_NIGHT),1,0,true];
									
									[_sameGroup,_x,_targetPositionAGL,_alpha,_role] call wh_nt_fnc_nametagDrawNear;
								};
							};
						}
						else
						{
							//	If the unit is in a gunner slot and not the commander, display the tag at the gun's position.
							if(_x isEqualTo gunner _vehicle) then
							{
								_targetPositionAGL = [_vehicle modeltoworld (_vehicle selectionPosition "gunnerview") select 0,_vehicle modeltoworld (_vehicle selectionPosition "gunnerview") select 1,(_targetPositionAGL) select 2];
								
								if _isCursor then
								{
									_alpha = linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,
									(_distance / WH_NT_VAR_NIGHT),1,0,true] * _alpha;
									
									[_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_alpha,_zoom,_role] call wh_nt_fnc_nametagDrawCursor;
								}
								else
								{
									_alpha = linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,
									(_distance / WH_NT_VAR_NIGHT),1,0,true];
									
									[_sameGroup,_x,_targetPositionAGL,_alpha,_role] call wh_nt_fnc_nametagDrawNear;
								};
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

/*
//------------------------------------------------------------------------------------
//	Ongoing tag fader.
//------------------------------------------------------------------------------------

{
	private _startTime =	_args select 0;
	private _player = 		_args select 1;
	private _target = 		_args select 2;
				
	if ((time) > (_startTime + WH_NT_FADETIME)) then
	{
		_handle call CBA_fnc_removePerFrameHandler;
		
		private _index = WH_NT_FADE_NAMES find _target;
		WH_NT_FADE_IDS deleteAt _index;
		WH_NT_FADE_NAMES deleteAt _index;
		WH_NT_FADE_STARTS deleteAt _index;
	}
	else
	{
		private _cameraPositionAGL = positionCameraToWorld[0,0,0];
		private _cameraPositionASL = AGLtoASL _cameraPositionAGL;

		private _targetPositionAGL;
		private _targetPositionASL;
		private _alpha;
		
		private _zoom = call wh_nt_fnc_getZoom;

		private _alphaCoef = ((_startTime + WH_NT_FADETIME) - time) / WH_NT_FADETIME;
		
		if( _target isKindOf "Man" ) then 
		{
			//	Get the position of the man's upper spine.
			_targetPositionAGL = 
			if !(WH_NT_FONT_HEIGHT_ONHEAD) 
			then { _target modelToWorldVisual (_target selectionPosition "spine3") } 	// 0.0034ms
			else { _target modelToWorldVisual (_target selectionPosition "pilot")		// 0.0072ms
					vectorAdd [0,0,((0.2 + (((_player distance _target) * 1.5 * WH_NT_FONT_SPREAD_BOTTOM_MULTI)/_zoom)))] };

			_targetPositionASL = AGLtoASL _targetPositionAGL;
			
			if ( lineIntersectsSurfaces [_cameraPositionASL, _targetPositionASL, _player, _target] isEqualTo [] ) then
			{
				_alpha = (linearConversion[(((WH_NT_DRAWDISTANCE_CURSOR)*(_zoom))/1.3),
				(WH_NT_DRAWDISTANCE_CURSOR*_zoom),(((_cameraPositionAGL distance _targetPositionAGL) / WH_NT_VAR_NIGHT)),1,0,true])* _alphaCoef;
				
				[_cameraPositionAGL,(group _target isEqualTo group _player),_target,_targetPositionAGL,_alpha,_zoom,""] call wh_nt_fnc_nametagDrawCursor;
			};
		}
		else
		{
			//	Otherwise (if the entity is a vehicle)...

			//	Save the a variable reference to the vehicle for later.
			private _vehicle = _target;
			
			private _isCursor = 
			if ( WH_NT_VAR_INVEHICLE && {(_vehicle isEqualTo vehicle _player)} )
			then { true }
			else {(_vehicle isEqualTo _cursorObject)};
			
			//	For every crew in the vehicle that's not the player...
			{
				//	The target's position is his real position.
				_targetPositionAGL = ASLtoAGL (getPosASLVisual _x) vectorAdd [0,0,(0.4)];

				//	...If they are on-screen...
				if ( !(worldToScreen _targetPositionAGL isEqualTo []) ) then
				{
					//	Check if the player and target are in the same group.
					private _sameGroup = (group _x isEqualTo group _player);
					
					// Get the distance from player to target.
					private _distance = _cameraPositionAGL distance _targetPositionAGL;
					
					//	Get the crew's role, if present.
					private _role = call
					{
						if ( commander	_vehicle isEqualTo _x ) exitWith {"Commander"};
						if ( gunner		_vehicle isEqualTo _x ) exitWith {"Gunner"};
						if ( !(driver	_vehicle isEqualTo _x)) exitWith {""};
						if ( driver		_vehicle isEqualTo _x && {!(_vehicle isKindOf "helicopter") && {!(_vehicle isKindOf "plane")}} ) exitWith {"Driver"};
						if ( driver		_vehicle isEqualTo _x && { (_vehicle isKindOf "helicopter") || { (_vehicle isKindOf "plane")}} ) exitWith {"Pilot"};
						""
					};

					//	Only display the driver, commander, and members of the players group unless the player is up close.
					if (effectiveCommander _vehicle isEqualTo _x || {(_distance <= WH_NT_DRAWDISTANCE_NEAR)}) then
					{
						//	If the unit is the commander, pass the vehicle he's driving and draw the tag.
						if (effectiveCommander _vehicle isEqualTo _x) then 
						{
							//	Get the vehicle's friendly name from configs.
							private _vehicleName = format ["%1",getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayname")];
							
							//	Get the maximum number of (passenger) seats from configs.
							private _maxSlots = getNumber(configfile >> "CfgVehicles" >> typeof _vehicle >> "transportSoldier") + (count allTurrets [_vehicle, true] - count allTurrets _vehicle);
							
							//	Get the number of empty seats.
							private _freeSlots = _vehicle emptyPositions "cargo";
							
							//	If meaningful, append vehicle name.
							if !(_vehicleName isEqualTo "") then
							{ _role = format ["%1 %2",_vehicleName,_role]};
							
							//	If meaningful, append some info on seats onto the vehicle info.
							if (_maxSlots > 0) then 
							{ _role = format["%1 [%2/%3]",_role,(_maxSlots-_freeSlots),_maxSlots]; };
	
							_alpha = (linearConversion[(((WH_NT_DRAWDISTANCE_CURSOR)*(_zoom))/1.3),
							(WH_NT_DRAWDISTANCE_CURSOR*_zoom),((_distance / WH_NT_VAR_NIGHT)),1,0,true]) * _alphaCoef;
							
							[_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_alpha,_zoom,_role] call wh_nt_fnc_nametagDrawCursor;
						}
						else
						{
							//	If the unit is the driver but not the commander, or far enough from the driver that the tags will not overlap each other, draw the tags on them normally.
							if (driver _vehicle isEqualTo _x || {_targetPositionAGL distance (ASLToAGL getPosASLVisual(driver _vehicle)) > 0.5}) then
							{
								if (driver _vehicle isEqualTo _x || {gunner _vehicle isEqualTo _x}) then
								{
									_alpha = (linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,(_distance / WH_NT_VAR_NIGHT),1,0,true]) * _alphaCoef;
									
									[_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_alpha,_zoom,_role] call wh_nt_fnc_nametagDrawCursor;
								};
							}
							else
							{
								//	If the unit is in a gunner slot and not the commander, display the tag at the gun's position.
								if(_x isEqualTo gunner _vehicle) then
								{
									_targetPositionAGL = [_vehicle modeltoworld (_vehicle selectionPosition "gunnerview") select 0,_vehicle modeltoworld (_vehicle selectionPosition "gunnerview") select 1,(_targetPositionAGL) select 2];
									
									if _isCursor then
									{
										_alpha = (linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,(_distance / WH_NT_VAR_NIGHT),1,0,true]) * _alphaCoef;
										
										[_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_alpha,_zoom,_role] call wh_nt_fnc_nametagDrawCursor;
									};
								};
							};
						};
					};
				};
			} forEach (crew _vehicle select {!(_x isEqualTo _player)});
		};
	};
} forEach WH_NT_FADE_NAMES;
*/