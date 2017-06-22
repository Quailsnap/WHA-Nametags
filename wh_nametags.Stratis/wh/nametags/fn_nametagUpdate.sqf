// ====================================================================================
//
//	fn_nametagUpdate.sqf - Updates values for WH nametags (heavily based on F3 and ST)
//	> call wh_nt_fnc_nametagUpdate; <
//	@ /u/Whalen207 | Whale #5963
//
// ====================================================================================

// ------------------------------------------------------------------------------------
// Update sequence intended to be run each frame.
// ------------------------------------------------------------------------------------

// If the script is active...
if !(WH_NT_NAMETAGS_ON) exitWith {};

// Establish initial variables.
private _unit = player;

// Find player camera's position. Allows this script to work with 3PP.
private _playerPosition = if (cameraView isEqualTo "EXTERNAL")
then { positionCameraToWorld[0,0,0] } else { getPosVisual _unit };
//private _playerPosition = positionCameraToWorld[0,0,0];

// If in normal vision, ranges reduce from darkness. Nightvision helps to counter this, but not perfectly. (FROM SHACKTAC NAMETAGS)
private _range = 
if ( WH_NT_NIGHT && {!(sunOrMoon isEqualTo 1)}) then 
{
	if (currentVisionMode _unit isEqualTo 0) then
	{	linearConversion [0, 1, sunOrMoon, 0.25,1,true];	}
	else
	{	linearConversion [0, 1, sunOrMoon, 0.75,1,true];	};
}
else { 1 };

// Get fov, which will be used to adjust spacing and size of text.
private _fov = if ( WH_NT_DRAWDISTANCE_FOV ) then 
{	(call wh_nt_fnc_getZoom);	}
else { 1 };

// Establish _entities array.
private _entities = [];

// Unless disabled, collect all entities in the relevant distance.
if !(WH_NT_DRAWCURSORONLY) then
{ _entities = (_playerPosition) nearEntities [["CAManBase","LandVehicle","Helicopter","Plane","Ship_F"], (WH_NT_DRAWDISTANCE_ALL*_range)]; };

// Even if disabled, make sure cursortarget is in the entity array.
if (isNull objectParent _unit) then
{
	if ((_playerPosition distance cursorTarget) <= (((WH_NT_DRAWDISTANCE_ONE) * _range) * _fov))
	then { _entities pushBackUnique cursorTarget; };
}
else
{
	if ((_playerPosition distance cursorObject) <= (((WH_NT_DRAWDISTANCE_ONE) * _range) * _fov))
	then { _entities pushBackUnique cursorObject; };
};

// Loop through all the entities collected.
{
	// If the entity is a man, draw a nametag for it.
	if((typeof _x) iskindof "Man") then
	{
		private _targetPosition = getPosVisual _x;
		private _distance = _targetPosition distance _playerPosition;
		[_unit,_x,_targetPosition,_fov,_distance,_range] call wh_nt_fnc_nametagDraw;
	}
	
	// Otherwise (if it's a vehicle)...
	else
	{
		if ( WH_NT_SHOW_INVEHICLE ) then
		{
			private _vehicle = _x;
			private _i = 1;
			private _noRoleOrGroup = ( _vehicle isEqualTo vehicle _unit && {((speed (vehicle _unit)) > 30)});
			
			// ...For every crew in the vehicle that's not the player...
			{
				private _role = call
				{
					if ( commander _vehicle isEqualTo _x ) exitWith {"Commander"};
					if ( gunner	   _vehicle isEqualTo _x ) exitWith {"Gunner"};
					if ( !(driver  _vehicle isEqualTo _x)) exitWith {""};
					if ( driver	   _vehicle isEqualTo _x && {!(_vehicle isKindOf "helicopter") && {!(_vehicle isKindOf "plane")}} ) exitWith {"Driver"};
					if ( driver	   _vehicle isEqualTo _x && {(_vehicle isKindOf "helicopter") || {(_vehicle isKindOf "plane")}} ) exitWith {"Pilot"};
					""
				};

				private _targetPosition = getPosVisual _x;
				private _distance = _targetPosition distance _playerPosition;
				
				// Only display the driver, commander, and members of the players group unless the player is up close.
				if (effectiveCommander _vehicle isEqualTo _x || {group _x isEqualTo group _unit || {_distance <= WH_NT_DRAWDISTANCE_ALL}}) then
				{
					// If the unit is the commander, pass the vehicle he's driving.
					if (effectiveCommander _vehicle isEqualTo _x) then 
					{
						[_unit,_x,_targetPosition,_fov,_distance,_range,_role,_noRoleOrGroup,_vehicle] call wh_nt_fnc_nametagDraw; 
					}
					else
					{
						if (driver _vehicle isEqualTo _x || {_targetPosition distance (getPosVisual (driver _vehicle)) > 0.2}) then
						{
							[_unit,_x,_targetPosition,_fov,_distance,_range,_role,_noRoleOrGroup] call wh_nt_fnc_nametagDraw;
						}
						else
						{
							// If the unit is in a gunner slot and not the commander, display the tag at the gun's position.
							if(_x isEqualTo gunner _vehicle) then
							{
								_targetPosition = [_vehicle modeltoworld (_vehicle selectionPosition "gunnerview") select 0,_vehicle modeltoworld (_vehicle selectionPosition "gunnerview") select 1,(getPosVisual _x) select 2];
								_distance = _targetPosition distance _playerPosition;
							}
							else
							// Otherwise, display the tag above the vehicle.
							{
								private _angle = (getdir _vehicle)+180;
								_targetPosition = [((_targetPosition select 0) + sin(_angle)*(0.6*_i)) , ((_targetPosition select 1) + cos(_angle)*(0.6*_i)),((_targetPosition select 2) + (WH_NT_FONT_HEIGHT_VEHICLE*_i))];
								_i = _i + 1;
								_distance = _targetPosition distance _playerPosition;
							};

							[_unit,_x,_targetPosition,_fov,_distance,_range,_role,_noRoleOrGroup] call wh_nt_fnc_nametagDraw;
						};
					};
				};
			} forEach (crew _vehicle select {!(_x isEqualTo player)});
		};
	};
} count (_entities select {
		// Only other entities...
        _x != player &&
        // ...and only if they're on the same side, or in the same group.
        {(side _x isEqualTo side player) || {(group _x isEqualTo group player) || {(side _x isEqualTo civilian)}}}
		//&& !(_unit iskindof "VirtualMan_F")} <- Relic from a gentler age.
});