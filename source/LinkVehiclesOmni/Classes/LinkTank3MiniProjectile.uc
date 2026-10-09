// ============================================================================
// Link Tank projectile.
// ============================================================================
class LinkTank3MiniProjectile extends PROJ_LinkTurret_Plasma;

// ============================================================================

defaultproperties
{
     //VehicleDamageMult=1.75000
     // VehicleDamageMult=4.000000 Link Turret Plasma default!
     VehicleDamageMult=1.00000  // this I don't think works except on turrets?
     Speed=8500.00000 // 5000
     MaxSpeed=8500.00000 // 5000
     Damage=42.000000  // link gun is 30, Regular link tank is 55
     DamageRadius=225.000000
     MomentumTransfer=5000.000000
     MyDamageType=Class'LinkVehiclesOmni.DamTypeLinkTank3Plasma'
     DrawScale=0.67
}
