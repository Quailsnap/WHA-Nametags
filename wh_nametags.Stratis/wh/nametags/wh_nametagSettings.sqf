//====================================================================================
//
//	wh_nametagSettings.sqf - Contains optional CBA addon settings.
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

if ( isClass(configFile >> "CfgPatches" >> "cba_settings") ) then
{
	//	Setting for disabling the entire system.
	[
		"WH_NT_NAMETAGS_ON",		// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"WH Nametag System", 		// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		true 						// Setting type-specific data.
	] call CBA_Settings_fnc_init;

	//	Setting for changing the typeface.
	[
		"WH_NT_FONT_FACE_MAIN",		// Internal setting name and value set.
		"LIST", 					// Setting type.
		"Font Face (Names)", 		// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		[
			[WH_NT_FONT_FACE_MAIN,"PuristaBold","PuristaSemiBold","PuristaMedium","PuristaLight","EtelkaNarrowMediumPro","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight","TahomaB"],
			["Default","Purista (Bold)","Purista (Semibold)","Purista (Medium)","Purista (Light)","Etelka Pro Narrow","Roboto Condensed","Roboto Condensed (Bold) *","Roboto Condensed (Light)","Tahoma (Bold)"],
			0
		] 							// Setting type-specific data.
	] call CBA_Settings_fnc_init;

	//	Setting for changing the secondary typeface.
	[
		"WH_NT_FONT_FACE_SEC",		// Internal setting name and value set.
		"LIST", 					// Setting type.
		"Font Face (Other)", 		// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		[
			[WH_NT_FONT_FACE_SEC,"PuristaBold","PuristaSemiBold","PuristaMedium","PuristaLight","EtelkaNarrowMediumPro","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight","TahomaB"],
			["Default","Purista (Bold)","Purista (Semibold)","Purista (Medium)","Purista (Light)","Etelka Pro Narrow","Roboto Condensed *","Roboto Condensed (Bold)","Roboto Condensed (Light)","Tahoma (Bold)"],
			0
		] 							// Setting type-specific data.
	] call CBA_Settings_fnc_init;

	//	Setting for changing typeface color.
	[
		"WH_NT_FONT_COLOR_DEFAULT",	// Internal setting name and value set.
		"LIST", 					// Setting type.
		"Font Color (Main)", 		// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		[
			[WH_NT_FONT_COLOR_DEFAULT,[0.68,0.90,0.36,0.85],[0.77, 0.51, 0.08, 0.85],[0.15,0.70,0.90,0.85],[0.90,0.10,0.10,0.85],[0.90,0.90,0.90,0.85],[0.90,0.75,0,0.85],[0.85,0.50,0.90,0.85]],
			["Default","WH Green *","ACE Rust","TMTM Blue","COAL Crimson","FA White","ST Sand","BromA Purple"],
			0
		] 							// Setting type-specific data.
	] call CBA_Settings_fnc_init;
	
	//	Setting to dynamically alter font size.
	[
		"WH_NT_FONT_SIZE_MULTI",	// Internal setting name and value set.
		"SLIDER", 					// Setting type.
		"Font Size", 				// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		[0.75, 1.25, 1, 2], 		// Setting type-specific data.
		nil, 						// Nil or 0 for changeable, 1 to reset to default, 2 to lock.
		{ call wh_nt_fnc_nametagResetFont; }
									// Executed at mission start and every change.
	] call CBA_Settings_fnc_init;

	//	Setting to dynamically alter font spread.
	[
		"WH_NT_FONT_SPREAD_MULTI",	// Internal setting name and value set.
		"SLIDER", 					// Setting type.
		"Font Spread", 				// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		[0.75, 1.25, 1, 2], 		// Setting type-specific data.
		nil, 						// Nil or 0 for changeable, 1 to reset to default, 2 to lock.
		{ call wh_nt_fnc_nametagResetFont; }
									// Executed at mission start and every change.
	] call CBA_Settings_fnc_init;
	
	//	Setting to flip drawcursoronly.
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
	//	Changes the default if the missionmaker changes it.
	else
	{
		[
			"WH_NT_DRAWCURSORONLY",		// Internal setting name and value set.
			"CHECKBOX", 				// Setting type.
			"Cursor Only (Saves FPS)",	// Name shown in menu.
			"WH Nametags", 				// Category shown in menu.
			true 						// Setting type-specific data.
		] call CBA_Settings_fnc_init;
	};

	//	Changes whether nametags draw the role and group when under cursor.
	//	Missionmaker can force these off in nametagCONFIG.
	if (WH_NT_SHOW_ROLE || {WH_NT_SHOW_GROUP}) then 
	{
		switch true do
		{
			case (WH_NT_SHOW_ROLE && WH_NT_SHOW_GROUP):
			{
				//	Option to not show role and group tags.
				[
					"WH_NT_SHOW_ROLEANDGROUP",	// Internal setting name and value set.
					"CHECKBOX", 				// Setting type.
					"Show Role and Group",		// Name shown in menu.
					"WH Nametags", 				// Category shown in menu.
					true, 						// Setting type-specific data.
					nil, 						// Nil or 0 for changeable.
					{
						if WH_NT_SHOW_ROLEANDGROUP 
						then { WH_NT_SHOW_ROLE = true; WH_NT_SHOW_GROUP = true; } 
						else { WH_NT_SHOW_ROLE = false; WH_NT_SHOW_GROUP = false; };
					}
				] call CBA_Settings_fnc_init;
			};
			case (!WH_NT_SHOW_ROLE&& WH_NT_SHOW_GROUP):
			{
				//	Option to not show group tags.
				[
					"WH_NT_SHOW_GROUP",			// Internal setting name and value set.
					"CHECKBOX", 				// Setting type.
					"Show Group Names",			// Name shown in menu.
					"WH Nametags", 				// Category shown in menu.
					true, 						// Setting type-specific data.
					nil, 						// Nil or 0 for changeable.
					{}
				] call CBA_Settings_fnc_init;
			};
			case (WH_NT_SHOW_ROLE &&!WH_NT_SHOW_GROUP):
			{
				//	Option to not show role tags.
				[
					"WH_NT_SHOW_ROLE",			// Internal setting name and value set.
					"CHECKBOX", 				// Setting type.
					"Show Unit Roles",			// Name shown in menu.
					"WH Nametags", 				// Category shown in menu.
					true, 						// Setting type-specific data.
					nil, 						// Nil or 0 for changeable.
					{}
				] call CBA_Settings_fnc_init;
			};
		};
	};
	
	//	Attaches nametags to player heads, like ACE.
	//	Missionmaker can change the default setting.
	if !WH_NT_FONT_HEIGHT_ONHEAD then
	{
		[
		"WH_NT_FONT_HEIGHT_ONHEAD",	// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"Show Above Head",			// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		false 						// Setting type-specific data.
		] call CBA_Settings_fnc_init;
	}
	else
	{
		[
		"WH_NT_FONT_HEIGHT_ONHEAD",	// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"Show Above Head",			// Name shown in menu.
		"WH Nametags", 				// Category shown in menu.
		true 						// Setting type-specific data.
		] call CBA_Settings_fnc_init;
	};
};