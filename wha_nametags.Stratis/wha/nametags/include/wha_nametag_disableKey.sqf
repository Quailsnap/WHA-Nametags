//====================================================================================
//
//	wha_nametag_disableKey.sqf - Sets up a key that can be used to flip the nametag
//							   system on and off with a press.
//
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Setup the Action Key, default '='.
//------------------------------------------------------------------------------------

//	None of this will execute if the actionkey line in CONFIG is commented out.
if (!isNil "WHA_NAMETAG_ACTIONKEY") then
{
	WHA_NAMETAG_ACTIONKEY_ID = (actionKeys WHA_NAMETAG_ACTIONKEY) select 0;// This key, a global variable.
	WHA_NAMETAG_ACTIONKEY_NAME = actionKeysNames WHA_NAMETAG_ACTIONKEY;	// Which is named this...
	
	//	Function that will determine when the disableKey is depressed.
	WHA_NAMETAG_KEYDOWN = 
	{
		_key = _this select 1;
		_handled = false;
		if(_key == WHA_NAMETAG_ACTIONKEY_ID) then
		{
			WHA_NAMETAG_ON = !WHA_NAMETAG_ON;
			_handled = true;
		};
		_handled;
	};

	//	Function that will determine when the disableKey is released.
	WHA_NAMETAG_KEYUP = 
	{
		_key = _this select 1;
		_handled = false;
		if(_key == WHA_NAMETAG_ACTIONKEY_ID) then
		{
			_handled = true;
		};
		_handled;
	};
	
	//	Add eventhandlers (functions above).
	(findDisplay 46) displayAddEventHandler   ["keydown", "_this call WHA_NAMETAG_KEYDOWN"];
	(findDisplay 46) displayAddEventHandler   ["keyup", "_this call WHA_NAMETAG_KEYUP"];
};