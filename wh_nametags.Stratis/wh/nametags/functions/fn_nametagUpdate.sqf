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
private _alphaCoef;
private _index;
private _target;
private _data;
private _nameColor;
private _role;


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

private _entities =+ WH_NT_CACHE_ENTS;
//if !WH_NT_DRAWCURSORONLY then
//{ _player nearEntities [["CAManBase","LandVehicle","Helicopter","Plane","Ship_F"], //(WH_NT_DRAWDISTANCE_NEAR*WH_NT_VAR_NIGHT)] } // _cameraPositionAGL
//else { [] };


//------------------------------------------------------------------------------------
//	Collect cursorObject or cursorTarget depending on player mounted state.
//------------------------------------------------------------------------------------

private _cursorObject = 
if !WH_NT_VAR_INVEHICLE then
{
	if ( (_player distance cursorTarget) <= (((WH_NT_DRAWDISTANCE_CURSOR) * WH_NT_VAR_NIGHT) * _zoom) &&
		{(side group cursorTarget isEqualTo side group _player)} ) 
	then { cursorTarget }
	else { objNull };
}
//	If the player is in a vehicle, use cursorObject.
//	cursorObject can look through windows.
else
{
	if ((_player distance cursorObject) <= (((WH_NT_DRAWDISTANCE_CURSOR) * WH_NT_VAR_NIGHT) * _zoom) &&
		{(side group cursorObject isEqualTo side group _player)} )
	then { cursorObject }
	else { objNull }; // nil?
};

_entities pushBackUnique _cursorObject;


//------------------------------------------------------------------------------------
//	Add cursorObject to cache if not already present.
//------------------------------------------------------------------------------------



