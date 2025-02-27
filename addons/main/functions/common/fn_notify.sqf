#include "..\..\script_component.hpp"

/*
Function:
    FFPP_fnc_notify

Description:
    Punishes the player given for FF.
    Doesn't do the checking itself, refer to FFPP_fnc_checkIncident.

Scope:
    <SERVER>

Environment:
    <UNSCHEDULED> Suspension may cause simultaneous read then write of the players FF stats, leading to the last call taking preference.

Parameters:
    <OBJECT> Player that is being verified for FF.
    <NUMBER> The amount of time to add to the players total sentence time.
    <NUMBER> Raise the player's total offence level by this percentage. (100% total = Ocean Gulag).
    <OBJECT> [OPTIONAL] The victim of the player's FF.

Returns:
    <STRING> Either an exemption type or a return from fn_punishment.sqf.

Examples:
    [_instigator,_timeAdded,_offenceAdded,_victim] remoteExec ["FFPP_fnc_notify",2,false]; // How it should be called from another FFPP_fnc_checkIncident.
    // Unit Tests:
    [cursorObject, 0, 0] remoteExec ["FFPP_fnc_notify",2];                                 // Ping with FF Warning
    [cursorObject,120, 1] remoteExec ["FFPP_fnc_notify",2];                                // Punish, 120 additional seconds
    [player,10, 1] remoteExec ["FFPP_fnc_notify",2];                                       // Test Self Punish, 10 additional seconds
    // Function that goes hand-in-hand
    [cursorObject,"forgive"] remoteExec [FFPP_fnc_notify_release,2]; // Forgive all sins

Author: Caleb Serafin
License: MIT License, Copyright (c) 2020 Official AntiStasi Community
*/
params ["_instigator",["_victim",objNull],["_customMessage",""]];
private _filename = "fn_punishment.sqf";

//////////////Enable Switches///////////////
if (isNil QSET(enabled)) then { SET(enabled) = true; };
if (isNil QSET(tellInstigator)) then { SET(tellInstigator) = false; };
if (isNil QSET(tellVictim)) then { SET(tellVictim) = false; };
if (isNil QSET(tellAdmin)) then { SET(tellAdmin) = true; };

//////////Fetches punishment values/////////
private _UID = getPlayerUID _instigator;
private _name = name _instigator;
private _currentTime = (floor serverTime);
private _keyPairs = [["offenceTotal",0],["lastOffenceTime",_currentTime]];
([_UID,_keyPairs] call FFPP_fnc_dataGet) params ["_offenceTotal","_lastTime"];

///////////////Data validation//////////////
_lastTime = (0 max _lastTime) min _currentTime;
_offenceTotal = ceil (0 max _offenceTotal);

//////////////FF smain addition/////////////
_offenceTotal = _offenceTotal + 1;

//////////Saves data to instigator//////////
private _keyPairs = [["offenceTotal",_offenceTotal],["lastOffenceTime",_currentTime],["name",_name],["player",_instigator]];
[_UID,_keyPairs] call FFPP_fnc_dataSet;

///////////////Victim Notifier//////////////
private _injuredComrade = "";
private _victimStats = "damaged systemPunished [AI]";
if (_victim isKindOf "Man") then {
    _injuredComrade = ["Injured comrade: ",name _victim] joinString "";
    if (SET(tellVictim) && isPlayer _victim) then {
        ["FF Notification", [_name," hurt you!"] joinString ""] remoteExec ["FFPP_fnc_customHint", _victim, false];
    };
    private _UIDVictim = ["AI", getPlayerUID _victim] select (isPlayer _victim);
    _victimStats = ["damaged ",name _victim," [",_UIDVictim,"]"] joinString "";
};

/////////////Instigator Notifier////////////
private _playerStats = ["Offences: ",str _offenceTotal,", Seconds since last FF: ",str _lastTime,", Custom message: ", _customMessage] joinString "";
[2, ["WARNING | ",_name," [",_UID,"] ",_victimStats,", ",_playerStats] joinString "", _filename] call FFPP_fnc_log;

if (SET(tellInstigator)) then {
    ["FF Warning", ["Watch your fire!",_injuredComrade,_customMessage] joinString "<br/>"] remoteExec ["FFPP_fnc_customHint", _instigator, false];
};

if (SET(tellAdmin)) then {
    private _admin = [] call FFPP_fnc_getAdmin;
    if (!isNull _admin) then {
        ["FF Notification", [_name," has been found guilty of FF.<br/>Total Offences: ",str _offenceTotal, "<br/>Victim: ",name _victim] joinString ""] remoteExec ["FFPP_fnc_customHint",_admin,false];
    };
};

"WARNING";
