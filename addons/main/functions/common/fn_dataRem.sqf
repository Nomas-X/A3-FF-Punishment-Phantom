/*
Function:
    FFPP_fnc_dataRem

Description:
    1. Removes specified keys in a UID entry;
    2. Or removes an entire UID entry from _dataNamespace.

Scope:
    <ANY>

Environment:
    <ANY>

Parameters 1:
    <STRING> UID of entry.
    <ARRAY<STRING>> List of keys to remove.

Parameters 2:
    <STRING> UID to remove.
    <ARRAY> Empty array.

Returns:
    <BOOLEAN> true if it hasn't crashed; false is invalid params; nil if it has crashed.

Examples:
    private _keys = ["test","420"];
    private _UID = "123";
    [_UID,_keys] call FFPP_fnc_dataRem; // Removes keys "test" and "frost" in UID "123"
    [_UID,[]] call FFPP_fnc_dataRem;    // Removes UID "123" and all it's keys from _dataNamespace

Author: Caleb Serafin
Date Updated: 27 May 2020
License: MIT License, Copyright (c) 2020 Official AntiStasi Community
*/
params [
    ["_UID",objNull,["UID string",objNull]],
    ["_keys",[],[ [] ]]
];
private _filename = "fn_dataRem.sqf";

if (typeName _UID == "OBJECT" && {isPlayer _UID}) then {
    _UID = getPlayerUID _UID;
};
if (typeName _UID != "STRING" || {_UID in ["","dataNamespace"]}) exitWith {
    [1, format ["INVALID PARAMS | _UID=""%1""", _UID], _filename] remoteExecCall ["FFPP_fnc_log",2,false];
    false;
};

private _data_namespace = call FFPP_fnc_dataNamespace;
if (_keys isEqualTo []) exitWith {
    _data_namespace setVariable [_UID, nil, true];
    true;
};
private _data_UID = _data_namespace getVariable [_UID, [] ];

private _key = "";
{
    _key = _x;
    _data_UID deleteAt (_data_UID findIf {(_x#0) == _key});
} forEach _keys;
_data_namespace setVariable [_UID, _data_UID, true];
true;