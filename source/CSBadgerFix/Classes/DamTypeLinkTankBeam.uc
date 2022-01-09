// ============================================================================
// Link Tank Beam Damage
// ============================================================================
class DamTypeLinkTankBeam extends DamTypeLinkTurretBeam
	abstract;

// ============================================================================

defaultproperties
{
     VehicleClass=Class'CSBadgerFix.ONSLinkTank'
     DeathString="%o received the long green shaft of %k's Link Tank."
     FemaleSuicide="%o gave herself the shaft... oh dear"
     MaleSuicide="%o gave himself the shaft... oh dear"
}
