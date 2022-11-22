//=============================================================================
// VehicleSpawnProtectionTimer
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:48:01 in Package: UltimateMappingTools$
//
// Disables spawn protection for the vehicle after a fixed amount of time after
// the vehicle was spawned.
//=============================================================================
class VehicleSpawnProtectionTimer extends Info;

event Timer()
{
    if (SVehicle(Owner) != None)
        SVehicle(Owner).bSpawnProtected = false;
    else
        Destroy();
}

defaultproperties
{
}
