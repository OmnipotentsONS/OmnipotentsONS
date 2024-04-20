class DamTypeHospitalerLinkBeam extends VehicleDamageType
	abstract;

defaultproperties
{
     VehicleClass=Class'HospitalerV3Omni.HospitalerV3Omni'
     DeathString="%o was carved up by %k's green shaft."
     FemaleSuicide="%o shafted herself."
     MaleSuicide="%o shafted himself."
     bDetonatesGoop=True
     bSkeletize=True
     bCausesBlood=False
     bLeaveBodyEffect=True
     DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LinkHit'
     DamageOverlayTime=0.500000
     VehicleDamageScaling=1.5
}
