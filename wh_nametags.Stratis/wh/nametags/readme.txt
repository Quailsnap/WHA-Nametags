 ===================================================================

	WHALE'S NAMETAGS (V0.6G Beta) 
 	SCRIPT FOR ARMA 3
	Contact @ /u/Whalen207 | Whale #5963

	Special Thanks To:
	- Wolfenswan, ferstaberinde, headswe of F3 Framework, for code I built off of.
	- Dsylexci and Zedx64 of Shacktac, for feature inspiration and some code solutions.

	Features:
	- All features configurable by missionmaker.
	- Some features configurable by clients using CBA.
	- Full multiplayer support.
	- Performance comparable to ACE nametags.
	- Can display player name, group, distance, and role.
	- Custom roles can be set using setVariable, designed for use with F3.
	- Can display vehicle information including available seats.
	- Nametags can be toggled on or off with a button press.
	- Nametags are rendered in 3D and follow players.
	- Tags will fade out after a certain distance.
	- Lighting conditions (day, night, NVGs) can affect visible distance.
	- Player zoom level can affect visible distance and font size.
	- Colorblind mode.

	How to Implement:
	- Configure your settings inside wh_nametagCONFIG.sqf.
	- Make a file called 'initPlayerLocal.sqf' or 'init.sqf' in the root mission folder.
	- Put this code in 'initPlayerLocal.sqf' OR 'init.sqf': 
		[] execVM "wh\nametags\wh_nametagInit.sqf";
	- Make a file called 'description.ext' in the root mission folder.
	- Put this code in the 'description.ext' function header (CfgFunctions):
		#include "wh\nametags\wh_nametagFunctions.hpp"

	TODO:
	- Caching for cursortarget (in fn_nametagDraw). Cursor fades.
	- Improve performance significantly.
	- Find a less hacky fix for vibrating vehicle tags.
	- Check if dead player nametags work and for how long.
	- Find a better way to change default font spacing between lines (ie: role on top, name in middle)
	   depending on what font and font size is chosen.
	- Find a better way to switch between cursorObject and cursorTarget depending on whether or not the    
	   player is currently in a vehicle.
	
 ===================================================================