//------------------------------------------------------------------------------------
//	Loop through entities collected.
//------------------------------------------------------------------------------------
{
//	For every entity in the array...

	//	....If the entity is a man...
	if( _x isKindOf "Man" ) then 
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
			if (_x isEqualTo _cursorObject) then
			{
				_alpha = linearConversion[(((WH_NT_DRAWDISTANCE_CURSOR)*(_zoom))/1.3),
				(WH_NT_DRAWDISTANCE_CURSOR*_zoom),(((_cameraPositionAGL distance _targetPositionAGL) / WH_NT_VAR_NIGHT)),1,0,true];
				
				[_cameraPositionAGL,(group _x isEqualTo group _player),_x,_targetPositionAGL,_alpha,_zoom,""] call wh_nt_fnc_nametagDrawCursor;
			}
			else
			{
				_data = WH_NT_CACHE_DATA select (WH_NT_CACHE_NAMES find _x);
				
				_alpha = linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,
				((_cameraPositionAGL distance _targetPositionAGL) / WH_NT_VAR_NIGHT),1,0,true];
				
				_nameColor =+ ( _data select 1 );
				_nameColor set [3, (_nameColor select 3) * _alpha];	
				
				drawIcon3D ["", _nameColor, _targetPositionAGL, 0, 0, 0, (_data select 0),WH_NT_FONT_SHADOW,WH_NT_FONT_SIZE_MAIN,WH_NT_FONT_FACE_MAIN];
			};
		};
	}
	else 
	{
		//	Otherwise (if the entity is a vehicle)...

		//	Save the a variable reference to the vehicle for later.
		private _vehicle = _x;
		
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
				_role = if _isCursor then
				{
					call
					{
						if ( commander	_vehicle isEqualTo _x ) exitWith {"Commander"};
						if ( gunner		_vehicle isEqualTo _x ) exitWith {"Gunner"};
						if ( !(driver	_vehicle isEqualTo _x)) exitWith {""};
						if ( driver		_vehicle isEqualTo _x && {!(_vehicle isKindOf "helicopter") && {!(_vehicle isKindOf "plane")}} ) exitWith {"Driver"};
						if ( driver		_vehicle isEqualTo _x && { (_vehicle isKindOf "helicopter") || { (_vehicle isKindOf "plane")}} ) exitWith {"Pilot"};
						""
					};
				}
				else { "" };


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
							(WH_NT_DRAWDISTANCE_CURSOR*_zoom),((_distance / WH_NT_VAR_NIGHT)),1,0,true];
							
							[_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_alpha,_zoom,_role] call wh_nt_fnc_nametagDrawCursor;
						}
						else
						{
							_data = WH_NT_CACHE_DATA select (WH_NT_CACHE_NAMES find _x);
							
							_alpha = linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,
							((_cameraPositionAGL distance _targetPositionAGL) / WH_NT_VAR_NIGHT),1,0,true];
							
							_nameColor =+ ( _data select 1 );
							_nameColor set [3, (_nameColor select 3) * _alpha];
							
							_role = ( _data select 2 );
							
							diag_log "NAME";
							diag_log (_data select 0);
							
							diag_log "-------------- DATA --------------";
							diag_log _data;
							
							drawIcon3D ["", _nameColor, _targetPositionAGL, 0, 0, 0, (_data select 0),WH_NT_FONT_SHADOW,WH_NT_FONT_SIZE_MAIN,WH_NT_FONT_FACE_MAIN];
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
									(_distance / WH_NT_VAR_NIGHT),1,0,true];
									
									[_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_alpha,_zoom,_role] call wh_nt_fnc_nametagDrawCursor;
								}
								else
								{
									_data = WH_NT_CACHE_DATA select (WH_NT_CACHE_NAMES find _x);
					
									_alpha = linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,
									((_cameraPositionAGL distance _targetPositionAGL) / WH_NT_VAR_NIGHT),1,0,true];
									
									_nameColor =+ ( _data select 1 );
									_nameColor set [3, (_nameColor select 3) * _alpha];
									
									_role = ( _data select 2 );
									
									drawIcon3D ["", _nameColor, _targetPositionAGL, 0, 0, 0, (_data select 0),WH_NT_FONT_SHADOW,WH_NT_FONT_SIZE_MAIN,WH_NT_FONT_FACE_MAIN];
								};
							}
							else
							{
								//	This case is for passengers.
								//	Check if the passenger is occluded before drawing the tag.
								if (lineIntersectsSurfaces [_cameraPositionASL, eyePos _x, _player, _x] isEqualTo []) then
								{
									_data = WH_NT_CACHE_DATA select (WH_NT_CACHE_NAMES find _x);
					
									_alpha = linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,
									((_cameraPositionAGL distance _targetPositionAGL) / WH_NT_VAR_NIGHT),1,0,true];
									
									_nameColor =+ ( _data select 1 );
									_nameColor set [3, (_nameColor select 3) * _alpha];
									
									_role = ( _data select 2 );
					
									drawIcon3D ["", _nameColor, _targetPositionAGL, 0, 0, 0, (_data select 0),WH_NT_FONT_SHADOW,WH_NT_FONT_SIZE_MAIN,WH_NT_FONT_FACE_MAIN];
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
									(_distance / WH_NT_VAR_NIGHT),1,0,true];
									
									[_cameraPositionAGL,_sameGroup,_x,_targetPositionAGL,_alpha,_zoom,_role] call wh_nt_fnc_nametagDrawCursor;
								}
								else
								{
									_data = WH_NT_CACHE_DATA select (WH_NT_CACHE_NAMES find _x);
					
									_alpha = linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,
									((_cameraPositionAGL distance _targetPositionAGL) / WH_NT_VAR_NIGHT),1,0,true];
									
									_nameColor =+ ( _data select 1 );
									_nameColor set [3, (_nameColor select 3) * _alpha];
									
									_role = ( _data select 2 );
									
									drawIcon3D ["", _nameColor, _targetPositionAGL, 0, 0, 0, (_data select 0),WH_NT_FONT_SHADOW,WH_NT_FONT_SIZE_MAIN,WH_NT_FONT_FACE_MAIN];
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
} forEach _entities;

