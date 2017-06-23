/// ====================================================================================
//
//	fn_nametagDraw.sqf - Initializes values for WH nametags (heavily based on F3 and ST)
//
//		[_target,_targetPosition,_unit,_unitPosition,_fov,_range,_role,_noRoleOrGroup,_vehicle] call
//		wh_nt_fnc_nametagDraw;
//	OR
//		call wh_nt_fnc_nametagDraw;
//
//	@ /u/Whalen207 | Whale #5963
//
// ====================================================================================

// ------------------------------------------------------------------------------------
// Declare variables.
// ------------------------------------------------------------------------------------
params [["_target",cursorTarget],["_targetPosition",getPosVisual _target],["_unit",player],["_unitPosition",getPosVisual _unit],["_fov",1],["_range",1],["_role",""],["_vehicle",null]];

// _target (Object CAManBase): Soldier the nametag will be rendered on.
// _targetPosition (posAGL): Position the nametag will be rendered on.
// _unit (Object CAManBase): The player.
// _unitPosition (posAGL): Position of the player.
// _fov (Number, max 1.7): Player's current zoom level.
// _range (Number, max 1): Range modifier depending on day/night cycles.
// _role (String): Target's role to be displayed at bottom.
// _vehicle (Object): If the player is looking at a vehicle -- that vehicle object.


// ------------------------------------------------------------------------------------
// Initial setup.
// ------------------------------------------------------------------------------------

// Set name.
private _name = name _target;

// If the unit is dead, shorten the range. 
if (!alive _target) then 
{
	_range = _range * 0.5;
	
	// After a while, dead units names change to an Error. This fixes that.
    if (_name isEqualTo "Error: No unit") then 
	{ _name = ""; };
};

// Determine the stance of the unit, adjust tag height accordingly.
private _height = call
{
	if ( stance _target isEqualTo "STAND" ) exitWith 	{WH_NT_FONT_HEIGHT_STANDING };
	if ( stance _target isEqualTo "PRONE" ) exitWith 	{ WH_NT_FONT_HEIGHT_PRONE   };
	if ( !(vehicle _target isEqualTo _target) ) exitWith{ WH_NT_FONT_HEIGHT_VEHICLE };
	WH_NT_FONT_HEIGHT_CROUCHING
};

// Check which tags to show. Default to false if nil.
private _showVehicleInfo = missionNamespace getVariable ["WH_NT_SHOW_VEHICLEINFO", false];
private _showDistance = missionNamespace getVariable ["WH_NT_SHOW_DISTANCE", false];
private _showRole = missionNamespace getVariable ["WH_NT_SHOW_ROLE", false];
private _showGroup = missionNamespace getVariable ["WH_NT_SHOW_GROUP", false];

// Only show group if it's not the same group as the player.
private _group = if (_showGroup && {!(group _target isEqualTo group _unit) && {(!isNull (group _target)) }})
then { groupID (group _target) } else { "" };


// ------------------------------------------------------------------------------------
// Set and manage distance to target.
// ------------------------------------------------------------------------------------

// Set distance.
private _distance = _unitPosition distance _targetPosition;

// Only show distance for units further than 3m away.
if (_showDistance && {_distance >= 3}) then 
{	_name = _name + format [" | %1m",round (_distance)];	};


// ------------------------------------------------------------------------------------
// Find transparency of tag depending on distance and time of day.
// ------------------------------------------------------------------------------------

// Get the transparency using some stupidly complex function.
private _alpha =
// If the player is not in a vehicle...
if (isNull objectParent _unit) then 
{ 
	// Use cursorTarget.
	if ( _target isEqualTo cursorTarget || {_target isEqualTo (effectiveCommander cursorTarget)} ) then 
	{ linearConversion[(((WH_NT_DRAWDISTANCE_ONE)*(_fov))/2),(WH_NT_DRAWDISTANCE_ONE*_fov),((_distance / _range)/_fov),1,0,true]; }
	else
	{ linearConversion[WH_NT_DRAWDISTANCE_ALL/2,WH_NT_DRAWDISTANCE_ALL,(_distance / _range),1,0,true];};
}
// If the player is in a vehicle...
else 
{
	// Use cursorObject, which can see through windows better.
	if ( _target isEqualTo cursorObject || {_target isEqualTo (effectiveCommander cursorObject)} ) then 
	{ linearConversion[(((WH_NT_DRAWDISTANCE_ONE)*(_fov))/2),(WH_NT_DRAWDISTANCE_ONE*_fov),((_distance / _range)/_fov),1,0,true]; }
	else
	{ linearConversion[WH_NT_DRAWDISTANCE_ALL/2,WH_NT_DRAWDISTANCE_ALL,(_distance / _range),1,0,true];};
};


// ------------------------------------------------------------------------------------
// Find and set nametag color.
// ------------------------------------------------------------------------------------

// Define the default color of the nametag...
private _color = + WH_NT_FONT_COLOR_OTHER;
_nameColor = WH_NT_FONT_COLOR_DEFAULT;

// ...For normal people...
if (_role isEqualTo "" && {_showRole}) then 							
{
	// Grab the variable set in F3 AssignGear, if present.
	_role = (_target getVariable ["f_var_assignGear_friendly",""]);
	// If it's not there, grab the possibly-ugly name from configs.
	if ( _role isEqualTo "" ) then
	{ _role = getText (configFile >> "CfgVehicles" >> typeOf _target >> "displayname") };
}
// ...and for vehicle crew, where a role is already present.
else { _nameColor = WH_NT_FONT_COLOR_CREW };

