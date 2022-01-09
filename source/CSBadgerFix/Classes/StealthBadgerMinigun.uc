//=============================================================================
// StealthBadgerMinigun.
//=============================================================================
class StealthBadgerMinigun extends BadgerMinigun;

state InstantFireMode
{
    function Fire(Controller C)
    {
		Super.Fire(C);
		StealthBadger(Instigator).WeaponFired();
    }

    function AltFire(Controller C)
    {
		Super.AltFire(C);
		StealthBadger(Instigator).WeaponFired();
    }
}

defaultproperties
{
}
