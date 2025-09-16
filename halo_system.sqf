//Global HALO subscriber array
halo_players = [];
publicVariable "halo_players";


fnc_halo_addPlayer = {
    params ["_unit"];
    if (!(_unit in halo_players)) then {
        halo_players pushBack _unit;
        publicVariable "halo_players";
        [_unit, "Subscribed to next jump"] remoteExec ["hint", _unit];
    };
};

fnc_halo_removePlayer = {
    params ["_unit"];
    if (_unit in halo_players) then {
        halo_players = halo_players - [_unit];
        publicVariable "halo_players";
        [_unit, "Unsubscribed from next jump"] remoteExec ["hint", _unit];
    };
};

fnc_getHaloMarkerPos = {
	params ["_markertext"];
    private _targetText = _markertext;   // text players must type in marker name
    private _foundPos = [];

    {
        if ((markerText _x) isEqualTo _targetText) exitWith {
            _foundPos = getMarkerPos _x;
        };
    } forEach allMapMarkers;

    _foundPos
};


fnc_getDirection = {
    params ["_startPos", "_endPos"];

    private _dx = (_endPos select 0) - (_startPos select 0);
    private _dy = (_endPos select 1) - (_startPos select 1);

    private _dir = (_dx atan2 _dy);   // atan2 returns degrees
    if (_dir < 0) then {_dir = _dir + 360}; // keep it in [0,360)

    _dir
};


fnc_halo_launch = {
    private _planeType = "RHS_C130J"; 
    private _plane_height = 10000; // Height above the marker to spawn the plane
    private _plane_speed = 70; // Speed of the plane in m/s
    private _destination_distance_offset = 2000; // Distance beyond the DZ marker to fly to
    private _spawnPos = ["HALO_START"] call fnc_getHaloMarkerPos;
	if (_spawnPos isEqualTo []) exitWith {
		["No HALO start marker found on the map! Must be called 'HALO_START'"] remoteExec ["hint", 0];
	};

	_adjusted_spawnPos = _spawnPos vectorAdd [0,0,_plane_height+300]; //adding height to the map marker

    private _destPos = ["HALO_END"] call fnc_getHaloMarkerPos;
    if (_destPos isEqualTo []) exitWith {
        ["No HALO marker found on the map! Must be called 'HALO_END'"] remoteExec ["hint", 0];
    };

    private _dir = [_spawnPos, _destPos] call fnc_getDirection;

    // Calcola la posizione 1km oltre il DZ nella stessa direzione
    private _rad = _dir * (pi / 180); // Convert to radians

    // Create plane
    private _plane = createVehicle [_planeType, _adjusted_spawnPos, [], 0, "FLY"];
    _plane setPosASL _adjusted_spawnPos;
    createVehicleCrew _plane;
    _plane flyInHeight _plane_height;

    _plane_x_velocity = _plane_speed * sin _rad;
    _plane_y_velocity = _plane_speed * cos _rad;
    _plane setVelocity [_plane_x_velocity, _plane_y_velocity, 0]; // Initial forward velocity
    _plane setDir _dir;

    // Load players
    {
        if (alive _x) then {
            removeBackpack _x;
            _x addBackpack "B_Parachute";
            _x moveInCargo _plane;
        };
    } forEach halo_players;

    ["HALO plane spawned and boarding complete!"] remoteExec ["hint", 0];

    // Give AI pilot a waypoint towards the marker position
    private _grp = group driver _plane;
    private _wp = _grp addWaypoint [_destPos, 0];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "CARELESS";
    _wp setWaypointSpeed "LIMITED";

    // Reset
    halo_players = [];
    publicVariable "halo_players";

    systemChat format ["Variable dump: _spawnPos: %1, _destPos: %2, _dir: %3, _rad: %4, _plane_x_velocity: %5, _plane_y_velocity: %6", _spawnPos, _destPos, _dir, _rad, _plane_x_velocity, _plane_y_velocity];
};




