//=============================================================================
// LockerWeaponsPlayerStart
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:41:38 in Package: UltimateMappingTools$
//
// This PlayerStart equips the spawning player with the weapons from the closest
// WeaponLocker in the specified range.
// The Event is triggered when the player spawns.
//=============================================================================
class LockerWeaponsPlayerStart extends TriggeredPlayerStart;


var()  float MaxWeaponLockerDistance ;
// The player will spawn with the weapons from the closest WeaponLocker within
// this distance.

var()  bool bAlwaysRefreshClosestLocker ;
/* Enabling this will perform a check to find the closest Locker every time
 * a player respawns. This allows to always use the closest Locker in case that
 * this PlayerStart is attached to a Mover and moves away from it's initial location.
 * However, performing the check is processing intense, so you should disable this
 * if the PlayerStart is not attached to a Mover.
 */

var() edfindable WeaponLocker AssignLocker ;
// Always use the locker that is specified here. Search for a locker in radius
// at runtime if none is specified. Overrides bAlwaysRefreshClosestLocker.





/* Intern */
var  WeaponLocker  BestLocker ; // The closest WeaponLocker found in proximity.



//=============================================================================
event BeginPlay()
{
    local LockerWeaponsPlayerStartSpawnNotifier LWPSSN;

    foreach AllActors(class'LockerWeaponsPlayerStartSpawnNotifier', LWPSSN){break;}

    if (LWPSSN == None)
        LWPSSN = Spawn(class'LockerWeaponsPlayerStartSpawnNotifier',,'LWPSSN');

    Event = 'LWPSSN';
}

event PostBeginPlay()
{
    if (AssignLocker != None)
        BestLocker = AssignLocker;
    else
    {
        if (!bAlwaysRefreshClosestLocker)
            BestLocker = FindClosestLocker(Location, MaxWeaponLockerDistance);
    }
}


function EquipSpawnedPlayer(Pawn P)
{
    if (P != None)
    {
        if (MaxWeaponLockerDistance > 0)
        {
            if (bAlwaysRefreshClosestLocker && AssignLocker != None)
                BestLocker = FindClosestLocker(self.Location, MaxWeaponLockerDistance);

            if (BestLocker != None)
            {
                BestLocker.Touch(P);
            }
        }
    }
}


function WeaponLocker FindClosestLocker(vector StartLocation, float SearchRadius)
{
    local WeaponLocker ClosestLocker, Locker;

    foreach RadiusActors(class 'WeaponLocker', Locker, SearchRadius)
    {
        if (ClosestLocker == None)
            ClosestLocker = Locker;
        else if (VSize(StartLocation - ClosestLocker.Location) > VSize(StartLocation - Locker.Location))
            ClosestLocker = Locker;
    }

    return ClosestLocker;
}

defaultproperties
{
     MaxWeaponLockerDistance=1000.000000
     Event="'"
}
