// ====================================================================================
//
//	wh_nametagCBA.sqf - Contains optional CBA addon settings used only if CBA is present.
//
// ====================================================================================

if ( isClass(configFile >> "CfgPatches" >> "cba_settings") ) then
{
	// Setting for disabling the entire system.
	[
		"WH_NT_NAMETAGS_ON",		// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"WH Nametag System", 				// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		true 						// Setting type-specific data.
	] call CBA_Settings_fnc_init;

	// Setting for changing the typeface.
	[
		"WH_NT_FONT_FACE_MAIN",		// Internal setting name and value set.
		"LIST", 					// Setting type.
		"Font Face (Names)", 		// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		[
			["PuristaBold","PuristaSemiBold","PuristaMedium","PuristaLight","EtelkaNarrowMediumPro","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight","TahomaB"],
			["Purista (Bold)","Purista (Semibold)","Purista (Medium)","Purista (Light)","Etelka Pro Narrow","Roboto Condensed","Roboto Condensed (Bold) *","Roboto Condensed (Light)","Tahoma (Bold)"],
			6
		] 							// Setting type-specific data.
	] call CBA_Settings_fnc_init;

	// Setting for changing the secondary typeface.
	[
		"WH_NT_FONT_FACE_SEC",		// Internal setting name and value set.
		"LIST", 					// Setting type.
		"Font Face (Other)", 		// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		[
			["PuristaBold","PuristaSemiBold","PuristaMedium","PuristaLight","EtelkaNarrowMediumPro","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight","TahomaB"],
			["Purista (Bold)","Purista (Semibold)","Purista (Medium)","Purista (Light)","Etelka Pro Narrow","Roboto Condensed *","Roboto Condensed (Bold)","Roboto Condensed (Light)","Tahoma (Bold)"],
			5
		] 							// Setting type-specific data.
	] call CBA_Settings_fnc_init;

	// Setting to dynamically alter font size.
	[
		"WH_NT_FONT_SIZE_MULTI",	// Internal setting name and value set.
		"SLIDER", 					// Setting type.
		"Font Size", 				// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		[0.5, 1.5, 1, 2], 			// Setting type-specific data.
		nil, 						// Nil or 0 for changeable, 1 to reset to default, 2 to lock.
		{ call wh_nt_fnc_nametagSetFontSpread; }
									// Executed at mission start and every change.
	] call CBA_Settings_fnc_init;

	// Setting to dynamically alter font spread.
	[
		"WH_NT_FONT_SPREAD_MULTI",	// Internal setting name and value set.
		"SLIDER", 					// Setting type.
		"Font Spread", 				// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		[0.5, 1.5, 1, 2], 			// Setting type-specific data.
		nil, 						// Nil or 0 for changeable, 1 to reset to default, 2 to lock.
		{ call wh_nt_fnc_nametagSetFontSpread; }
									// Executed at mission start and every change.
	] call CBA_Settings_fnc_init;
	
	// Setting to flip drawcursoronly.
	if (!WH_NT_DRAWCURSORONLY) then
	{
	[
		"WH_NT_DRAWCURSORONLY",		// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"Cursor Only (Saves FPS)",	// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		false 						// Setting type-specific data.
	] call CBA_Settings_fnc_init;
	}
	// Locks in if missionmaker forces it.
	else
	{
	[
		"WH_NT_DRAWCURSORONLY",		// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"Cursor Only (Saves FPS)",	// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		true, 						// Setting type-specific data.
		1 							// Nil or 0 for changeable, 1 to lock, 2 to hardlock.
	] call CBA_Settings_fnc_init;
	};

	// Colorblind mode.
	[
		"WH_NT_FONT_COLORBLIND",	// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"Colorblind Mode",			// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		false 						// Setting type-specific data.
	] call CBA_Settings_fnc_init;
};