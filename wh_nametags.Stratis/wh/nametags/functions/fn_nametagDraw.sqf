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

params["_player","_cameraPositionAGL","_sameGroup","_target",
"_targetPositionAGL","_zoom","_role","_vehicle"];

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


//------------------------------------------------------------------------------------
//	Get target name.
//------------------------------------------------------------------------------------

//	If the unit is dead, set the name to "Unknown".
//	In many mods (ACE), unconscious and dead units are moved to side civilian, which
//	will stop rendering nametags all-together.
private _name = if (alive _x) then { name _x } else { "Unknown" };


//------------------------------------------------------------------------------------
//	Get target group name.
//------------------------------------------------------------------------------------

//	Only show target group tag if it's not the same group as the player.
private _groupName = if !(_sameGroup) then { groupID (group _target) } else { "" };


//------------------------------------------------------------------------------------
//	Set and manage distance to target.
//------------------------------------------------------------------------------------

//	Set distance. Cannot use the quicker calculation (object to object rather than
//		position to position) because _distance is used to calculate font transparency
//		and, more importantly, spacing between lines.

private _distance = _cameraPositionAGL distance _targetPositionAGL;

//	Only show distance for units further than 3m away.
if (WH_NT_SHOW_DISTANCE && {_distance >= 3}) then 
{	_name = _name + format [" | %1m",round (_distance)];	};


//------------------------------------------------------------------------------------
//	Find transparency of tag depending on distance and time of day.
//------------------------------------------------------------------------------------

//	Get the alpha (transparency) using some stupidly complex function.
private _alpha =
//	If the player is not in a vehicle...
if !WH_NT_VAR_PLAYER_INVEHICLE then 
{ 
	//	Use cursorTarget for the 'pointing at' unit you can see further away.

	//	If the target is the cursorTarget, base the alpha on DISTANCE_ONE.
	//		Do a linearConversion (community.bistudio.com/wiki/linearConversion),
	//		comparing the distance to target with the maximum distance tags can be
	//		rendered at. If the distance to target is the maximum distance, the
	//		alpha will be 0 (fully transparent). If it's less, the transparency
	//		will ramp up until the distance is the max distance divided by 1.3,
	//		where the alpha will be 1 (fully visible).
	
	//	Note that zoom increases the max distance you can see "ONE" tags.
	
	if ( _x isEqualTo cursorTarget || {_x isEqualTo (effectiveCommander cursorTarget)} ) then 
	{ linearConversion[(((WH_NT_DRAWDISTANCE_ONE)*(_zoom))/1.3),(WH_NT_DRAWDISTANCE_ONE*_zoom),((_distance / WH_NT_VAR_NIGHT)/_zoom),1,0,true]; }
	//	If the target being nametagged isn't the cursorTarget, the alpha should be based on DISTANCE_ALL.
	else
	{ linearConversion[WH_NT_DRAWDISTANCE_ALL/1.3,WH_NT_DRAWDISTANCE_ALL,(_distance / WH_NT_VAR_NIGHT),1,0,true];};
}
//	If the player is in a vehicle...
else 
{
	//	Use cursorObject, which can see through windows better.
	if ( _x isEqualTo cursorObject || {_x isEqualTo (effectiveCommander cursorObject)} ) then 
	{ linearConversion[(((WH_NT_DRAWDISTANCE_ONE)*(_zoom))/1.5),(WH_NT_DRAWDISTANCE_ONE*_zoom),((_distance / WH_NT_VAR_NIGHT)/_zoom),1,0,true]; }
	else
	{ linearConversion[WH_NT_DRAWDISTANCE_ALL/1.5,WH_NT_DRAWDISTANCE_ALL,(_distance / WH_NT_VAR_NIGHT),1,0,true];};
};


//------------------------------------------------------------------------------------
//	Find and set nametag color and target role.
//------------------------------------------------------------------------------------

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
	_role = (_x getVariable ["f_var_assignGear_friendly",
			getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayname")]);
}
//	...and for vehicle crew, where a role is already present.
else { _nameColor = + WH_NT_FONT_COLOR_CREW };

//	For units in the same group as the player, set their color according to color team.
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


//------------------------------------------------------------------------------------
//	Use space magic to realign the tags with the player's view.
//	IE: If the player is above the target, normally the nametags (which are stacked -
//	- vertically) would appear scrunched inside one another.
//	This alleviates this by realigning them vertically.
//
//	Special thanks to cptnnick for this idea, code, implementation, everything!
//------------------------------------------------------------------------------------

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
private _targetPositionAGLTop =    _targetPositionAGL vectorAdd (_vectorDiff vectorMultiply (WH_NT_FONT_SPREAD_TOP * _distance / _zoom));
private _targetPositionAGLBottom = _targetPositionAGL vectorAdd ((_vectorDiff vectorMultiply (WH_NT_FONT_SPREAD_BOTTOM * _distance / _zoom)) vectorMultiply -1);


//------------------------------------------------------------------------------------
//	Determine font size based on zoom.
//------------------------------------------------------------------------------------

//	Max out zoom at 1.67 regardless to avoid HUGE text.
_zoom = _zoom min 1.67;

//	Setup the sizes based on the default size * the multiplier * the zoom.
private _sizeVehicle 	= WH_NT_FONT_SIZE_VEH * _zoom * WH_NT_FONT_SIZE_MULTI;
private _sizeMain 		= WH_NT_FONT_SIZE_MAIN* _zoom * WH_NT_FONT_SIZE_MULTI;
private _sizeSecondary 	= WH_NT_FONT_SIZE_SEC * _zoom * WH_NT_FONT_SIZE_MULTI;


//------------------------------------------------------------------------------------
//	Render the nametags.
//------------------------------------------------------------------------------------

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


//------------------------------------------------------------------------------------
//	Render the vehicle tag if the vehicle exists.
//------------------------------------------------------------------------------------

if (!(isNil "_vehicle") && {WH_NT_SHOW_VEHICLEINFO}) then
{
	//	Get the vehicle's friendly name from configs.
	_vehicleName = format ["%1",getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayname")];
	
	//	Get the maximum number of (passenger) seats from configs.
	private _maxSlots = getNumber(configfile >> "CfgVehicles" >> typeof _vehicle >> "transportSoldier") + (count allTurrets [_vehicle, true] - count allTurrets _vehicle);
	
	//	Get the number of empty seats.
	private _freeSlots = _vehicle emptyPositions "cargo";

	//	If meaningful, append some info on seats onto the vehicle info.
	if (_maxSlots > 0) then 
	{ _vehicleName = _vehicleName + format[" [%1/%2]",(_maxSlots-_freeSlots),_maxSlots]; };
	
	_targetPositionAGL set [2,(_targetPositionAGL select 2) + (WH_NT_FONT_HEIGHT_VEHICLE_INFO)];
	drawIcon3D ["", _color, _targetPositionAGL,
	0, 0, 0, _vehicleName,WH_NT_FONT_SHADOW,_sizeVehicle,WH_NT_FONT_FACE_MAIN];
};