class ShockerFrontTurret extends ONSTankSecondaryTurret;

var float altFireSpread, Spread;


replication
{
	unreliable if(Role==ROLE_Authority)
	altFireSpread, Spread;
}

simulated event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;

	if (FireCountdown <= 0)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (bAltFire)
		{
			if (altFireSpread > 0)
				WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*altFireSpread);
		}
		else
		{
			if (Spread > 0)
				WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);
		}

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
		if (bAltFire)
		{
			FireCountdown = AltFireInterval;
			AltFire(C);
		}
		else
		{
		    FireCountdown = FireInterval;
		    Fire(C);
		}
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

	    return True;
	}

	return False;
}

state InstantFireMode
{

    function AltFire(Controller C)
    {
        FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        // Play firing noise
        if (bAmbientFireSound)
            AmbientSound = FireSoundClass;
        else
            PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);

        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }

}

defaultproperties
{
     altFireSpread=0.200000
     Spread=0.070000
     YawBone="SIDEgunBASE"
     PitchBone="SIDEgunBARREL"
     WeaponFireAttachmentBone="Firepoint"
     WeaponFireOffset=-30.000000
     DualFireOffset=0.000000
     RedSkin=Texture'KainTex_Shocker.Shocker.ShockerRED'
     BlueSkin=Texture'KainTex_Shocker.Shocker.ShockerBLUE'
     DamageType=Class'Shocker_V2.DamTypeShockerMachineGun'
     Mesh=SkeletalMesh'ONSWeapons-A.PRVsideGun'
     DrawScale=0.850000
}
