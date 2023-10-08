// ============================================================================
// Link Tank Beam Damage
// ============================================================================
class DamTypeLinkTank3HeavyBeam extends DamTypeLinkTurretBeam
	abstract;

// ============================================================================

defaultproperties
{
     VehicleClass=Class'LinkVehiclesOmni.LinkTank3Heavy'
     DeathString="%o received the long, thick green shaft of %k's Link Tank."
     FemaleSuicide="%o gave herself the shaft... oh dear"
     MaleSuicide="%o gave himself the shaft... oh dear"
     VehicleDamageScaling=1.30
}
