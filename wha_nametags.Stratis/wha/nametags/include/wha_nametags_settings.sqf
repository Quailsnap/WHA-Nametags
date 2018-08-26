//====================================================================================
//
//	wha_nametags_settings.sqf - Contains optional CBA addon settings.
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//	Setting for disabling the entire system.
[
	"WHA_NAMETAGS_ON",		// Internal setting name and value set.
	"CHECKBOX", 				// Setting type.
	"WHA Nametag System", 		// Name shown in menu.
	"WHA Nametags", 				// Category shown in menu.
	true 						// Setting type-specific data.
] call CBA_Settings_fnc_init;

//	Setting for changing the typeface.
[
	"WHA_NAMETAGS_FONT_FACE",			// Internal setting name and value set.
	"LIST", 					// Setting type.
	"Font Face", 				// Name shown in menu.
	"WHA Nametags", 				// Category shown in menu.
	[
		[WHA_NAMETAGS_FONT_FACE,"Roboto","RobotoLight","Purista","PuristaLight","Etelka","Tahoma"],
		["Default","Roboto (Bold) *","Roboto (Light)","Purista (Bold)","Purista (Light)","Etelka Narrow","Tahoma (Bold)"],
		0
	], 							// Setting type-specific data.
	nil,
	{ call wha_nametags_fnc_resetFont; }
								// Executed at mission start and every change.
] call CBA_Settings_fnc_init;

//	Setting for changing typeface color.
[
	"WHA_NAMETAGS_FONT_COLOR",			// Internal setting name and value set.
	"LIST", 					// Setting type.
	"Font Color", 				// Name shown in menu.
	"WHA Nametags", 				// Category shown in menu.
	[
		[WHA_NAMETAGS_FONT_COLOR,"WHGreen","ACERust","TMTMTeal","COALCrimson","FAWhite","STSand","BromaPurple"],
		["Default","WHA Green *","ACE Rust","TMTM Teal","COAL Crimson","FA White","ST Sand","BromA Purple"],
		0
	],							// Setting type-specific data.
	nil,
	{ call wha_nametags_fnc_resetFont; }
								// Executed at mission start and every change.
] call CBA_Settings_fnc_init;

//	Setting to dynamically alter font size.
[
	"WHA_NAMETAGS_FONT_SIZE_MULTI",	// Internal setting name and value set.
	"SLIDER", 					// Setting type.
	"Font Size", 				// Name shown in menu.
	"WHA Nametags", 				// Category shown in menu.
	[0.75, 1.25, 1, 2], 		// Setting type-specific data.
	nil, 						// Nil or 0 for changeable, 1 to reset to default, 2 to lock.
	{ call wha_nametags_fnc_resetFont; }
								// Executed at mission start and every change.
] call CBA_Settings_fnc_init;

//	Setting to dynamically alter font spread.
[
	"WHA_NAMETAGS_FONT_SPREAD_MULTI",	// Internal setting name and value set.
	"SLIDER", 					// Setting type.
	"Font Spread", 				// Name shown in menu.
	"WHA Nametags", 				// Category shown in menu.
	[0.75, 1.25, 1, 2], 		// Setting type-specific data.
	nil, 						// Nil or 0 for changeable, 1 to reset to default, 2 to lock.
	{ call wha_nametags_fnc_resetFont; }
								// Executed at mission start and every change.
] call CBA_Settings_fnc_init;

//	Setting to flip drawcursoronly.
if (!WHA_NAMETAGS_DRAWCURSORONLY) then
{
	[
		"WHA_NAMETAGS_DRAWCURSORONLY",		// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"Cursor Only (Saves FPS)",	// Name shown in menu.
		"WHA Nametags", 				// Category shown in menu.
		false 						// Setting type-specific data.
	] call CBA_Settings_fnc_init;
}
//	Changes the default if the missionmaker changes it.
else
{
	[
		"WHA_NAMETAGS_DRAWCURSORONLY",		// Internal setting name and value set.
		"CHECKBOX", 				// Setting type.
		"Cursor Only (Saves FPS)",	// Name shown in menu.
		"WHA Nametags", 				// Category shown in menu.
		true 						// Setting type-specific data.
	] call CBA_Settings_fnc_init;
};

//	Changes whether nametags draw the role and group when under cursor.
//	Missionmaker can force these off in nametag_CONFIG.
if (WHA_NAMETAGS_SHOW_ROLE || {WHA_NAMETAGS_SHOW_GROUP}) then 
{
	switch true do
	{
		case (WHA_NAMETAGS_SHOW_ROLE && WHA_NAMETAGS_SHOW_GROUP):
		{
			//	Option to not show role and group tags.
			[
				"WHA_NAMETAGS_SHOW_ROLEANDGROUP",	// Internal setting name and value set.
				"CHECKBOX", 				// Setting type.
				"Show Role and Group",		// Name shown in menu.
				"WHA Nametags", 				// Category shown in menu.
				true, 						// Setting type-specific data.
				nil, 						// Nil or 0 for changeable.
				{
					if WHA_NAMETAGS_SHOW_ROLEANDGROUP 
					then { WHA_NAMETAGS_SHOW_ROLE = true; WHA_NAMETAGS_SHOW_GROUP = true; } 
					else { WHA_NAMETAGS_SHOW_ROLE = false; WHA_NAMETAGS_SHOW_GROUP = false; };
				}
			] call CBA_Settings_fnc_init;
		};
		case (!WHA_NAMETAGS_SHOW_ROLE&& WHA_NAMETAGS_SHOW_GROUP):
		{
			//	Option to not show group tags.
			[
				"WHA_NAMETAGS_SHOW_GROUP",			// Internal setting name and value set.
				"CHECKBOX", 				// Setting type.
				"Show Group Names",			// Name shown in menu.
				"WHA Nametags", 				// Category shown in menu.
				true, 						// Setting type-specific data.
				nil, 						// Nil or 0 for changeable.
				{}
			] call CBA_Settings_fnc_init;
		};
		case (WHA_NAMETAGS_SHOW_ROLE &&!WHA_NAMETAGS_SHOW_GROUP):
		{
			//	Option to not show role tags.
			[
				"WHA_NAMETAGS_SHOW_ROLE",			// Internal setting name and value set.
				"CHECKBOX", 				// Setting type.
				"Show Unit Roles",			// Name shown in menu.
				"WHA Nametags", 				// Category shown in menu.
				true, 						// Setting type-specific data.
				nil, 						// Nil or 0 for changeable.
				{}
			] call CBA_Settings_fnc_init;
		};
	};
};

//	Attaches nametags to player heads, like ACE.
//	Missionmaker can change the default setting.
if !WHA_NAMETAGS_FONT_HEIGHT_ONHEAD then
{
	[
	"WHA_NAMETAGS_FONT_HEIGHT_ONHEAD",	// Internal setting name and value set.
	"CHECKBOX", 				// Setting type.
	"Show Above Head",			// Name shown in menu.
	"WHA Nametags", 				// Category shown in menu.
	false 						// Setting type-specific data.
	] call CBA_Settings_fnc_init;
}
else
{
	[
	"WHA_NAMETAGS_FONT_HEIGHT_ONHEAD",	// Internal setting name and value set.
	"CHECKBOX", 				// Setting type.
	"Show Above Head",			// Name shown in menu.
	"WHA Nametags", 				// Category shown in menu.
	true 						// Setting type-specific data.
	] call CBA_Settings_fnc_init;
};
