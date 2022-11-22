//=============================================================================
// LockerWeaponsPlayerStartSpawnNotifier
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:18:19 in Package: UltimateMappingTools$
//
// This is a hack to get the LockerWeaponsPlayerStart to work.
// The PlayerStart itself doesn't get any notification when a player spawns there
// but the GameInfo triggers the Event of the PlayerStart where the player was
// spawned.
//
// So we simply let every LockerWeaponsPlayerStart trigger us and then re-route
// the necessary information to him, because that is given with the TriggerEvent.
//=============================================================================
class LockerWeaponsPlayerStartSpawnNotifier extends Info;

event Trigger(Actor Other, Pawn EventInstigator)
{
    if (LockerWeaponsPlayerStart(Other) != None)
        LockerWeaponsPlayerStart(Other).EquipSpawnedPlayer(EventInstigator);
}

defaultproperties
{
}
