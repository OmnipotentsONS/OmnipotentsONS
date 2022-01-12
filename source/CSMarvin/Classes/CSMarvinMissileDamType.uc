class CSMarvinMissileDamType extends VehicleDamageType
	abstract;

defaultproperties
{
	DeathString="%k's Q-36 filled %o with plasma."
	MaleSuicide="%o fried himself with his own plasma blast."
	FemaleSuicide="%o fried herself with her own plasma blast."
	FlashFog=(X=700.00000,Y=0.000000,Z=0.00000)

    DamageOverlayMaterial=Material'XGameShaders.PlayerShaders.LinkHit'
    DamageOverlayTime=1.0
	bDetonatesGoop=true
	bDelayedDamage=true
	VehicleClass=class'CSMarvin'
}
