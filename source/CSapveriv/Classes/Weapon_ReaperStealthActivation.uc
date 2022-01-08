class Weapon_ReaperStealthActivation extends ONSWeapon;

var Reaper R;


function byte BestMode()
{
	return 0;
}
state ProjectileFireMode
{

	function Fire(Controller C)
	{
	 R=Reaper(Instigator);
       Reaper(instigator).StealthMode();
	}
}

defaultproperties
{
     YawBone="PlasmaGunBarrel"
     PitchBone="PlasmaGunBarrel"
     PitchUpLimit=18000
     PitchDownLimit=49153
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     WeaponFireOffset=85.000000
     DualFireOffset=116.000000
     RotationsPerSecond=0.200000
     bInstantRotation=True
     bDualIndependantTargeting=True
     FireInterval=60.000000
     FireSoundClass=Sound'WeaponSounds.TAGRifle.TAGFireB'
     FireSoundVolume=70.000000
     FireForce="Laser01"
     AIInfo(0)=(bLeadTarget=True,aimerror=400.000000,RefireRate=0.500000)
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
