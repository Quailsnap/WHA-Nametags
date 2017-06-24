// ====================================================================================
//
//	fn_nametagSetFontSpread.sqf - Updates font spread (top and bottom) depending on 
//								  a dynamic spread coefficient and static font sizes.
//
//	> call wh_nt_fnc_nametagSetFontSpread; <
//	@ /u/Whalen207 | Whale #5963
//
// ====================================================================================

// ------------------------------------------------------------------------------------
//	Setup inital variables.
// ------------------------------------------------------------------------------------

private _spacingMultiplier = WH_NT_FONT_SPREAD_MULTI * WH_NT_FONT_SIZE_MULTI * WH_NT_FONT_SIZE_SEC;
private _topCoefficient    = 0.50; // (0.9032)
private _bottomCoefficient = 0.65; // (1.0645)


// ------------------------------------------------------------------------------------
//	Update global font spread.
// ------------------------------------------------------------------------------------

// Top and bottom are separate to avoid a wonky appearance.
WH_NT_FONT_SPREAD_TOP 	 = _spacingMultiplier * _topCoefficient;
WH_NT_FONT_SPREAD_BOTTOM = _spacingMultiplier * _bottomCoefficient;