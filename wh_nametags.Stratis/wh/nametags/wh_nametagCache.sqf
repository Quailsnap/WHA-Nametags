WH_NT_CACHE_ENTS = [];
WH_NT_CACHE_DATA = [];
WH_NT_CACHE_NAMES = [];

//	Establish variable that will be used to keep track of Arma's day/night cycle.
WH_NT_VAR_NIGHT = 1;

//	...and one for whether the player is in a vehicle.
WH_NT_VAR_INVEHICLE = false;

WH_NT_CACHE_LOOP =
[
	{
		if WH_NT_NAMETAGS_ON then
		{
			//	Check the day night cycle...
			WH_NT_VAR_NIGHT = if WH_NT_NIGHT then
			{ linearConversion [0, 1, sunOrMoon, 0.25+0.5*(currentVisionMode player),1,true]; } else { 1 };
		
			//	...check if the player is in a vehicle...
			WH_NT_VAR_INVEHICLE = !(isNull objectParent player);
			
			//	Update the cache of nearEntities.
			private _data = [];
			private _dataNames = [];
			private _unitData = [];
			private _group = group player;
			private _sameGroup;
			private _name;
			private _role;
			private _nameColor;
			private _team;
			
			private _entities = 
			if !WH_NT_DRAWCURSORONLY then
			{
				player nearEntities [["CAManBase","LandVehicle","Helicopter","Plane","Ship_F"], 
				((WH_NT_DRAWDISTANCE_NEAR+(WH_NT_DRAWDISTANCE_NEAR*0.25)+1)*WH_NT_VAR_NIGHT)] 
				select 	
				{
					!(_x isEqualTo player) &&
					{(
						(side group _x isEqualTo side group player) 	// 0.0018ms
						//((side _x getFriend side player) > 0.6) 		// 0.0024ms
						//|| {(group _x isEqualTo group player)}
					)} 
				}
			}
			else { [] };

			{
				_unit = _x;
				{
					_unitData = [];
					_sameGroup = (group _x isEqualTo _group);
					_name = name _x;

					//	Get the crew's role, if present.
					_role = if (isNull objectParent _x) then { "" } else { call
					{
						if ( commander	_unit isEqualTo _x ) exitWith {"Commander"};
						if ( gunner		_unit isEqualTo _x ) exitWith {"Gunner"};
						if ( !(driver	_unit isEqualTo _x)) exitWith {""};
						if ( driver		_unit isEqualTo _x && {!(_unit isKindOf "helicopter") && {!(_unit isKindOf "plane")}} ) exitWith {"Driver"};
						if ( driver		_unit isEqualTo _x && { (_unit isKindOf "helicopter") || { (_unit isKindOf "plane")}} ) exitWith {"Pilot"};
						""
					}};
					
					_nameColor = 
					if (_role isEqualTo "") 
					then { + WH_NT_FONT_COLOR_DEFAULT }
					//	...and for vehicle crew, where a role is already present.
					else { + WH_NT_FONT_COLOR_CREW };

					//	For units in the same group as the player, set their color according to color team.
					if (_sameGroup) then 
					{ 
						_team = assignedTeam _x;
						_nameColor = switch (_team) do 
						{
							case "RED": 	{	+WH_NT_FONT_COLOR_GROUPR	};
							case "GREEN": 	{	+WH_NT_FONT_COLOR_GROUPG	};
							case "BLUE": 	{	+WH_NT_FONT_COLOR_GROUPB	};
							case "YELLOW": 	{	+WH_NT_FONT_COLOR_GROUPY	};
							default			{	+WH_NT_FONT_COLOR_GROUP		};
						};
					};

					//	If they're running colorblind, reset the nameColor to a nice white one.
					if (WH_NT_FONT_COLORBLIND) then { _nameColor =+ WH_NT_FONT_COLOR_OTHER };
	 
					_unitData pushBack _name;
					_unitData pushBack _nameColor;
					_unitData pushBack _role;
										
					_dataNames pushBack _x;
					_data append [_unitData];
				} forEach (crew _unit select {!(_x isEqualTo player)});
			} count _entities;
			
			WH_NT_CACHE_DATA =+ _data;
			WH_NT_CACHE_NAMES =+ _dataNames;
			WH_NT_CACHE_ENTS =+ _entities;
		};
	},
	0.5,
	[]
] call CBA_fnc_addPerFrameHandler;