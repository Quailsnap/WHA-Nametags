 ==========================================================================================

	WHALE'S NAMETAGS (V0.8.3 Beta) 
	SCRIPT FOR ARMA 3
	
	( https://github.com/Whalen207/WH )
	Contact @ /u/Whalen207 | Whale #5963
	
	Special Thanks To:
	-	Wolfenswan, ferstaberinde, headswe of F3 Framework, for code I built off of.
	-	Dsylexci and Zedx64 of Shacktac, for feature inspiration and some code solutions.
	-	Dedmen, commy2, and Quiksilver for advice in the Arma 3 Discord.
	-	Cptnnick for wonderful advice on vector math that helped me immensely.
	-	eraser1 of COALITION for some optimization advice.

	Features:
	-	Most features configurable by missionmaker.
	-	Many features configurable by clients using CBA.
	-	Does not render nametags if offscreen or out of sight.
	-	Can display player name, group, distance, and role.
	-	Custom roles can be set using setVariable.
	-	Can display vehicle information including available seats.
	-	Nametags can be toggled on or off with a button press.
	-	Nametags are rendered in 3D, but appear 2D and follow players.
	-	Tags will fade out after a certain distance.
	-	Lighting conditions (day, night, NVGs) can affect visible distance.
	-	Player zoom level can affect visible distance and font size.
	-	Colorblind mode.

	How to Implement:
	-	Move the WH folder (with \nametags) into the root mission folder.
	-	Configure your settings inside wh_nametagCONFIG.sqf (Optional)
	-	Make a file called 'initPlayerLocal.sqf' or 'init.sqf' in the root mission folder.
	-	Put this code in 'initPlayerLocal.sqf' OR 'init.sqf': 
		[] execVM "wh\nametags\wh_nametagInit.sqf";
	-	Make a file called 'description.ext' in the root mission folder.
	-	Put this code in the 'description.ext' function header (CfgFunctions):
		#include "wh\nametags\functions\wh_nametagFunctions.hpp"
	-	If you have ACE and want to disable ACE nametags just for your mission,
		the code for that is available in the description.ext of the Stratis
		mission provided with this script.

==========================================================================================