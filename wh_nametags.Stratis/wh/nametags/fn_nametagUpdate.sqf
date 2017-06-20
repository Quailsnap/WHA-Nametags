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
private _pos;
private _dist;
private _veh;
private _i;
private _role;
private _vehS;
private _angle;
private _noRG;

// Find player camera's position. Allows this script to work with 3PP.
private _ppos = if (cameraView isEqualTo "EXTERNAL")
then { positionCameraToWorld[0,0,0] } else { getPosATL player };

// If in normal vision, ranges reduce from darkness. Nightvision helps to counter this, but not perfectly. (FROM SHACKTAC NAMETAGS)
private _range = 
if ( WH_NT_NIGHT && {!(sunOrMoon isEqualTo 1)}) then 
{
	if (currentVisionMode player isEqualTo 0) then
	{	linearConversion [0, 1, sunOrMoon, 0.25,1,true];	}
	else
	{	linearConversion [0, 1, sunOrMoon, 0.75,1,true];	};
}
else { 1 };

// Get fov, which will be used to adjust spacing and size of text.
private _fov = if ( WH_NT_DRAWDISTANCE_FOV ) then 
{	(call wh_nt_fnc_getZoom);	}
else { 1 };

// Establish entities array.
private _ents = [];

// Unless disabled, collect all entities in the relevant distance.
if !(WH_NT_DRAWCURSORONLY) then
{ _ents = (_ppos) nearEntities [["CAManBase","LandVehicle","Helicopter","Plane","Ship_F"], (WH_NT_DRAWDISTANCE_ALL*_range)]; };

// Even if disabled, make sure cursortarget is in the entity array.
if (vehicle player isEqualTo player) then
{
	if 
	(
		!(cursorTarget in _ents) && 
		{(_ppos distance cursorTarget) <= (((WH_NT_DRAWDISTANCE_ONE) * _range) * _fov)}
	) then {_ents append [cursorTarget]};
}
else
{
	if 
	(
		!(cursorObject in _ents) && 
		{(_ppos distance cursorObject) <= (((WH_NT_DRAWDISTANCE_ONE) * _range) * _fov)}
	) then {_ents append [cursorObject]};
};

// Loop through all the entities collected.
{
	// Filter entities.
	if 
	(	// Only other entities...
		_x != player &&
		// ...and only if they're on the same side, or in the same group.
		{(side _x isEqualTo side player) || {(group _x isEqualTo group player) || {(side _x isEqualTo civilian)}}}
		 //&& !(player iskindof "VirtualMan_F")}
	)
	then
	{
		// If the entity is a man, draw a nametag for it.
		if((typeof _x) iskindof "Man") then
		{
			_pos  = getPosATLVisual _x;
			_dist = _pos distance _ppos;
			[_x,_pos,_fov,_dist,_range] call wh_nt_fnc_nametagDraw;
		}
		
		// Otherwise (if it's a vehicle)...
		else
		{
			if ( WH_NT_SHOW_INVEHICLE ) then
			{
				_veh = _x;
				_i = 1;
				
				_noRG = if ( _veh isEqualTo vehicle player && {((speed (vehicle player)) > 30)})
				then { true } else { false };
				
				// ...For every crew in the vehicle that's not the player...
				{
					_role = call
					{
						if ( commander _veh isEqualTo _x ) exitWith {"Commander"};
						if ( gunner	   _veh isEqualTo _x ) exitWith {"Gunner"};
						if ( !(driver  _veh isEqualTo _x)) exitWith {""};
						if ( driver	   _veh isEqualTo _x && {!(_veh isKindOf "helicopter") && {!(_veh isKindOf "plane")}} ) exitWith {"Driver"};
						if ( driver	   _veh isEqualTo _x && {(_veh isKindOf "helicopter") || {(_veh isKindOf "plane")}} ) exitWith {"Pilot"};
						""
					};
					
					_pos  = getPosATLVisual _x;
					_dist = _pos distance _ppos;

					// Only display the driver, commander, and members of the players group unless the player is up close.
					if (effectiveCommander _veh isEqualTo _x || {group _x isEqualTo group player || {_dist <= WH_NT_DRAWDISTANCE_ALL}}) then
					{	
						// If the unit is the commander, calculate the available and taken seats, and get the vehicle name.
						if (effectiveCommander _veh isEqualTo _x) then 
						{
							_vehS = format ["%1",getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayname")];
							_maxSlots = getNumber(configfile >> "CfgVehicles" >> typeof _veh >> "transportSoldier") + (count allTurrets [_veh, true] - count allTurrets _veh);
							_freeSlots = _veh emptyPositions "cargo";
							
							if (_maxSlots > 0) then 
							{	_vehS = _vehS + format[" [%1/%2]",(_maxSlots-_freeSlots),_maxSlots];	};
						
							[_x,_pos,_fov,_dist,_range,_role,_noRG,_vehS] call wh_nt_fnc_nametagDraw; 
						}
						else
						{
							if (_pos distance (getPosATLVisual (effectiveCommander _veh)) > 0.2) then
							{
								[_x,_pos,_fov,_dist,_range,_role,_noRG] call wh_nt_fnc_nametagDraw;
							}
							else
							{
								// If the unit is in a gunner slot and not the commander, display the tag at the gun's position.
								if(_x isEqualTo gunner _veh) then
								{
									_pos = [_veh modeltoworld (_veh selectionPosition "gunnerview") select 0,_veh modeltoworld (_veh selectionPosition "gunnerview") select 1,(getPosATLVisual _x) select 2];
								}
								else
								// Otherwise, display the tag above the vehicle.
								{
									_angle = (getdir _veh)+180;
									_pos = [((_pos select 0) + sin(_angle)*(0.6*_i)) , (_pos select 1) + cos(_angle)*(0.6*_i),_pos select 2 + WH_NT_FONT_HEIGHT_VEHICLE];
									_i = _i + 1;
								};

								[_x,_pos,_fov,_dist,_range,_role,_noRG] call wh_nt_fnc_nametagDraw;
							};
						};
					};
				} forEach (crew _veh select {!(_x isEqualTo player)});
			};
		};
	};
} count _ents;