class HospitilarLinkTW extends LinkTW;

#exec OBJ LOAD FILE=..\Textures\IllyHospitalerSkins

simulated function SetInitialState()
{
	Skins[0]=Texture'IllyHospitalerSkins.Hospitaler.LinkTurret_Skin2';

	Super.SetInitialState();

}

simulated function vector GetEffectStart()
{
    return HospitilarLinkGun(HospitilarLinkGunPawn(Instigator).Gun).GetFireStart();
}

defaultproperties
{
     FireModeClass(0)=Class'HospitalerV3Omni.HospitilarLinkGunFire'
     FireModeClass(1)=Class'HospitalerV3Omni.HospitilarLinkGunAltFire'
}
