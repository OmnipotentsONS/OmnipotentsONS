/******************************************************************************
DracoFlamethrowerGun

Creation date: 2013-04-28 08:10
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

// Wormbo used a hack here, the projectiles are invsible and he used Ambient Emitters to simulate the projectiles
// then used a hack on the alt fire so it wouldn't show.
// better fix was in Ownereffects() to not show AmbientEmitter if altfire
// deleted a bunch of garbage code to work around the hack


class DracoFlamethrowerGun extends ONSWeapon; // ONSLinkableWeapon;


//=============================================================================
// Imports
//=============================================================================

//#exec audio import file=Sounds\DracoFireLoop.wav
// just reference the Draco Package


//=============================================================================
// Variables
//=============================================================================

//var float DamageFactor;
//var bool bTurnedOff;  //appears to do nothing?!


simulated function Tick(float DeltaTime)
{
	//if (bTurnedOff)
	//	return; 
	

	if (Instigator != None && Instigator.PlayerReplicationInfo != None)
	{
		bForceCenterAim = False;
	}
	else if (!bActive && CurrentAim != rot(0,0,0))
	{
		bForceCenterAim = True;
		bActive = True;
	}
	else if (bActive && CurrentAim == rot(0,0,0))
	{
		bActive = False;
	}
}

function byte BestMode()
{
	if (Draco(Owner) == None || Draco(Owner).Incoming == None)
		return 0; // not defending against AVRiL
	
	if (Bot(Instigator.Controller) != None && Bot(Instigator.Controller).Skill > 3 + 3 * FRand() && Draco(Owner).DecoyProtectionIsGood())
		return 0; // decoy is out, now try to shoot down the AVRiL with the flamethrower
	
	return 1; // AVRiL incoming and no decoy out yet
}

// WTF is this for? pooty
//simulated function SetFireRateModifier(float Modifier)
//{
//	DamageFactor = Modifier;
//}

simulated function InitEffects()
{
	// don't even spawn on server
	if (Level.NetMode == NM_DedicatedServer)
		return;

	
	
	if ( (FlashEmitterClass != None) && (FlashEmitter == None) )
	{
		FlashEmitter = Spawn(FlashEmitterClass);
		FlashEmitter.SetDrawScale(DrawScale);
		if (WeaponFireAttachmentBone == '')
			FlashEmitter.SetBase(self);
		else
			AttachToBone(FlashEmitter, WeaponFireAttachmentBone);

		FlashEmitter.SetRelativeLocation(WeaponFireOffset * vect(1,0,0));
	}
  
	
	if (AmbientEffectEmitterClass != none && AmbientEffectEmitter == None)
	{
		AmbientEffectEmitter = Spawn(AmbientEffectEmitterClass, self,, WeaponFireLocation, WeaponFireRotation);
		//if (WeaponFireAttachmentBone == '')
		//	AmbientEffectEmitter.SetBase(self);
		//else
		//	AttachToBone(AmbientEffectEmitter, WeaponFireAttachmentBone);

		//AmbientEffectEmitter.SetRelativeLocation(WeaponFireOffset * vect(1,0,0) / DrawScale); // because it seems to scale with DrawScale, unlike everything else
	}
}

simulated function float ChargeBar()
{
	return FClamp(0.999 - (FireCountDown / AltFireInterval), 0.0, 0.999);
}


simulated function DestroyEffects()
{
	if (FlashEmitter != None)
		FlashEmitter.Destroy();
	if (EffectEmitter != None)
		EffectEmitter.Destroy();
	if (AmbientEffectEmitter != None)
	{
		AmbientEffectEmitter.Kill();
		AmbientEffectEmitter = None;
	}
}

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

        if (AmbientEffectEmitter != None && (!bIsAltFire))  // don't show for alt fire.
        // because only primary fire needs this on the Draco -- this avoids Wormbo's dumb flash counter hack in the original version
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

state ProjectileFireMode
{
	
	// this uses the AmbientEffects to simulate the flame projectiles.
	function Fire(Controller C)
	{

		if (AmbientEffectEmitter != None)
		{
			AmbientEffectEmitter.SetEmitterStatus(true);
		}
		Super.Fire(C);
	
	}


    function AltFire(Controller C)
    {
		if (AmbientEffectEmitter != None)
			{
				AmbientEffectEmitter.SetEmitterStatus(false);
			}
		Super.AltFire(C);
    }

}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     //DamageFactor=1.000000
     YawBone="GatlingGun"
     PitchBone="GatlingGun"
     PitchUpLimit=2000
     PitchDownLimit=50000
     WeaponFireAttachmentBone="GatlingGunFirePoint"
     bShowChargingBar=True
    // Works now needed to set the chargebar function,
    
     DualFireOffset=10.000000
     RotationsPerSecond=0.700000
     bAmbientFireSound=True
     RedSkin=Shader'WVDraco.Skins.DracoShaderRed'
     BlueSkin=Shader'WVDraco.Skins.DracoShaderBlue'
     FireInterval=0.100000
     
     AltFireInterval=3.000000
     
     AmbientEffectEmitterClass=Class'FireVehiclesV2Omni.DracoFlamethrowerEmitter'
     FireSoundClass=Sound'WVDraco.DracoFireLoop'
     ProjectileClass=Class'FireVehiclesV2Omni.DracoFlamethrowerProjectile'
     AltFireProjectileClass=Class'FireVehiclesV2Omni.DracoFireballIncendiary'
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.250000,RefireRate=0.700000)
     Mesh=SkeletalMesh'ONSBPAnimations.DualAttackCraftGatlingGunMesh'
     SoundRadius=500.000000
}
