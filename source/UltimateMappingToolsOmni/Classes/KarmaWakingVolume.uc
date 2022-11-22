//-----------------------------------------------------------------------------
// KarmaWakingVolume
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:40:59 in Package: UltimateMappingTools$
//
// Wakes Vehicles and KActors up when they are inside the volume and forces
// them to update their location this way. Use this for vehicle lifts.
//-----------------------------------------------------------------------------
class KarmaWakingVolume extends Volume;

simulated event Tick(float DeltaTime)
{
    local Actor A;

    foreach TouchingActors (class'Actor', A)
    {
        if (Pawn(A) != None || KActor(A) != None)
        {
            A.KWake();
        }
    }
}

defaultproperties
{
     bStatic=False
}
