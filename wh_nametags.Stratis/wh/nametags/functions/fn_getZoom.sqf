// ====================================================================================
//
//	fn_getZoom.sqf - Gets player zoom, where default is 1.0
//	> call wh_nt_fnc_getZoom; <
//
//	Adapted from code by Killzone Kid.
//	http://killzonekid.com/arma-scripting-tutorials-get-zoom/
//
// ====================================================================================

(
	(
		[0.5,0.5] 
		distance2D  
		worldToScreen 
		positionCameraToWorld 
		[0,3,4]
	) * (
		getResolution 
		select 5
	) / 2
) + 0.66666
