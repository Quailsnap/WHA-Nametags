/// ====================================================================================
//
//	fn_nametagDraw.sqf - Initializes values for WH nametags (heavily based on F3 and ST)
//		[_x,_pos,_fov,_dist,_range,_role,_veh] call wh_nt_fnc_nametagDraw;
//	OR
//		[_x,_pos] call wh_nt_fnc_nametagDraw;
//
//	@ /u/Whalen207 | Whale #5963
//
// ====================================================================================

// ------------------------------------------------------------------------------------
// Declare variables.
// ------------------------------------------------------------------------------------

params ["_t","_u","_pos",["_fov",1],["_dist",0],["_range",1],["_role",""],["_noRG",false],["_veh",""]];


// ------------------------------------------------------------------------------------
// Initial setup.
// ------------------------------------------------------------------------------------

// If the unit is dead, shorten the range. Set name.
private _name = name _t;

if (!alive _t) then 
{
    if (_name isEqualTo "Error: No unit") then 
	{ _name = ""; };

    _range = _range * 0.5;
};

// Determine the stance of the unit, adjust tag height accordingly.
private _height = call
{
	if ( stance _t isEqualTo "STAND" ) exitWith {WH_NT_FONT_HEIGHT_STANDING};
	if ( stance _t isEqualTo "PRONE" ) exitWith { WH_NT_FONT_HEIGHT_PRONE  };
	if (!(vehicle _t isEqualTo _t)   ) exitWith { WH_NT_FONT_HEIGHT_PRONE  };
	WH_NT_FONT_HEIGHT_CROUCHING
};

// Check which tags to show. Default to false if nil.
private _showVeh  = missionNamespace getVariable ["WH_NT_SHOW_VEHICLEINFO", false];
private _showDis  = missionNamespace getVariable ["WH_NT_SHOW_DISTANCE", false];
private _showRole = missionNamespace getVariable ["WH_NT_SHOW_ROLE", false];
private _showGrp  = missionNamespace getVariable ["WH_NT_SHOW_GROUP", false];
if (_noRG) then { _showGrp = false; _showRole = false };

// Only show group if it's not the same group as the player.
private _grp = if (_showGrp && {group _t != group _u && {(!isNull (group _t)) && {!(_noRG)}}}) then 
{ groupID (group _t) } else { "" };

// Only show distance for units further than 3m away.
if (_showDis && {_dist >= 3}) then 
{	_name = _name + format [" | %1m",round (_dist)];	};


// ------------------------------------------------------------------------------------
// Find and set nametag color.
// ------------------------------------------------------------------------------------

// Define the default color of the nametag...
private _color = + WH_NT_FONT_COLOR_OTHER;
_nameColor = WH_NT_FONT_COLOR_DEFAULT;

// ...For normal people...
if (_role isEqualTo "" && {_showRole}) then 							
{
	_role = (_t getVariable ["f_var_assignGear_friendly",""]);
	if ( _role isEqualTo "" ) then
	{ _role = getText (configFile >> "CfgVehicles" >> typeOf _t >> "displayname") };
}
// ...and for vehicle crew.
else { _nameColor = WH_NT_FONT_COLOR_CREW };

// For units in the same group as the player, set their color according to color team.
if (group _t isEqualTo group _u) then 
{ 
	private _team = assignedTeam _t;
	_nameColor = switch (_team) do 
	{
		case "RED": 	{	WH_NT_FONT_COLOR_GROUPR	};
		case "GREEN": 	{	WH_NT_FONT_COLOR_GROUPG	};
		case "BLUE": 	{	WH_NT_FONT_COLOR_GROUPB	};
		case "YELLOW": 	{	WH_NT_FONT_COLOR_GROUPY	};
		default  		{	WH_NT_FONT_COLOR_GROUP	};
	};
	
	if (_showGrp && {WH_NT_FONT_COLORBLIND}) then
	{
		_grp = switch (_team) do 
		{
			case "RED": 	{	"Team Red"		};
			case "GREEN": 	{	"Team Green"	};
			case "BLUE": 	{	"Team Blue"		};
			case "YELLOW": 	{	"Team Yellow"	};
			default  		{};
		};
	};
};

