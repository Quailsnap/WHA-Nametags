//====================================================================================
//
//	wha_nametags_checkMods.sqf - Checks for ACE, ACRE, and/or TFAR presence.
//
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Checking for mods.
//------------------------------------------------------------------------------------

//	ACE
WHA_NAMETAGS_MOD_ACE = (isClass(configfile >> "CfgPatches" >> "ace_medical"));

//	TFAR
WHA_NAMETAGS_MOD_TFAR = (isClass (configFile >> "CfgPatches" >> "task_force_radio"));

//	ACRE
WHA_NAMETAGS_MOD_ACRE = (isClass (configFile >> "CfgPatches" >> "acre_api"));