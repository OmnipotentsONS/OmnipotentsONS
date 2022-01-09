class CSShieldMechDamTypeShieldImpact extends VehicleDamageType
	abstract;

defaultproperties
{
    DeathString="%o was pulverized by %k's mega shield gun."
	MaleSuicide="%o threw his weight around once too often."
	FemaleSuicide="%o threw her weight around once too often."
    DamageOverlayMaterial=Material'XGameShaders.PlayerShaders.LinkHit'
    DamageOverlayTime=0.5

    VehicleClass=class'CSMech.CSShieldMech'
    bDetonatesGoop=true

	bKUseOwnDeathVel=true
	KDeathVel=450
	KDeathUpKick=300

    VehicleMomentumScaling=1.0
}