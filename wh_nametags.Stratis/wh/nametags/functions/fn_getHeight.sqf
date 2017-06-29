// ====================================================================================
//
//	fn_getHeight.sqf - Returns a height bonus for nametags depending on unit stance.
//	> _height = [_unit] call wh_nt_fnc_getHeight; <
//
// ====================================================================================

switch (stance _this) do 
{
	case "STAND": 	{	WH_NT_FONT_HEIGHT_STANDING	};
	case "CROUCH": 	{	WH_NT_FONT_HEIGHT_CROUCHING	};
	case "PRONE": 	{	WH_NT_FONT_HEIGHT_PRONE		};
	default			{	WH_NT_FONT_HEIGHT_VEHICLE	};
};