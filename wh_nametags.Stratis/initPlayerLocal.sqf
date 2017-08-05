// NAMETAGS
[] execVM "wh\nametags\wh_nametagInit.sqf";

// For testing purposes
setViewDistance 50;
setObjectViewDistance [50,0];

WH_NT_TESTLOOP =
[
	{
		{ player reveal [_x,4] } forEach allUnits;
	},
	10,
	[]
] call CBA_fnc_addPerFrameHandler;