//====================================================================================
//
//	wha_nametags_disableKey.sqf - Sets up a key that can be used to flip the nametag
//							   system on and off with a press.
//
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Setup the Action Key, default '='.
//------------------------------------------------------------------------------------

//	None of this will execute if the actionkey line in CONFIG is commented out.
if (!isNil "WHA_NAMETAGS_ACTIONKEY") then
{
	WHA_NAMETAGS_ACTIONKEY_ID = (actionKeys WHA_NAMETAGS_ACTIONKEY) select 0;// This key, a global variable.
	WHA_NAMETAGS_ACTIONKEY_NAME = actionKeysNames WHA_NAMETAGS_ACTIONKEY;	// Which is named this...
	
	//	Function that will determine when the disableKey is depressed.
	WHA_NAMETAGS_KEYDOWN = 
	{
		private _key = _this select 1;
		private _handled = false;
		if(_key == WHA_NAMETAGS_ACTIONKEY_ID) then
		{
			WHA_NAMETAGS_ON = !WHA_NAMETAGS_ON;
			_handled = true;
		};
		_handled;
	};

	//	Function that will determine when the disableKey is released.
	WHA_NAMETAGS_KEYUP = 
	{
		private _key = _this select 1;
		private _handled = false;
		if(_key == WHA_NAMETAGS_ACTIONKEY_ID) then
		{
			_handled = true;
		};
		_handled;
	};
	
	//	Add eventhandlers (functions above).
	(findDisplay 46) displayAddEventHandler   ["keydown", "_this call WHA_NAMETAGS_KEYDOWN"];
	(findDisplay 46) displayAddEventHandler   ["keyup", "_this call WHA_NAMETAGS_KEYUP"];
};