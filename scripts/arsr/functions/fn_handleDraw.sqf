params ["_originatorPos", "_inAccurateOriginalPos", "_interceptPos", "_shotKey"];

if ((arsr_posCache getOrDefault [_shotKey, []]) isEqualTo []) then {
    systemChat "Artillery shot detected! Drawing on map!";
    if (arsr_drawStyle > 0) then {
        private _old = arsr_autoDeleteMarkerTime;
        arsr_autoDeleteMarkerTime = -1;
        private _marker = [_originatorPos, "", _originatorPos] call arsr_fnc_initMarker;
        arsr_autoDeleteMarkerTime = _old;
        _marker setMarkerPosLocal _inAccurateOriginalPos;
        _marker setMarkerTypeLocal "mil_destroy";
        _marker setMarkerColorLocal arsr_markerColor;
        _marker setMarkerTextLocal (format ["Approx artillery position [%1]", [daytime, "HH:MM:SS"] call BIS_fnc_timeToString]);
        arsr_posCache set [_shotKey, [_inAccurateOriginalPos]];
        arsr_posCache set [_shotKey + "#marker", _marker];
        [{
            arsr_posCache set [_this, nil];
            arsr_posCache set [_this + "#marker", nil];
        }, _shotKey, 60] call CBA_fnc_waitAndExecute ;
    };
};

if (arsr_drawStyle > 0) then {
    private _arr = arsr_posCache get _shotKey;
    private _marker = arsr_posCache get (_shotKey + "#marker");
    _arr pushBackUnique _inAccurateOriginalPos;
    private _pos = [0, 0, 0];
    {
        _pos = _pos vectorAdd _x;
    } forEach _arr;
    _marker setMarkerPosLocal (_pos vectorMultiply (1 / count _arr));
};

switch (arsr_drawStyle) do {
    case 0: arsr_fnc_drawArrows;
    case 1: arsr_fnc_drawLines;
    case 2: arsr_fnc_drawCones;
    default arsr_fnc_drawArrow;
};
