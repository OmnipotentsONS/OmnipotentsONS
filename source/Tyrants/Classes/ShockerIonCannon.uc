class ShockerIonCannon extends ONSHoverTank_IonPlasma_Weapon;


simulated event FlashMuzzleFlash()
{
	super.FlashMuzzleFlash();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( !IsAltFire() && BeamCount != OldBeamCount )
		{
			OldBeamCount = BeamCount;
			PlayAnim('MASMainGunDeploy', 80.0, 0);
			super.ShakeView();
		}
	}
}

defaultproperties
{
     BeamEffectClass=Class'Tyrants.Shocker_IonPlasma_BeamFire'
     YawBone="MainGunBase"
     PitchBone="MainGunBase"
     WeaponFireAttachmentBone="maingunBarrel"
     WeaponFireOffset=10.000000
     bReplicateAnimations=True
     Mesh=SkeletalMesh'Tyrants_ANIM.ShockerCannon'
     DrawScale=0.400000
}
