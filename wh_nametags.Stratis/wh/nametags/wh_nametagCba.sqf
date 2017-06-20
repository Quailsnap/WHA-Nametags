// ====================================================================================
//
//	wh_nametagCBA.sqf - Contains optional CBA addon settings used only if CBA is present.
//
// ====================================================================================

if ( isClass(configFile >> "CfgPatches" >> "cba_settings") ) then
{
	[
		"WH_NT_NAMETAGS_ON",		// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"WH Nametag System", 				// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		true 						// Setting type-specific data.
	] call CBA_Settings_fnc_init;

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

	[
		"WH_NT_FONT_SIZE_MULTI",	// Internal setting name and value set.
		"SLIDER", 					// Setting type.
		"Font Size", 				// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		[0.5, 1.5, 1, 2], 			// Setting type-specific data.
		nil, 						// Nil or 0 for changeable, 1 to reset to default, 2 to lock.
		{
			WH_NT_FONT_SPREAD_TOP = WH_NT_FONT_SIZE_MULTI * WH_NT_FONT_SIZE_SEC * 0.5185;
			WH_NT_FONT_SPREAD_BOT = WH_NT_FONT_SIZE_MULTI * WH_NT_FONT_SIZE_SEC * 0.6333;
		}							// Executed at mission start and every change.
	] call CBA_Settings_fnc_init;

	if (!WH_NT_DRAWCURSORONLY) then
	{
	[
		"WH_NT_DRAWCURSORONLY",		// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"Draw On Cursor Only (Saves FPS)",
		"WH Nametags", 				// Category shown in menu.
		false 						// Setting type-specific data.
	] call CBA_Settings_fnc_init;
	}
	else
	{
	[
		"WH_NT_DRAWCURSORONLY",		// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"Draw On Cursor Only (Saves FPS)",
		"WH Nametags", 				// Category shown in menu.
		true, 						// Setting type-specific data.
		1 							// Nil or 0 for changeable, 1 to lock, 2 to hardlock.
	] call CBA_Settings_fnc_init;
	};

	if (WH_NT_DRAWDISTANCE_FOV) then
	{
	[
		"WH_NT_DRAWDISTANCE_FOV",	// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"Nametag Zooming",			// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		true 						// Setting type-specific data.
	] call CBA_Settings_fnc_init;
	}
	else 
	{
	[
		"WH_NT_DRAWDISTANCE_FOV",	// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"Nametag Zooming",	// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		false, 						// Setting type-specific data.
		1 							// Nil or 0 for changeable, 1 to lock, 2 to hardlock.
	] call CBA_Settings_fnc_init;
	};

	[
		"WH_NT_FONT_COLORBLIND",	// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"Colorblind Mode",			// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		false 						// Setting type-specific data.
	] call CBA_Settings_fnc_init;
};