//=============================================================================
// StealthBadgerTurret.
//=============================================================================
class StealthBadgerTurret extends BadgerTurret;

state ProjectileFireMode
{
    function Fire(Controller C)
    {
		Super.Fire(C);
		StealthBadger(ONSWeaponPawn(Instigator).VehicleBase).WeaponFired();
	}
}

defaultproperties
{
}
