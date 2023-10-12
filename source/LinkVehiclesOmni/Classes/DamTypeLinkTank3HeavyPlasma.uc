// ============================================================================
// Link Tank Plasma Damage
// ============================================================================
class DamTypeLinkTank3HeavyPlasma extends DamTypeLinkTurretPlasma
	abstract;

// ============================================================================

defaultproperties
{
     VehicleClass=Class'LinkVehiclesOmni.LinkTank3Heavy'
     DeathString="%o choked down some of %k's steaming hot Link Tank plasma."
     FemaleSuicide="%o gulped down her own plasma."
     MaleSuicide="%o gulped down his own plasma."
     VehicleDamageScaling = 1.50
     // VehicleDamageMult also set in PROJ_LinkTurret_Plasama don't need it twice
}
