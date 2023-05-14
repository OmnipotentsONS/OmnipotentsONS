// ============================================================================
// ONS Link Turret Plasma Damage
// ============================================================================
class DamTypeLink3TurretPlasma extends DamTypeLinkTurretPlasma
	abstract;

// ============================================================================

defaultproperties
{
     VehicleClass=Class'LinkVehiclesOmni.LinkTank3'
     DeathString="%o gulped down loads of %k's steaming hot Link Turret plasma."
     FemaleSuicide="%o gulped down her own plasma."
     MaleSuicide="%o gulped down his own plasma."
     VehicleDamageScaling = 1.25
}
