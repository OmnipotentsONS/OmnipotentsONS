class CSMarvinPortalWeapon extends ONSWeapon;

#exec AUDIO IMPORT File=Sounds\PortalShoot.wav 

var bool bForceMinimumGrowth;
var float DefaultPortalSize;

var bool bHoldingFire, bHoldingAltFire;

simulated function Destroyed()
{
    local CSMarvinPortalDecal pd;

    foreach DynamicActors(Class'CSMarvinPortalDecal', pd)
		if (pd.Owner == Self)
			pd.Destroy();

    super.Destroyed();
}


/*
simulated function ClientStartFire(Controller C, bool bAltFire)
{
    bIsAltFire = bAltFire;

	if (FireCountdown <= 0)
	{
		if (bIsRepeatingFF)
		{
			if (bIsAltFire)
				ClientPlayForceFeedback( AltFireForce );
			else
				ClientPlayForceFeedback( FireForce );
		}
		//OwnerEffects();
	}
}

simulated function ClientStopFire(Controller C, bool bWasAltFire)
{
	if (bIsRepeatingFF)
	{
		if (bIsAltFire)
			StopForceFeedback( AltFireForce );
		else
			StopForceFeedback( FireForce );
	}

	if (Role < ROLE_Authority && AmbientEffectEmitter != None)
		AmbientEffectEmitter.SetEmitterStatus(false);

    OwnerEffects();
}
*/

simulated function OwnerEffects()
{
}


state ProjectileFireMode
{
    function Fire(Controller C)
    {
        if(!bHoldingFire)
        {
            bHoldingFire = true;
        }
    }
    function CeaseFire(Controller C)
    {
        local CSMarvinProjectile MP;

        if(bHoldingAltFire)
        {
            CeaseAltFire(C);
            return;
        }
        if(!bHoldingFire)
            return;

        bHoldingFire = false;

        DualFireOffset=default.DualFireOffset*-1;
    	CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(false);

        MP = CSMarvinProjectile(SpawnProjectile(ProjectileClass, False));
        if(MP != None)
        {
            MP.bForceMinimumGrowth = bForceMinimumGrowth;
            MP.DefaultPortalSize = DefaultPortalSize;
            MP.StartingPortalSize = DefaultPortalSize; 
        }

        PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
    }

    function AltFire(Controller C)
    {
        if(!bHoldingAltFire)
        {
            bHoldingAltFire = true;
        }
    }

    function CeaseAltFire(Controller C)
    {
        local CSMarvinProjectile MP;

        if(!bHoldingAltFire)
            return;

        bHoldingAltFire = false;

        DualFireOffset=default.DualFireOffset;
    	CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(false);

        if (AltFireProjectileClass == None)
        {
            Fire(C);
        }
        else
        {
            MP = CSMarvinProjectile(SpawnProjectile(AltFireProjectileClass, True));
            if(MP != None)
            {
                MP.bForceMinimumGrowth = bForceMinimumGrowth;
                MP.DefaultPortalSize = DefaultPortalSize;
                MP.StartingPortalSize = DefaultPortalSize;
            }

            PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
        }
    }
}

/*
simulated event OwnerEffects()
{
	if (!bIsRepeatingFF)
	{
		if (bIsAltFire)
			ClientPlayForceFeedback( AltFireForce );
		else
			ClientPlayForceFeedback( FireForce );
	}
    ShakeView();

	if (Role < ROLE_Authority)
	{
		if (bIsAltFire)
			FireCountdown = AltFireInterval;
		else
			FireCountdown = FireInterval;

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        FlashMuzzleFlash();

		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);



        // Play firing noise
        if (!bAmbientFireSound)
        {
            if (bIsAltFire)
                PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
            else
                PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
	}
}
*/



defaultproperties
{
    Mesh=Mesh'ONSWeapons-A.PlasmaGun'
    YawBone=PlasmaGunBarrel
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchBone=PlasmaGunBarrel
    PitchUpLimit=18000
    PitchDownLimit=49153
    FireSoundClass=sound'CSMarvin.PortalShoot'
    AltFireSoundClass=sound'CSMarvin.PortalShoot'
    FireForce="Laser01"
    AltFireForce="Laser01"
    ProjectileClass=class'CSMarvinProjectileRed'
    FireInterval=0.5
    AltFireProjectileClass=class'CSMarvinProjectileBlue'
    AltFireInterval=0.5
    WeaponFireAttachmentBone=PlasmaGunAttachment
    WeaponFireOffset=0.0
    bAimable=True
    RotationsPerSecond=1.2
    DualFireOffset=44
    //MinAim=0.900
    //bDoOffsetTrace=true
    DefaultPortalSize=3.0
}