// For units in the same group as the player, set their color according to color team.
if (group _target isEqualTo group _unit) then 
{ 
	private _team = assignedTeam _target;
	_nameColor = switch (_team) do 
	{
		case "RED": 	{	WH_NT_FONT_COLOR_GROUPR	};
		case "GREEN": 	{	WH_NT_FONT_COLOR_GROUPG	};
		case "BLUE": 	{	WH_NT_FONT_COLOR_GROUPB	};
		case "YELLOW": 	{	WH_NT_FONT_COLOR_GROUPY	};
		default  		{	WH_NT_FONT_COLOR_GROUP	};
	};
	
	// For colorblind mode, replace the colors with group strings.
	if (_showGroup && {WH_NT_FONT_COLORBLIND}) then
	{
		_group = switch (_team) do 
		{
			case "RED": 	{	"Team Red"		};
			case "GREEN": 	{	"Team Green"	};
			case "BLUE": 	{	"Team Blue"		};
			case "YELLOW": 	{	"Team Yellow"	};
			default  		{};
		};
	};
};

// If they're running colorblind, reset the nameColor to a nice white one.
if (WH_NT_FONT_COLORBLIND) then { _nameColor = WH_NT_FONT_COLOR_OTHER };

// Apply the alpha coating to each color's transparency.
_color set [3, (_color select 3) * _alpha];
_nameColor = 
[_nameColor select 0, _nameColor select 1, _nameColor select 2, ((_nameColor select 3) * (_alpha))];


// ------------------------------------------------------------------------------------
// Use space magic to realign the tags with the player's view.
// IE: If the player is above the target, normally the nametags (which are stacked -
// - vertically) would appear scrunched inside one another.
// This alleviates this by realigning them horizontally.
// ------------------------------------------------------------------------------------

_targetPosition set [2,(_targetPosition select 2)+_height];

private _vectorDiff = (vectorNormalized ((_targetPosition vectorDiff _unitPosition) vectorCrossProduct ((vectorDir player) vectorCrossProduct (vectorUp player))));

private _targetPositionTop = _targetPosition vectorAdd ((_vectorDiff vectorMultiply (WH_NT_FONT_SPREAD_TOP * _distance / _fov)) vectorMultiply -1);
private _targetPositionBottom = _targetPosition vectorAdd (_vectorDiff vectorMultiply (WH_NT_FONT_SPREAD_BOTTOM * _distance / _fov));


// ------------------------------------------------------------------------------------
// Determine font size based on fov.
// ------------------------------------------------------------------------------------

// If font size zooming is disabled, set the FOV multi to 1.
if !(WH_NT_FONT_SIZE_ZOOM) 
then { _fov = 1 }
// Max out FOV at 1.67 regardless to avoid HUGE text.
else { _fov = _fov min 1.67 };

// Setup the sizes based on the default size * the multiplier * the FOV.
private _sizeVehicle 	= WH_NT_FONT_SIZE_VEH * _fov * WH_NT_FONT_SIZE_MULTI;
private _sizeMain 		= WH_NT_FONT_SIZE_MAIN* _fov * WH_NT_FONT_SIZE_MULTI;
private _sizeSecondary 	= WH_NT_FONT_SIZE_SEC * _fov * WH_NT_FONT_SIZE_MULTI;


// ------------------------------------------------------------------------------------
// Get vehicle info, if present.
// ------------------------------------------------------------------------------------

private _vehicleName = "";

if (_showVehicleInfo && {!(isNull _vehicle)}) then
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
};


// ------------------------------------------------------------------------------------
// Render the nametag.
// ------------------------------------------------------------------------------------

// Vehicle tag, if necessary, hovering above vehicle. Only present for commander.
if (_showVehicleInfo && {!(_vehicleName isEqualTo "")}) then
{
	drawIcon3D ["", _color, [(_targetPosition select 0),(_targetPosition select 1),((_targetPosition select 2) + (WH_NT_FONT_HEIGHT_VEHICLE_INFO))],
	0, 0, 0, _vehicleName,WH_NT_FONT_SHADOW,_sizeVehicle,WH_NT_FONT_FACE_MAIN];
};

// Role tag (top).
if (_showRole && {!(_role isEqualTo "")}) then
{//[_targetPosition select 0,_targetPosition select 1,(_targetPosition select 2) + _height + _spacingTop]
	drawIcon3D ["", _color, _targetPositionTop, 
	0, 0, 0, _role,WH_NT_FONT_SHADOW,_sizeSecondary,WH_NT_FONT_FACE_SEC];
};

// Name tag (middle).
drawIcon3D ["", _nameColor, _targetPosition, //[_targetPosition select 0,_targetPosition select 1,(_targetPosition select 2) + _height]
0, 0, 0, _name,WH_NT_FONT_SHADOW,_sizeMain,WH_NT_FONT_FACE_MAIN];

// Group tag (bottom).
if (_showGroup && {!(_group isEqualTo "")}) then
{
	drawIcon3D ["", _color, _targetPositionBottom,
	0, 0, 0, _group,WH_NT_FONT_SHADOW,_sizeSecondary,WH_NT_FONT_FACE_SEC];
};