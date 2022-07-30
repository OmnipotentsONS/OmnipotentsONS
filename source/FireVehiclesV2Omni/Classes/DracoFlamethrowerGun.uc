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

class DracoFlamethrowerGun extends ONSWeapon; // ONSLinkableWeapon;


//=============================================================================
// Imports
//=============================================================================

//#exec audio import file=Sounds\DracoFireLoop.wav
// just reference the Draco Package


//=============================================================================
// Variables
//=============================================================================

var float DamageFactor;
var bool bTurnedOff;


simulated function Tick(float DeltaTime)
{
	if (bTurnedOff)
		return;

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

simulated function SetFireRateModifier(float Modifier)
{
	DamageFactor = Modifier;
}

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

simulated function ClientStartFire(Controller C, bool bAltFire)
{
	if (!bAltFire)
		Super.ClientStartFire(C, bAltFire);
}

state ProjectileFireMode
{
	function Fire(Controller C)
	{
		local Projectile P;

		if (AmbientEffectEmitter != None)
		{
			AmbientEffectEmitter.SetEmitterStatus(true);
		}
		P = SpawnProjectile(ProjectileClass, False);
		if (P != None)
			P.Damage *= DamageFactor;
	}

    function AltFire(Controller C)
    {
		local ONSDecoy P;
		local ONSDualAttackCraft V;

    	if (AltFireProjectileClass != none)
    	{
			P =	ONSDecoy(SpawnProjectile(AltFireProjectileClass, True));
			V = ONSDualAttackCraft(Owner);
			if (P != None && V != None)
			{
				V.Decoys.Insert(0,1);
				V.Decoys[0] = P;

			    P.ProtectedTarget = V;
			}
			FlashCount = 0; // ugly, but would otherwise start spawning flame particles on the client
		}
    }
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     DamageFactor=1.000000
     YawBone="GatlingGun"
     PitchBone="GatlingGun"
     PitchUpLimit=2000
     PitchDownLimit=50000
     WeaponFireAttachmentBone="GatlingGunFirePoint"
     bShowChargingBar=True
    // Doesn't work for some reason

     DualFireOffset=10.000000
     RotationsPerSecond=0.700000
     bAmbientFireSound=True
     RedSkin=Shader'WVDraco.Skins.DracoShaderRed'
     BlueSkin=Shader'WVDraco.Skins.DracoShaderBlue'
     FireInterval=0.100000
     
     AltFireInterval=5.000000
     
     AmbientEffectEmitterClass=Class'FireVehiclesV2Omni.DracoFlamethrowerEmitter'
     FireSoundClass=Sound'WVDraco.DracoFireLoop'
     ProjectileClass=Class'FireVehiclesV2Omni.DracoFlamethrowerProjectile'
     AltFireProjectileClass=Class'FireVehiclesV2Omni.DracoFireballIncendiary'
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.250000,RefireRate=0.700000)
     Mesh=SkeletalMesh'ONSBPAnimations.DualAttackCraftGatlingGunMesh'
     SoundRadius=500.000000
}
