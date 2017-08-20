//====================================================================================
//
//	fn_isTalking.sqf - Detect whether player is talking with ACRE/TFAR/Vanilla.
//	> _isTalking = _unit call wh_nt_fnc_isTalking <
//
//	Adapted from code by Killzone Kid, and from ACE3 code.
//	- http://killzonekid.com/arma-scripting-tutorials-whos-talking/
//	- https://github.com/acemod/ACE3
//
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Initial setup.
//------------------------------------------------------------------------------------

//	The unit passed through the function.
params["_unit"];

//	If the unit is dead, exit.
if !(alive _unit) exitWith {false};

//	Establish variable that will change depending on whether unit is speaking.
_isSpeaking = false;


//------------------------------------------------------------------------------------
//	Switch between checks depending on which radio mod(s) are present.
//------------------------------------------------------------------------------------

//	Case where ACRE is present.
if WH_NT_MOD_ACRE then
{
	if ([_unit] call acre_api_fnc_isSpeaking) then
	{ _isSpeaking = true };
};

//	Case where TFAR is present.
if WH_NT_MOD_TFAR then
{
	if (_unit getVariable ["tf_isSpeaking", false]) then
	{ _isSpeaking = true };
};

//	Case for vanilla in-game comms.
//	TBD. Will be tested first on CBAless / MODless branch.

_isSpeaking