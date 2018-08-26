// NAMETAGS
[] execVM "wha\nametags\wha_nametags_init.sqf";

WHA_NAMETAGS_TESTLOOP =
[
	{ { WHA_NAMETAGS_PLAYER reveal [_x,4] } forEach allUnits; },
	10,
	[]
] call CBA_fnc_addPerFrameHandler;