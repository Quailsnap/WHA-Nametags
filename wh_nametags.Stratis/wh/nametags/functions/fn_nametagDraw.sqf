/// ====================================================================================
//
//	fn_nametagDraw.sqf - Initializes values for WH nametags (heavily based on F3 and ST)
//
//		[_x,_targetPositionAGL,_playerGroup,_cameraPositionAGL,_zoom,_range,_role,_noRoleOrGroup,_vehicle] call
//		wh_nt_fnc_nametagDraw;
//
//	@ /u/Whalen207 | Whale #5963
//
// ====================================================================================

// ------------------------------------------------------------------------------------
// Declare variables.
// ------------------------------------------------------------------------------------

params["_player","_cameraPositionAGL","_sameGroup","_target",
"_targetPositionAGL","_zoom","_role","_vehicle"];

// _x (Object CAManBase): Soldier the nametag will be rendered on.
// _targetPositionAGL (posAGL): Position the nametag will be rendered on.
// player (Object CAManBase): The player.
// _cameraPositionAGL (posAGL): Position of the player.
// _zoom (Number, max 1.7): Player's current zoom level.
// _range (Number, max 1): Range modifier depending on day/night cycles.
// _role (String): Target's role to be displayed at bottom.
// _vehicle (Object): If the player is looking at a vehicle -- that vehicle object.


// ------------------------------------------------------------------------------------
//	Initial setup.
// ------------------------------------------------------------------------------------

// If the unit is dead, shorten the range. 
private _name = if (alive _x) then { name _x } else { "Unknown" };
//	_range = _range * 0.5;

// Only show group if it's not the same group as the player.
private _groupName = if !(_sameGroup) then { groupID (group _target) } else { "" };


// ------------------------------------------------------------------------------------
//	Set and manage distance to target.
// ------------------------------------------------------------------------------------

// Set distance.
private _distance = _cameraPositionAGL distance _targetPositionAGL;

// Only show distance for units further than 3m away.
if (WH_NT_SHOW_DISTANCE && {_distance >= 3}) then 
{	_name = _name + format [" | %1m",round (_distance)];	};


// ------------------------------------------------------------------------------------
//	Find transparency of tag depending on distance and time of day.
// ------------------------------------------------------------------------------------

// Get the transparency using some stupidly complex function.
private _alpha =
// If the player is not in a vehicle...
if (WH_NT_VAR_PLAYER_INVEHICLE) then 
{ 
	// Use cursorTarget.
	if ( _x isEqualTo cursorTarget || {_x isEqualTo (effectiveCommander cursorTarget)} ) then 
	{ linearConversion[(((WH_NT_DRAWDISTANCE_ONE)*(_zoom))/2),(WH_NT_DRAWDISTANCE_ONE*_zoom),((_distance / WH_NT_VAR_NIGHT)/_zoom),1,0,true]; }
	else
	{ linearConversion[WH_NT_DRAWDISTANCE_ALL/2,WH_NT_DRAWDISTANCE_ALL,(_distance / WH_NT_VAR_NIGHT),1,0,true];};
}
// If the player is in a vehicle...
else 
{
	// Use cursorObject, which can see through windows better.
	if ( _x isEqualTo cursorObject || {_x isEqualTo (effectiveCommander cursorObject)} ) then 
	{ linearConversion[(((WH_NT_DRAWDISTANCE_ONE)*(_zoom))/2),(WH_NT_DRAWDISTANCE_ONE*_zoom),((_distance / WH_NT_VAR_NIGHT)/_zoom),1,0,true]; }
	else
	{ linearConversion[WH_NT_DRAWDISTANCE_ALL/2,WH_NT_DRAWDISTANCE_ALL,(_distance / WH_NT_VAR_NIGHT),1,0,true];};
};


// ------------------------------------------------------------------------------------
//	Find and set nametag color and target role.
// ------------------------------------------------------------------------------------

// Define the default color of the nametag...
private _color = + WH_NT_FONT_COLOR_OTHER;
private _nameColor = + WH_NT_FONT_COLOR_DEFAULT;

