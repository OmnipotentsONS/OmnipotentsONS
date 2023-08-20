// ============================================================================
// ONS Link Turret Beam Damage
// ============================================================================
class DamTypeLinkTank3TurretLasers extends DamTypeLinkTurretBeam
	abstract;

// ============================================================================

defaultproperties
{
     VehicleClass=Class'LinkVehiclesOmni.LinkTank3'
     DeathString="%o got poked by long, thick green shafts of %k's Link Laser Turret."
     FemaleSuicide="%o gave herself the shaft... oh dear"
     MaleSuicide="%o gave himself the shaft... oh dear"
     VehicleDamageScaling=1.5
}
