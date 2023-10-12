// ============================================================================
// Link Tank projectile.
// ============================================================================
class LinkTank3HeavyProjectile extends PROJ_LinkTurret_Plasma;

// ============================================================================


defaultproperties
{
     VehicleDamageMult=1.00000  // this I don't think works except on turrets?
     Speed=5000.000000
     MaxSpeed=5000.000000
     Damage=66.000000
     DamageRadius=450.000000
     MomentumTransfer=8000.000000
     MyDamageType=Class'LinkVehiclesOmni.DamTypeLinkTank3HeavyPlasma'
}
