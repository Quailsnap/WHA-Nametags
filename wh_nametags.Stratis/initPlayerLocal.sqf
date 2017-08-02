// NAMETAGS
[] execVM "wh\nametags\wh_nametagInit.sqf";

// For testing purposes
setViewDistance 50;
setObjectViewDistance [50,0];

{ player reveal [_x,4] } forEach allUnits;