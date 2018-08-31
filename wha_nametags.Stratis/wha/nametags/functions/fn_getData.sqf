//====================================================================================
//
//	fn_getData.sqf - Collects data from units and queues them to be drawn.
//
//	> 	_data = [_player,_playerGroup,_cameraPositionAGL,_cameraPositionASL,_entities,
//		false] call wha_nametags_fnc_getData;	<
//
//		Returns [_names,_data].
//		Names is an array of references to units (CAManBase).
//		Data is nametag data, for each.
//
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Initializing variables.
//------------------------------------------------------------------------------------

params ["_player","_playerGroup","_cameraPositionAGL","_cameraPositionASL",
		"_entities","_isCursor"];

// _player (object CAManBase): Current player that will be rendering tags.
// _playerGroup: Group of said player.
// _cameraPositionAGL (positionAGL array [[],[],[]]): Current position of player camera.
// _cameraPositionASL (positionASL array [[],[],[]]): Current position of player camera.
// _entities (array of objects CAManBase or vehicle): Entities tags will be processed for.
// _isCursor (boolean): Flag signaling that said entities are under cursor.

		
//------------------------------------------------------------------------------------
//	Establishing arrays to be filled with unit names and unit data, respectively.
//------------------------------------------------------------------------------------

private _names= [];
private _data = [];

// TODO: Temporary fix for zoom not being in here.
private _zoom = 1;


//------------------------------------------------------------------------------------
//	Main loop. Fills above arrays with data for each entity in _entities.
//------------------------------------------------------------------------------------

