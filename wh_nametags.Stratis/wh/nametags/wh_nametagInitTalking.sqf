//====================================================================================
//
//	wh_nametagInitTalking.sqf - Places monitors on all players to check if they are
//								speaking.
//
//	Adapted from code by Killzone Kid, and from ACE3 code.
//	- http://killzonekid.com/arma-scripting-tutorials-whos-talking/
//	- https://github.com/acemod/ACE3
//
//	Code previously from CSE. Credit to commy2.
//
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	CBA version, if CBA is present.
//------------------------------------------------------------------------------------

if WH_NT_MOD_CBA then
{
	[{
		private ["_old", "_new"];
		_old = player getVariable ["wh_nt_isSpeaking", false];
		_new = (!(isNull findDisplay 55));
		if (!(_oldSetting isEqualTo _newSetting)) then {
			ACE_player setVariable ["wh_nt_isSpeaking", _newSetting, true];
		};
	} , 0.1, []] call CBA_fnc_addPerFrameHandler;
};

//------------------------------------------------------------------------------------
//	Scheduled version, if CBA is not present.
//------------------------------------------------------------------------------------