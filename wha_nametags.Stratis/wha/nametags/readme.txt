==========================================================================================

	WHALE'S NAMETAGS (V0.10.1 Beta) 
	SCRIPT FOR ARMA 3
	
	( https://github.com/Quailsnap/WHA-Nametags )
	Contact @ /u/Whalen207 | Whale #5963
	
	This script requires CBA version v1.08.140725 or newer. 
	A branch that can be run without any mods is available here:
	( https://github.com/Quailsnap/WHA-Nametags/tree/modless )

	Special Thanks To:
	-	Wolfenswan, ferstaberinde, and headswe of F3 Framework, for code I built off of.
	-	Dsylexci and Zedx64 of Shacktac, for feature inspiration and some code solutions.
	-	Dedmen, commy2, and Quiksilver for advice in the Arma 3 Discord.
	-	Cptnnick for wonderful advice on vector math that helped me immensely.
	-	eraser1 of COALITION for help with optimization.
	-	shadow-fa from Folk ARPs and the FA community overall for testing and improvements.

	Features:
	-	Most features configurable by missionmaker.
	-	Many features configurable by clients using CBA.
	-	Displays player name, group, and role.
	-	Missionmakers can set custom roles on the fly.
	-	Displays vehicle information including available seats.
	-	Nametags can be toggled on or off with a button press.
	-	Tags will fade out after a certain distance.
	-	Lighting conditions and zoom level can affect visible distance.
	-	Changes nametag if target is talking use ACRE or TFAR.
	
	How to Implement:
	-	Move the wha folder (with \nametags) into your root mission folder.
	-	Configure your settings inside wha_nametags_CONFIG.sqf (Optional)
	-	Make a file called 'initPlayerLocal.sqf' or 'init.sqf' in the root mission folder.
	-	Put this code in 'initPlayerLocal.sqf' OR 'init.sqf': 
		[] execVM "wha\nametags\wha_nametags_init.sqf";
	-	Make a file called 'description.ext' in the root mission folder.
	-	Put this code in the 'description.ext' function header (CfgFunctions):
		#include "wha\nametags\functions\wha_nametags_functions.hpp"
	-	If you have ACE and want to disable ACE nametags just for your mission,
		the code for that is available in the description.ext of the Stratis
		mission provided with this script.

==========================================================================================