// ...For normal people...
if (_role isEqualTo "") then 							
{
	// Grab the variable set in F3 AssignGear, if present.
	// If it's not there, grab the possibly-ugly name from configs.
	_role = (_x getVariable ["f_var_assignGear_friendly",
			getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayname")]);
}
// ...and for vehicle crew, where a role is already present.
else { _nameColor = + WH_NT_FONT_COLOR_CREW };

// For units in the same group as the player, set their color according to color team.
if (_sameGroup) then 
{ 
	private _team = assignedTeam _x;
	_nameColor = switch (_team) do 
	{
		case "RED": 	{	+WH_NT_FONT_COLOR_GROUPR	};
		case "GREEN": 	{	+WH_NT_FONT_COLOR_GROUPG	};
		case "BLUE": 	{	+WH_NT_FONT_COLOR_GROUPB	};
		case "YELLOW": 	{	+WH_NT_FONT_COLOR_GROUPY	};
		default			{	+WH_NT_FONT_COLOR_GROUP		};
	};
	
	// For colorblind mode, replace the colors with group strings.
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

// If they're running colorblind, reset the nameColor to a nice white one.
if (WH_NT_FONT_COLORBLIND) then { _nameColor = + WH_NT_FONT_COLOR_OTHER };

// Apply the alpha coating to each color's transparency.
_color set [3, (_color select 3) * _alpha];
_nameColor set [3, (_nameColor select 3) * _alpha];


// ------------------------------------------------------------------------------------
//	Use space magic to realign the tags with the player's view.
//	IE: If the player is above the target, normally the nametags (which are stacked -
//	- vertically) would appear scrunched inside one another.
//	This alleviates this by realigning them horizontally.
//
//	Special thanks to cptnnick for this idea, code, implementation, everything!
// ------------------------------------------------------------------------------------

private _vectorDir = _cameraPositionAGL vectorFromTo (positionCameraToWorld[0,0,1]);
private _vectorDiff = (vectorNormalized (((_vectorDir) vectorCrossProduct (vectorUp player)) vectorCrossProduct (_targetPositionAGL vectorDiff _cameraPositionAGL)));

private _targetPositionAGLTop =    _targetPositionAGL vectorAdd (_vectorDiff vectorMultiply (WH_NT_FONT_SPREAD_TOP * _distance / _zoom));
private _targetPositionAGLBottom = _targetPositionAGL vectorAdd ((_vectorDiff vectorMultiply (WH_NT_FONT_SPREAD_BOTTOM * _distance / _zoom)) vectorMultiply -1);
// /_zoom


// ------------------------------------------------------------------------------------
//	Determine font size based on zoom.
// ------------------------------------------------------------------------------------

// Max out zoom at 1.67 regardless to avoid HUGE text.
_zoom = _zoom min 1.67;

// Setup the sizes based on the default size * the multiplier * the zoom.
private _sizeVehicle 	= WH_NT_FONT_SIZE_VEH * _zoom * WH_NT_FONT_SIZE_MULTI;
private _sizeMain 		= WH_NT_FONT_SIZE_MAIN* _zoom * WH_NT_FONT_SIZE_MULTI;
private _sizeSecondary 	= WH_NT_FONT_SIZE_SEC * _zoom * WH_NT_FONT_SIZE_MULTI;


// ------------------------------------------------------------------------------------
//	Render the nametags.
// ------------------------------------------------------------------------------------

// Role tag (top).
if (!(_role isEqualTo "") && {WH_NT_SHOW_ROLE}) then
{
	drawIcon3D ["", _color, _targetPositionAGLTop, 
	0, 0, 0, _role,WH_NT_FONT_SHADOW,_sizeSecondary,WH_NT_FONT_FACE_SEC];
};

// Name tag (middle).
drawIcon3D ["", _nameColor, _targetPositionAGL, 0, 0, 0, _name,WH_NT_FONT_SHADOW,_sizeMain,WH_NT_FONT_FACE_MAIN];

// Group tag (bottom).
if ( !(_groupName isEqualTo "") && {WH_NT_SHOW_GROUP}) then
{
	//drawIcon3D ["", _color, _targetPositionAGLTop,
	//0, 0, 0, _groupName,WH_NT_FONT_SHADOW,_sizeSecondary,WH_NT_FONT_FACE_SEC];
	drawIcon3D ["", _color, _targetPositionAGLBottom, 
	0, 0, 0, _groupName,WH_NT_FONT_SHADOW,_sizeSecondary,WH_NT_FONT_FACE_SEC];
};


// ------------------------------------------------------------------------------------
//	Render the vehicle tag for commanders.
// ------------------------------------------------------------------------------------

// Vehicle tag, if necessary, hovering above vehicle. Only present for commander.
if (!(isNil "_vehicle") && {WH_NT_SHOW_VEHICLEINFO}) then
{
	// Get the vehicle's friendly name from configs.
	_vehicleName = format ["%1",getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayname")];
	
	// Get the maximum number of (passenger) seats from configs.
	private _maxSlots = getNumber(configfile >> "CfgVehicles" >> typeof _vehicle >> "transportSoldier") + (count allTurrets [_vehicle, true] - count allTurrets _vehicle);
	
	// Get the number of empty seats.
	private _freeSlots = _vehicle emptyPositions "cargo";

	// If meaningful, append some info on seats onto the vehicle info.
	if (_maxSlots > 0) then 
	{ _vehicleName = _vehicleName + format[" [%1/%2]",(_maxSlots-_freeSlots),_maxSlots]; };
	
	_targetPositionAGL set [2,(_targetPositionAGL select 2) + (WH_NT_FONT_HEIGHT_VEHICLE_INFO)];
	drawIcon3D ["", _color, _targetPositionAGL,
	0, 0, 0, _vehicleName,WH_NT_FONT_SHADOW,_sizeVehicle,WH_NT_FONT_FACE_MAIN];
};