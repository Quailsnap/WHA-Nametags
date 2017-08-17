// NAMETAGS
[] execVM "wh\nametags\wh_nametagInit.sqf";

WH_NT_TESTLOOP =
[
	{
		{ WH_NT_PLAYER reveal [_x,4] } forEach allUnits;
	},
	10,
	[]
] call CBA_fnc_addPerFrameHandler;