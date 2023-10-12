// ============================================================================
// Link Tank Plasma Damage
// ============================================================================
class DamTypeLinkTank3Plasma extends DamTypeLinkTurretPlasma
	abstract;

// ============================================================================

defaultproperties
{
     VehicleClass=Class'LinkVehiclesOmni.LinkTank3'
     DeathString="%o choked down some of %k's steaming hot Link Tank plasma."
     FemaleSuicide="%o gulped down her own plasma."
     MaleSuicide="%o gulped down his own plasma."
     VehicleDamageScaling=1.5
}
