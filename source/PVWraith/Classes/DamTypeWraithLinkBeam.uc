

class DamTypeWraithLinkBeam extends PVWMessageProxyDamageType abstract;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     MessageSourceDamageType=Class'XWeapons.DamTypeLinkShaft'
     VehicleClass=Class'PVWraith.WraithLinkTurretPawn'
     bDetonatesGoop=True
     bSkeletize=True
     bCausesBlood=False
     bLeaveBodyEffect=True
     VehicleDamageScaling=1.33
     VehicleMomentumScaling=1.20
}
