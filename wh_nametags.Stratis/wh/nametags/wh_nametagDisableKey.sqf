if (!isNil "WH_NT_ACTIONKEY") then
{
	WH_NT_ACTIONKEY_KEY = (actionKeys WH_NT_ACTIONKEY) select 0;// This key, a global variable.
	WH_NT_ACTIONKEY_KEYNAME = actionKeysNames WH_NT_ACTIONKEY;	// Which is named this...
	
	// Function that will determine when the disableKey is depressed.
	WH_NT_KEYDOWN = 
	{
		_key = _this select 1;
		_handled = false;
		if(_key == WH_NT_ACTIONKEY_KEY) then
		{
			WH_NT_NAMETAGS_ON = !WH_NT_NAMETAGS_ON;
			_handled = true;
		};
		_handled;
	};

	// Function that will determine when the disableKey is released.
	WH_NT_KEYUP = 
	{
		_key = _this select 1;
		_handled = false;
		if(_key == WH_NT_ACTIONKEY_KEY) then
		{
			_handled = true;
		};
		_handled;
	};
	
	// Add eventhandlers (functions above).
	(findDisplay 46) displayAddEventHandler   ["keydown", "_this call WH_NT_KEYDOWN"];
	(findDisplay 46) displayAddEventHandler   ["keyup", "_this call WH_NT_KEYUP"];
};