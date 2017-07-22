// ====================================================================================
//
//	fn_nametagResetFont.sqf - 	Updates font size and spread depending on a dynamic 
//								spread coefficient and possible CBA setting alterations.
//
//	> call wh_nt_fnc_nametagResetFont; <
//	@ /u/Whalen207 | Whale #5963
//
// ====================================================================================

// ------------------------------------------------------------------------------------
//	Update global font sizes.
// ------------------------------------------------------------------------------------

WH_NT_FONT_SIZE_MAIN= WH_NT_FONT_SIZE_RAW * WH_NT_FONT_SIZE_MULTI;
WH_NT_FONT_SIZE_SEC	= WH_NT_FONT_SIZE_MAIN * WH_NT_FONT_SIZE_SEC_MULTI;


// ------------------------------------------------------------------------------------
//	Update global font spread.
// ------------------------------------------------------------------------------------

private _spacingMultiplier = WH_NT_FONT_SPREAD_MULTI * WH_NT_FONT_SIZE_SEC;

//	Coefficients are used. Should be changed if you change the default font, probably.
private _topMultiplier    = 0.50; // Default: (0.50)
private _bottomMultiplier = 0.65; // Default: (0.65)

// Top and bottom are separate to avoid a wonky appearance.
WH_NT_FONT_SPREAD_TOP_MULTI		= _spacingMultiplier * _topMultiplier;
WH_NT_FONT_SPREAD_BOTTOM_MULTI	= _spacingMultiplier * _bottomMultiplier;