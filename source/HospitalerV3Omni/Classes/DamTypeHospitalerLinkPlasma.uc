class DamTypeHospitalerLinkPlasma extends VehicleDamageType
	abstract;

defaultproperties
{
     VehicleClass=Class'HospitalerV3Omni.HospitalerV3Omni'
     DeathString="%o was served an extra helping of %k's plasma."
     FemaleSuicide="%o fried herself with her own plasma blast."
     MaleSuicide="%o fried himself with his own plasma blast."
     bDetonatesGoop=True
     DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LinkHit'
     DamageOverlayTime=0.500000
     VehicleDamageScaling=1.6
}
