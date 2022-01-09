class Weapon_ONSArmadilloPassenger extends ONSWeapon;


function byte BestMode()
{
	return 0;
}

defaultproperties
{
     YawBone="PlasmaGunBarrel"
     PitchBone="PlasmaGunBarrel"
     PitchUpLimit=15000
     PitchDownLimit=57500
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     GunnerAttachmentBone="PlasmaGunAttachment"
     FireInterval=1.000000
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
