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

params["_sameGroup","_target","_targetPositionAGL","_alpha","_role"];

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

private _name = if (alive _target) then { name _target } else { "Unknown" };
//private _distance = _cameraPositionAGL distance _targetPositionAGL;


//--------------------------------------------------------------------------------
//	Find and set nametag color and target role.
//--------------------------------------------------------------------------------

//	Define the default color of the nametag...
//	Note: the "+" before assignment is mandatory in SQF
//		for assigning arrays. If I just used a "=",
//		it would make a reference instead of a copy.

//	...For normal people...
private _nameColor = 
if (_role isEqualTo "") 
then { + WH_NT_FONT_COLOR_DEFAULT }
//	...and for vehicle crew, where a role is already present.
else { + WH_NT_FONT_COLOR_CREW };

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
};

//	If they're running colorblind, reset the nameColor to a nice white one.
if (WH_NT_FONT_COLORBLIND) then { _nameColor = + WH_NT_FONT_COLOR_OTHER };

//	Apply the alpha coating to the color.
_nameColor set [3, (_nameColor select 3) * _alpha];		


//--------------------------------------------------------------------------------
//	Draw the actual tag.
//--------------------------------------------------------------------------------

drawIcon3D ["", _nameColor, _targetPositionAGL, 0, 0, 0, _name,WH_NT_FONT_SHADOW,WH_NT_FONT_SIZE_MAIN,WH_NT_FONT_FACE_MAIN];