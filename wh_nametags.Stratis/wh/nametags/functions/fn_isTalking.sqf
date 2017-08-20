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


//------------------------------------------------------------------------------------
//	Switch between checks depending on which radio mod(s) are present.
//------------------------------------------------------------------------------------

//	Get variable broadcast across server.
_isSpeaking = _unit getVariable ["wh_isSpeaking",false]

//	Return value.
_isSpeaking