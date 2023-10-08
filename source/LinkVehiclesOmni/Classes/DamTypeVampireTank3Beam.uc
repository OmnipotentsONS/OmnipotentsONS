// ============================================================================
// Link Tank Beam Damage
// ============================================================================
class DamTypeVampireTank3Beam extends DamTypeLinkTurretBeam
	abstract;

// ============================================================================

defaultproperties
{
     VehicleClass=Class'LinkVehiclesOmni.VampireTank3'
     DeathString="%o was exsanguinated by %k's Vampire Tank."
     FemaleSuicide="%o sucked herself dry..."
     MaleSuicide="%o sucked himself dry..."
     VehicleDamageScaling=1.0
}
