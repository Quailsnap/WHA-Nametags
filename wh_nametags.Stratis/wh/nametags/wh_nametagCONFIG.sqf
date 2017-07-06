//=======================================================================================
//
//	wh_nametagConfig.sqf - Contains configurable values for WH nametags.
//						|| Heavy inspiration from F3.
//
//	Note:	If CBA is enabled, many of these settings (DRAWCURSORONLY, for instance) can
//		 	be altered by individual clients to their preference. If you disable
//			DRAWCURSORONLY it will lock that particular setting and force everyone to
//			play with it off. I recommend leaving the choice to the players.
//
//=======================================================================================

//---------------------------------------------------------------------------------------
//	Configuration Values. Feel free to modify. 
//---------------------------------------------------------------------------------------

//	Main Values																	(Default values)
WH_NT_DRAWCURSORONLY = false;	//	Only draw nametags on mouse cursor. 		(Default: false)
								//	Can save FPS in crowded areas.

WH_NT_ACTIONKEY = "timeInc"; 	//	Key that can be pressed to toggle tags.		("timeInc")
								//	Default is "timeInc", which is normally
								//	the (=) key. Other keys available here:
								//	https://community.bistudio.com/wiki/inputAction/actions/bindings
								//	Don't want any key? Comment out the line.
								
WH_NT_NIGHT = true;				//	Whether night will affect tag visibility.	(true)

// Information Shown
WH_NT_SHOW_GROUP 		= true;	//	Draw group name under unit's name. 			(true)
WH_NT_SHOW_ROLE			= true; //	Draw unit's role (rifleman, driver). 		(true)
WH_NT_SHOW_DISTANCE 	= false;//	Draw distance to unit.						(false)
WH_NT_SHOW_VEHICLEINFO 	= true;	//	Draw vehicle info.							(true)

// Draw Distances
WH_NT_DRAWDISTANCE_CURSOR = 20; 	//	Distance to draw nametags when pointing at a unit.	(20)
								//	Should be greater than DISTANCE_ALL.
								//	May be increased SIGNIFICANTLY if FOV is enabled.
WH_NT_DRAWDISTANCE_NEAR = 10; 	//	Distance within which all nametags will be drawn.	(10)
								//	Increasing this will cost performance.
								//	Due to a bug this will seem ~3m shorter in third person.

// Text Configuration: Typeface				Try "EtelkaNarrowMediumPro" for an Arma 2 throwback.
WH_NT_FONT_FACE_MAIN ="RobotoCondensedBold";//	Font for unit and vehicle names.	("RobotoCondensedBold")
WH_NT_FONT_FACE_SEC = "RobotoCondensed";	//	Font for unit groups and roles.		("RobotoCondensed")
WH_NT_FONT_SHADOW = 2;						//	Shadow to outline all text.			(2)

// Text Configuration: Size
WH_NT_FONT_SIZE_RAW = 0.036;		//	Default raw font size.					(0.036)
									//	Used directly for names, and used with
									//	below modifiers for all else.
WH_NT_FONT_SIZE_SEC_MULTI =	0.861;	//	Multiplier for group and role tags.		(0.861)
WH_NT_FONT_SIZE_MULTI = 1;			//	A general multiplier that can be used	(1)
									//	if you don't like the other ones.
// Text Configuration: Spacing
WH_NT_FONT_SPREAD_MULTI = 1;	//	Multiplier for vertical font spacing.		(1)
								//	may be overriden by CBA settings.
								
// Text Configuration: Color
WH_NT_FONT_COLOR_DEFAULT= [0.68,0.90,0.36,0.85];	//	Default color.			([0.68,0.90,0.36,0.85])
													//	May be overridden by CBA settings.

WH_NT_FONT_COLOR_GROUP	= [0.90,0.90,0.90,0.85];	//	Same group.				([0.90,0.90,0.90,0.85])
WH_NT_FONT_COLOR_GROUPR = [0.90,0.25,0.25,0.85];	//	Team red.				([0.90,0.25,0.25,0.85])
WH_NT_FONT_COLOR_GROUPG = [0.50,0.90,0.40,0.85];	//	Team green.				([0.50,0.90,0.40,0.85])
WH_NT_FONT_COLOR_GROUPB = [0.45,0.45,0.90,0.85];	//	Team blue.				([0.45,0.45,0.90,0.85])
WH_NT_FONT_COLOR_GROUPY = [0.90,0.90,0.30,0.85];	//	Team yellow.			([0.90,0.90,0.30,0.85])
WH_NT_FONT_COLOR_CREW	= [0.95,0.80,0.10,0.85];	//	Vehicle crew.			([0.95,0.80,0.10,0.85])
WH_NT_FONT_COLOR_OTHER	= [0.90,0.90,0.90,0.85];	//	Everything but names.	([0.90,0.90,0.90,0.85])

// Text Configuration: Position			Font height difference from torso when...
WH_NT_FONT_HEIGHT_ONHEAD = false;		//	Attaches nametags to head (like ACE)(false)
		
// Colorblind Mode
WH_NT_FONT_COLORBLIND = false;			//	Will remove colors and instead describe.	(false)