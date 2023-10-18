// ============================================================================
// ONS Link Turret Beam Damage
// ============================================================================
class DamTypeLinkTank3HeavyTurretLasers extends DamTypeLinkTurretBeam
	abstract;

// ============================================================================

defaultproperties
{
     VehicleClass=Class'LinkVehiclesOmni.LinkTank3Heavy'
     DeathString="%o got poked by long, thick, heavy green shafts of %k's Link Laser Turret."
     FemaleSuicide="%o gave herself the shaft... oh dear"
     MaleSuicide="%o gave himself the shaft... oh dear"
     VehicleDamageScaling=1.0 // DO ANY SCALING IN THE TURRET CLASS SINCE ITS SCALED ON LINKERS.
}