//	For every entity in _entities...
{
	//	Store said entity. It may be a vehicle (with multiple people inside), and it
	//	may just be a single unit. We do not know, so we will just process data for
	//	each of the "vehicles" (or units) "crew" (or self).
	private _entity = _x;
	
	//	If entity is not null and not a UAV . . .
	if (! (isNil "_entity" || {_entity in allUnitsUAV} ) ) then // TODO: Find a better solution for this.
	{
		//	For each member of the entity's crew (which would just be the entity, if it's a unit...)
		{
			if ( !(isNil "_x" || {_x isEqualTo _player}) ) then
			{
				//	Reset variables used for each unit.
				private _locationData = {};
				private _role = "";
				private _show = false;
				private _drawRoleAndGroup = false;
				private _isCommander = false;
				private _isPassenger = false; // TODO : Find a smoother solution for this.
				
				//	If the unit is NOT in a vehicle...
				if ( isNull objectParent _x ) then
				{
					//	Get the data that will be processed (later) to determine where
					//	to draw the nametag. Either their chest, or above their head.
					_locationData = 
					if !WHA_NAMETAGS_FONT_HEIGHT_ONHEAD
					then { {_x modelToWorldVisual (_x selectionPosition "spine3")} }
					else { {_x modelToWorldVisual (_x selectionPosition "pilot")
							vectorAdd [0,0,((0.2 + (((_player distance _x) * 1.5 * 
							WHA_NAMETAGS_FONT_SPREAD_BOTTOM_MULTI)/_zoom)))]} };
					
					_isCommander = true;
					
					//	If the unit is NOT in a vehicle and NOT under the cursor...
					if !_isCursor then
					{
						//	Get the location of that unit...
						private _targetPositionAGL = call _locationData;
						private _targetPositionASL = AGLtoASL _targetPositionAGL;
						
						//	...and check...
						if
						(
							// ( If the man is within the boundaries of the screen )
							!(worldToScreen _targetPositionAGL isEqualTo []) &&
							// AND ( If the game can draw a line from the player to the man without hitting anything )
							{ lineIntersectsSurfaces [_cameraPositionASL, _targetPositionASL, _player, _x] isEqualTo [] }
						)
						//	If those criteria are met, let the system know that the tag will be shown.
						then { _show = true };
					}
					else
					{
						//	If the unit is NOT in a vehicle but IS under the cursor,
						//	show it, and let the system know that the role and group
						//	should be rendered.
						_show = true;
						_drawRoleAndGroup = true;
					};
				}
				
				//	Otherwise (if the unit IS in a vehicle)...
				else
				{
					//	The vehicle is the thing we're processing the crew for.
					private _vehicle = vehicle _x; //objectParent _x
					
					//	Depending on where the unit is in a vehicle, store it's 'role.'
					_role = call
					{
						if ( commander	_vehicle isEqualTo _x ) exitWith {"Commander"};
						if ( gunner		_vehicle isEqualTo _x ) exitWith {"Gunner"};
						if ( !(driver	_vehicle isEqualTo _x)) exitWith {""};
						if ( driver		_vehicle isEqualTo _x && {!(_vehicle isKindOf "helicopter") && {!(_vehicle isKindOf "plane")}} ) exitWith {"Driver"};
						if ( driver		_vehicle isEqualTo _x && { (_vehicle isKindOf "helicopter") || { (_vehicle isKindOf "plane")}} ) exitWith {"Pilot"};
						""
					};
					
					//	The location data is different for vehicles, since many vehicle
					//	positions do not work properly with modelToWorldVisual.
					_locationData =
					{ ASLtoAGL (getPosASLVisual _x) vectorAdd [0,0,(0.4)] };
					
					//	Use the above location data to get the unit's location.
					private _targetPositionAGL = call _locationData;
					private _targetPositionASL = AGLtoASL _targetPositionAGL;
					
					//	If the unit has a role (isn't a passenger) then...
					if !( _role isEqualTo "" ) then
					{
						//	...if it's effectively the commander of the vehicle...
						if ( effectiveCommander _vehicle isEqualTo _x ) then
						{
							//	...set a flag that lets the system know if a player has this
							//	vehicle under his cursor from far away, only this guy should
							//	be rendered.
							_isCommander = true;
							
							//	Also, if the missionmaker has configured vehicle information
							//	to be shown, store that for later.
							if WHA_NAMETAGS_SHOW_VEHICLEINFO then
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
							};
						};
						
						//	If the unit is the gunner and is uncomfortably close to the driver (many Arma APCs
						//	without interiors do this), then render the nametag where the turret is.
						if ( _role isEqualTo "Gunner" && {_targetPositionASL distance (getPosASLVisual(driver _vehicle)) < 0.5} ) then
						{
							_locationData =
							{ _vehicle modelToWorldVisual (_vehicle selectionPosition "gunnerview") };
						};
						
						//	If the unit's location is on-screen...
						if !(worldToScreen _targetPositionAGL isEqualTo []) then 
						{
							//	Then show it.
							_show = true; 
							
							//	If it's player's vehicle, or if it's under the cursor,
							//	then draw the role and group, too.
							if ( _vehicle isEqualTo vehicle _player || {_isCursor} ) then
							{ _drawRoleAndGroup = true };
						};
					}
					
					//	Otherwise (if it IS a passenger)...
					else
					{
						if
						(
							// ( If the man is within the boundaries of the screen )
							!( worldToScreen _targetPositionAGL isEqualTo [] ) &&
							// AND ( If the game can draw a line from the player to the man without hitting anything )
							{ lineIntersectsSurfaces [_cameraPositionASL, _targetPositionASL, _player, _x] isEqualTo [] } &&
							{ _targetPositionAGL distance (ASLToAGL getPosASLVisual(driver _vehicle)) > 0.5 }
						)
						then 
						{
							//	Don't draw the role and group no matter what.
							_isPassenger = true;
							_show = true;
						};
					}
				};
				
				//----------------------------------------------------------------------------
				//	If the tag's going to be shown, get and add the data.
				//----------------------------------------------------------------------------
				
				//	If it's shown...
				if _show then
				{
					//	Get the unit's name.
					private _name = name _x;
					if ( isNil "_name" || {_name == "Error: No unit"} )
					then { _name = "" };
					
					//	Default the unit's nametag color to the mission default.
					private _nameColor =+ WHA_NAMETAGS_FONT_COLOR_DEFAULT;
					
					//	Get the unit's group.
					private _unitGroup = group _x;
					
					//	If the unit is in the same group as the player,
					//	then erase the group tag. It does not need to be shown.
					private _sameGroup = ( _unitGroup isEqualTo _playerGroup );
					private _groupName = if !_sameGroup then { groupID _unitGroup } else { "" };

					//	...For normal people...
					if ( _role isEqualTo "" ) then 							
					{
						//	Grab the variable set in F3 AssignGear, if present.
						//	If it's not there, grab the possibly-ugly name from configs.
						_role = ( _x getVariable ["f_var_assignGear_friendly",
								getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayname")] );
					}
					//	...and for vehicle crew, where a role is already present.
					else { _nameColor =+ WHA_NAMETAGS_FONT_COLOR_CREW };

					//	For units in the same group as the player, set their color according to color team.
					if _sameGroup then 
					{
						_nameColor = switch ( assignedTeam _x ) do 
						{
							case "RED": 	{ +WHA_NAMETAGS_FONT_COLOR_GROUPR };
							case "GREEN": 	{ +WHA_NAMETAGS_FONT_COLOR_GROUPG };
							case "BLUE": 	{ +WHA_NAMETAGS_FONT_COLOR_GROUPB };
							case "YELLOW": 	{ +WHA_NAMETAGS_FONT_COLOR_GROUPY };
							default			{ +WHA_NAMETAGS_FONT_COLOR_GROUP };
						};
					};
						
					//	Huck all this data into an array...
					//	Implementation from shadow-fa, aka shado
					private _unitData = 
					[
						_x,
						_entity,
						_name,
						_nameColor,
						_locationData,
						_role,
						_groupName,
						_drawRoleAndGroup,
						_isPassenger,
						_isCommander
					];
					
					//	...Then add the unit's name to the name array...
					_names pushBack _x;
					
					// ...and the unit's data to the data array.
					_data append [_unitData];
				};
			};
		} forEach ( crew _entity );
	};
} count _entities;


//------------------------------------------------------------------------------------
//	Returns arrays of names and data for all valid entities.
//------------------------------------------------------------------------------------

[_names,_data]