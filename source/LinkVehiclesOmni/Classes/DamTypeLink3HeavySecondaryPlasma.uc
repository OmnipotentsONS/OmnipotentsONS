// ============================================================================
// Link Tank Turret Plasma Damage
// ============================================================================
class DamTypeLink3HeavySecondaryPlasma extends DamTypeLinkTurretPlasma
	abstract;

// ============================================================================

defaultproperties
{
     VehicleClass=Class'LinkTank3HeavySecondaryTurretPawn'
     DeathString="%o swallowed some of %k's steaming hot plasma."
     FemaleSuicide="%o swallowed her own plasma."
     MaleSuicide="%o swallowed his own plasma."
     VehicleDamageScaling = 1.75
}