if (WH_NT_FONT_COLORBLIND) then { _nameColor = WH_NT_FONT_COLOR_OTHER };


// ------------------------------------------------------------------------------------
// Change alpha of tag depending on distance and time of day.
// ------------------------------------------------------------------------------------

private _alpha =
if (isNull objectParent _u) then 
{ 
	if ( _t isEqualTo cursorTarget || {_t isEqualTo (effectiveCommander cursorTarget)} ) then 
	{ linearConversion[(((WH_NT_DRAWDISTANCE_ONE)*(_fov))/2),(WH_NT_DRAWDISTANCE_ONE*_fov),((_dist / _range)/_fov),1,0,true]; }
	else
	{ linearConversion[WH_NT_DRAWDISTANCE_ALL/2,WH_NT_DRAWDISTANCE_ALL,(_dist / _range),1,0,true];};
}
else 
{
	if ( _t isEqualTo cursorObject || {_t isEqualTo (effectiveCommander cursorObject)} ) then 
	{ linearConversion[(((WH_NT_DRAWDISTANCE_ONE)*(_fov))/2),(WH_NT_DRAWDISTANCE_ONE*_fov),((_dist / _range)/_fov),1,0,true]; }
	else
	{ linearConversion[WH_NT_DRAWDISTANCE_ALL/2,WH_NT_DRAWDISTANCE_ALL,(_dist / _range),1,0,true];};
};

_color set [3, (_color select 3) * _alpha];
//_nameColor set [3, (_nameColor select 3) * _alpha];
_nameColor = 
[_nameColor select 0, _nameColor select 1, _nameColor select 2, ((_nameColor select 3) * (_alpha))];

// ------------------------------------------------------------------------------------
// Determine the distance needed between tags depending on how close the player is. (TBD)
// ------------------------------------------------------------------------------------

// Setup the 3D object spread based on the distance and FOV.
private _hdt = WH_NT_FONT_SPREAD_TOP * _dist / _fov;
private _hdb = WH_NT_FONT_SPREAD_BOT * _dist / _fov;


// ------------------------------------------------------------------------------------
// Determine font size based on fov.
// ------------------------------------------------------------------------------------

_fov = _fov min 1.67; // max ?

// Setup the sizes based on the default size * the multiplier * the FOV.
private _sizeV = WH_NT_FONT_SIZE_VEH * _fov * WH_NT_FONT_SIZE_MULTI;
private _sizeM = WH_NT_FONT_SIZE_MAIN* _fov * WH_NT_FONT_SIZE_MULTI;
private _sizeS = WH_NT_FONT_SIZE_SEC * _fov * WH_NT_FONT_SIZE_MULTI;


// ------------------------------------------------------------------------------------
// Render the nametag.
// ------------------------------------------------------------------------------------

// Vehicle tag, if necessary, hovering above vehicle. Only present for commander.
if (_showVeh && {!(_veh isEqualTo "")}) then
{
	drawIcon3D ["", _color, [_pos select 0,_pos select 1,((_pos select 2) + WH_NT_FONT_HEIGHT_VEH + (_hdt * 3))],
	0, 0, 0, _veh,WH_NT_FONT_SHADOW,_sizeV,WH_NT_FONT_FACE_MAIN];
};

// Role tag (top).
if (_showRole && {!(_role isEqualTo "")}) then
{
	drawIcon3D ["", _color, [_pos select 0,_pos select 1,(_pos select 2) + _height + _hdt],
	0, 0, 0, _role,WH_NT_FONT_SHADOW,_sizeS,WH_NT_FONT_FACE_SEC];
};

// Name tag (middle).
drawIcon3D ["", _nameColor, [_pos select 0,_pos select 1,(_pos select 2) + _height],
0, 0, 0, _name,WH_NT_FONT_SHADOW,_sizeM,WH_NT_FONT_FACE_MAIN];

// Group tag (bottom).
if (_showGrp && {!(_grp isEqualTo "")}) then
{
	drawIcon3D ["", _color, [_pos select 0,_pos select 1,(_pos select 2) + _height - _hdb],
	0, 0, 0, _grp,WH_NT_FONT_SHADOW,_sizeS,WH_NT_FONT_FACE_SEC];
};