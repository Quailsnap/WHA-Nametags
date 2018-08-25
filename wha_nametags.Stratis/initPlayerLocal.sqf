// NAMETAGS
[] execVM "wha\nametags\wha_nametag_init.sqf";

WHA_NAMETAG_TESTLOOP =
[
	{
		{ WHA_NAMETAG_PLAYER reveal [_x,4] } forEach allUnits;
	},
	10,
	[]
] call CBA_fnc_addPerFrameHandler;