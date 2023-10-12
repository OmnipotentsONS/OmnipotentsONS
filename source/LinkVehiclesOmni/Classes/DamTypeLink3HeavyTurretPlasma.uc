// ============================================================================
// ONS Link Turret Plasma Damage
// ============================================================================
class DamTypeLink3HeavyTurretPlasma extends DamTypeLinkTurretPlasma
	abstract;

// ============================================================================

defaultproperties
{
     VehicleClass=Class'LinkVehiclesOmni.LinkTank3Heavy'
     DeathString="%o gulped down heavy loads of %k's steaming hot Link Turret plasma."
     FemaleSuicide="%o gulped down her own plasma."
     MaleSuicide="%o gulped down his own plasma."
     VehicleDamageScaling = 1.6
}
