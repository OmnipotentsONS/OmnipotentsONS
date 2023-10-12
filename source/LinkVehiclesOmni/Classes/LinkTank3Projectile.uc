// ============================================================================
// Link Tank projectile.
// ============================================================================
class LinkTank3Projectile extends PROJ_LinkTurret_Plasma;

// ============================================================================

defaultproperties
{
     //VehicleDamageMult=1.75000
     // VehicleDamageMult=4.000000 Link Turret Plasma default!
     VehicleDamageMult=1.00000  // this I don't think works except on turrets?
     Speed=5000.000000
     MaxSpeed=5000.000000
     Damage=55.000000
     DamageRadius=300.000000
     MomentumTransfer=5000.000000
     MyDamageType=Class'LinkVehiclesOmni.DamTypeLinkTank3Plasma'
}