/*
//------------------------------------------------------------------------------------
//	Adding tags to the fading system.
//------------------------------------------------------------------------------------

if (	!(WH_NT_FADE_TARGET isEqualTo objNull) &&
		{!(WH_NT_FADE_TARGET isEqualTo _cursorObject)} &&
		{(side group WH_NT_FADE_TARGET isEqualTo side group player)}) then
{
	_target = WH_NT_FADE_TARGET;
	
	if ( _target in WH_NT_FADE_NAMES ) then
	{
		_index = WH_NT_FADE_NAMES find _target;
		//private _loopID = WH_NT_FADE_IDS deleteAt _index;
		
		//_loopID call CBA_fnc_removePerFrameHandler;
		WH_NT_FADE_NAMES deleteAt _index;
		WH_NT_FADE_DATA  deleteAt _index;
		
	};
	
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
			(WH_NT_DRAWDISTANCE_CURSOR*_zoom),(((_cameraPositionAGL distance _targetPositionAGL) / WH_NT_VAR_NIGHT)),1,0,true]);
			
			//--------------------------------------------------------------------------------
			//	Find and set nametag color and target role.
			//--------------------------------------------------------------------------------

			//	Define the default color of the nametag...
			//	Note: the "+" before assignment is mandatory in SQF
			//		for assigning arrays. If I just used a "=",
			//		it would make a reference instead of a copy.

			private _color = + WH_NT_FONT_COLOR_OTHER;
			private _nameColor = + WH_NT_FONT_COLOR_DEFAULT;

			//	...For normal people...
			if (_role isEqualTo "") then 							
			{
				//	Grab the variable set in F3 AssignGear, if present.
				//	If it's not there, grab the possibly-ugly name from configs.
				_role = (_target getVariable ["f_var_assignGear_friendly",
						getText (configFile >> "CfgVehicles" >> typeOf _target >> "displayname")]);
			}
			//	...and for vehicle crew, where a role is already present.
			else { _nameColor = + WH_NT_FONT_COLOR_CREW };

			//	For units in the same group as the player, set their color according to color team.
			if (_sameGroup) then 
			{ 
				private _team = assignedTeam _target;
				_nameColor = switch (_team) do 
				{
					case "RED": 	{	+WH_NT_FONT_COLOR_GROUPR	};
					case "GREEN": 	{	+WH_NT_FONT_COLOR_GROUPG	};
					case "BLUE": 	{	+WH_NT_FONT_COLOR_GROUPB	};
					case "YELLOW": 	{	+WH_NT_FONT_COLOR_GROUPY	};
					default			{	+WH_NT_FONT_COLOR_GROUP		};
				};
				
				//	For colorblind mode, replace the colors with group strings.
				if (WH_NT_FONT_COLORBLIND && {WH_NT_SHOW_GROUP}) then
				{
					_groupName = switch (_team) do 
					{
						case "RED": 	{ "Team Red" 	};
						case "GREEN": 	{ "Team Green" 	};
						case "BLUE": 	{ "Team Blue" 	};
						case "YELLOW": 	{ "Team Yellow"	};
						default  		{};
					};
				};
			};

			//	If they're running colorblind, reset the nameColor to a nice white one.
			if (WH_NT_FONT_COLORBLIND) then { _nameColor = + WH_NT_FONT_COLOR_OTHER };

			_data = [time, (group _target isEqualTo group _player), _target, _alpha, ""];
			
			WH_NT_FADE_NAMES pushBack _target;
			WH_NT_FADE_DATA  pushBack _data;
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
			_targetPositionAGL = ASLtoAGL (getPosASLVisual _target) vectorAdd [0,0,(0.4)];

			//	...If they are on-screen...
			if ( !(worldToScreen _targetPositionAGL isEqualTo []) ) then
			{
				//	Check if the player and target are in the same group.
				private _sameGroup = (group _target isEqualTo group _player);
				
				// Get the distance from player to target.
				private _distance = _cameraPositionAGL distance _targetPositionAGL;
				
				//	Get the crew's role, if present.
				private _role = call
				{
					if ( commander	_vehicle isEqualTo _target ) exitWith {"Commander"};
					if ( gunner		_vehicle isEqualTo _target ) exitWith {"Gunner"};
					if ( !(driver	_vehicle isEqualTo _target)) exitWith {""};
					if ( driver		_vehicle isEqualTo _target && {!(_vehicle isKindOf "helicopter") && {!(_vehicle isKindOf "plane")}} ) exitWith {"Driver"};
					if ( driver		_vehicle isEqualTo _target && { (_vehicle isKindOf "helicopter") || { (_vehicle isKindOf "plane")}} ) exitWith {"Pilot"};
					""
				};

				//	Only display the driver, commander, and members of the players group unless the player is up close.
				if (effectiveCommander _vehicle isEqualTo _target || {(_distance <= WH_NT_DRAWDISTANCE_NEAR)}) then
				{
					//	If the unit is the commander, pass the vehicle he's driving and draw the tag.
					if (effectiveCommander _vehicle isEqualTo _target) then 
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
						(WH_NT_DRAWDISTANCE_CURSOR*_zoom),((_distance / WH_NT_VAR_NIGHT)),1,0,true]);
						
						_data = [time, _sameGroup, _target, _alpha, _role];
						
						WH_NT_FADE_NAMES pushBack _target;
						WH_NT_FADE_DATA  pushBack _data;
					}
					else
					{
						//	If the unit is the driver but not the commander, or far enough from the driver that the tags will not overlap each other, draw the tags on them normally.
						if (driver _vehicle isEqualTo _target || {_targetPositionAGL distance (ASLToAGL getPosASLVisual(driver _vehicle)) > 0.5}) then
						{
							if (driver _vehicle isEqualTo _target || {gunner _vehicle isEqualTo _target}) then
							{
								_alpha = (linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,(_distance / WH_NT_VAR_NIGHT),1,0,true]);
								
								_data = [time, _sameGroup, _target, _alpha, _role];
								
								WH_NT_FADE_NAMES pushBack _target;
								WH_NT_FADE_DATA  pushBack _data;
							};
						}
						else
						{
							//	If the unit is in a gunner slot and not the commander, display the tag at the gun's position.
							if(_target isEqualTo gunner _vehicle) then
							{
								_targetPositionAGL = [_vehicle modeltoworld (_vehicle selectionPosition "gunnerview") select 0,_vehicle modeltoworld (_vehicle selectionPosition "gunnerview") select 1,(_targetPositionAGL) select 2];
								
								if _isCursor then
								{
									_alpha = (linearConversion[WH_NT_DRAWDISTANCE_NEAR/1.3,WH_NT_DRAWDISTANCE_NEAR,(_distance / WH_NT_VAR_NIGHT),1,0,true]);
									
									_data = [time, _sameGroup, _target, _alpha, _role];
									WH_NT_FADE_NAMES pushBack _target;
									WH_NT_FADE_DATA  pushBack _data;
								};
							};
						};
					};
				};
			};
		} forEach (crew _vehicle select {!(_x isEqualTo _player)});
	};
};


//------------------------------------------------------------------------------------
//	Fading previous target tags.
//------------------------------------------------------------------------------------

private _startTime;

{
	_data =+ WH_NT_FADE_DATA select _forEachIndex;
	_startTime = _data deleteAt 0;
				
	if ((time) > (_startTime + WH_NT_FADETIME)) then
	{
		private _index = WH_NT_FADE_NAMES find _x;
		WH_NT_FADE_DATA  deleteAt _index;
		WH_NT_FADE_NAMES deleteAt _index;
	}
	else
	{
		_data set [4,((_data select 5)*(((_startTime + WH_NT_FADETIME) - time) / WH_NT_FADETIME))];
		_data call wh_nt_fnc_nametagDrawCursor;
	};
} forEach WH_NT_FADE_NAMES;
	
WH_NT_FADE_TARGET = _cursorObject;*/