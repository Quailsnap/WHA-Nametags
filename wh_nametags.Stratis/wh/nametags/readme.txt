==========================================================================================

	WHALE'S NAMETAGS (V0.9.7ML Beta) 
	SCRIPT FOR ARMA 3
	> SPECIAL CBA OPTIONAL VERSION <
	
	( https://github.com/Whalen207/WH-NT )
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
	-	Displays player name, group, and role.
	-	Missionmakers can set custom roles on the fly.
	-	Displays vehicle information including available seats.
	-	Nametags can be toggled on or off with a button press.
	-	Tags will fade out after a certain distance.
	-	Lighting conditions and zoom level can affect visible distance.

	How to Implement:
	-	Move the wh folder (with \nametags) into your root mission folder.
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