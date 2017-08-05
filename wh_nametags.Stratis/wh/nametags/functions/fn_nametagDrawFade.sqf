//====================================================================================
//
//	fn_nametagDraw.sqf - Initializes values for WH nametags (heavily based on F3 and ST)
//
//	[_x,_targetPositionAGL,_playerGroup,_cameraPositionAGL,_zoom,_range,_role,
//	_noRoleOrGroup,_vehicle] call wh_nt_fnc_nametagDraw;
//
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Declare variables.
//------------------------------------------------------------------------------------

params["_sameGroup","_target","_alpha","_role","_cameraPositionAGL","_targetPositionAGL","_zoom"];

//	_player (player unit): Player doing the rendering.
//
//	_cameraPositionAGL (position AGL, usually positionCameraToWorld[0,0,0])
//						Position of player camera, first person or third person.
//
//	_sameGroup (boolean): Whether the player is in the same group as the target.
//
//	_target (Object CAManBase): The unit the nametag will collect data from.
//
//	_targetPositionAGL (position AGL, usually ASLtoAGL(getPosASLVisual _target))
//						The position the nametag will be rendered on.
//
//	_zoom (Number >0.8): The player's current zoom level (FOV).
//
//	_role (String): The role of the target. Pass "" if not vehicle crew.
//
//	_vehicle (Object, OPTIONAL): If present, a vehicle tag will also be rendered above
//								_targetPositionAGL.

//--------------------------------------------------------------------------------
//	Get target name and distance
//--------------------------------------------------------------------------------

//	If the unit is dead, set the name to "Unknown".
//	In many mods (ACE), unconscious and dead units are moved to side civilian, which
//	will stop rendering nametags all-together.

private _name = name _target;
private _camDistance = _cameraPositionAGL distance _targetPositionAGL;

//	Only show distance for units further than 3m away.
if (WH_NT_SHOW_DISTANCE && {_camDistance >= 3}) then 
{	_name = _name + format [" | %1m",round (_camDistance)];	};


//--------------------------------------------------------------------------------
//	Get target group name.
//--------------------------------------------------------------------------------

//	Only show target group tag if it's not the same group as the player.
private _groupName = if !(_sameGroup) then { groupID (group _target) } else { "" };


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

//	Apply the alpha coating to each color's transparency.
_color set [3, (_color select 3) * _alpha];
_nameColor set [3, (_nameColor select 3) * _alpha];


//--------------------------------------------------------------------------------
//	Determine font sizes depending on player zoom level.
//--------------------------------------------------------------------------------

//	Max out zoom at 1.67 regardless to avoid HUGE text.
private _zmin = _zoom min 1.67;

// TODO : Move _sizeMain to fnc_spread.
private _sizeMain 		= WH_NT_FONT_SIZE_MAIN* _zmin;
private _sizeSecondary 	= WH_NT_FONT_SIZE_SEC * _zmin;
private _sizeVehicle 	= WH_NT_FONT_SIZE_VEH * _zmin;


//--------------------------------------------------------------------------------
//	Use space magic to realign the tags with the player's view.
//	IE: If the player is above the target, normally the nametags (which are stacked -
//	- vertically) would appear scrunched inside one another.
//	This alleviates this by realigning them vertically.
//
//	Special thanks to cptnnick for this idea, code, implementation, everything!
//--------------------------------------------------------------------------------

//	First, get vector pointing directly forward from the player's view, wherever it is.
private _vectorDir = _cameraPositionAGL vectorFromTo (positionCameraToWorld[0,0,1]);

//	Second, and the biggest step, get the normal (magnitude 1) vector going upwards 
//		along the player's screen (visually) by taking the cross product of the player's
//		model upward vector and the player's view vector, and then take the cross product
//		of that and a vector going directly from the camera to the nametag.

//	Better explanation here 
//		( forums.bistudio.com/forums/topic/206072-multi-line-text-in-drawicon3d )

private _vectorDiff = (vectorNormalized (((_vectorDir) vectorCrossProduct (vectorUp player)) vectorCrossProduct (_targetPositionAGL vectorDiff _cameraPositionAGL)));

//	Take that new normal vector and multiply it by the distance, then divide it by the zoom.
private _targetPositionAGLTop =    _targetPositionAGL vectorAdd (_vectorDiff vectorMultiply (WH_NT_FONT_SPREAD_TOP_MULTI * _camDistance / _zoom));
private _targetPositionAGLBottom = _targetPositionAGL vectorAdd ((_vectorDiff vectorMultiply (WH_NT_FONT_SPREAD_BOTTOM_MULTI * _camDistance / _zoom)) vectorMultiply -1);


//--------------------------------------------------------------------------------
//	Render the nametags.
//--------------------------------------------------------------------------------

//	Role tag (top).
if (!(_role isEqualTo "") && {WH_NT_SHOW_ROLE}) then
{
	drawIcon3D ["", _color, _targetPositionAGLTop, 
	0, 0, 0, _role,WH_NT_FONT_SHADOW,_sizeSecondary,WH_NT_FONT_FACE_SEC];
};

//	Name tag (middle).
drawIcon3D ["", _nameColor, _targetPositionAGL, 0, 0, 0, _name,WH_NT_FONT_SHADOW,_sizeMain,WH_NT_FONT_FACE_MAIN];

//	Group tag (bottom).
if ( !(_groupName isEqualTo "") && {WH_NT_SHOW_GROUP}) then
{
	drawIcon3D ["", _color, _targetPositionAGLBottom, 
	0, 0, 0, _groupName,WH_NT_FONT_SHADOW,_sizeSecondary,WH_NT_FONT_FACE_SEC];
};