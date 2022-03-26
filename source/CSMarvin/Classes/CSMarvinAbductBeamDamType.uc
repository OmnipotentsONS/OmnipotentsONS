class CSMarvinAbductBeamDamType extends VehicleDamageType
	abstract;

defaultproperties
{
	DeathString="%o got beamed up by %k"
	MaleSuicide="%o fried himself with his own transporter beam."
	FemaleSuicide="%o fried herself with her own transporter beam."
	FlashFog=(X=700.00000,Y=0.000000,Z=0.00000)

    DamageOverlayMaterial=Material'XGameShaders.PlayerShaders.LinkHit'
    DamageOverlayTime=1.0
	bDetonatesGoop=true
	bDelayedDamage=true
	VehicleClass=class'CSMarvin'
    VehicleDamageScaling=1.0
    VehicleMomentumScaling=1.0
}
