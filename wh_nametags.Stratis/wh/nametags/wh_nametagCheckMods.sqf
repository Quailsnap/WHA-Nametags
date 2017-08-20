//====================================================================================
//
//	wh_nametagInitMods.sqf - Checks for ACE, ACRE, and/or TFAR presence.
//
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Checking for mods.
//------------------------------------------------------------------------------------

//	ACE
//	TBD, May integrate some ACE stuff (dead nametags) later.

//	TFAR
WH_NT_MOD_TFAR = (isClass (configFile >> "CfgPatches" >> "task_force_radio"));

//	ACRE
WH_NT_MOD_ACRE = (isClass (configFile >> "CfgPatches" >> "acre_api"));