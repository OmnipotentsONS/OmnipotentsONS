/**
Badgers_V2.FlameBadgerFlamethrower

Creation date: 2014-01-26 13:39
Last change: $Id$
Copyright (c) 2014, Wormbo
*/

class FlameBadgerFlamethrower extends ONSWeapon;


#exec audio import file=Sounds\FlamethrowerLoop.wav


var bool bTurnedOff;
var float DamageFactor;


simulated function SetFireRateModifier(float Modifier)
{
	DamageFactor = Modifier;
}

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
	return 0;
}

simulated function CalcWeaponFire()
{
	local coords WeaponBoneCoords;

	// Calculate fire offset in world space
	WeaponBoneCoords = GetBoneCoords(WeaponFireAttachmentBone);

	// Calculate rotation of the gun
	WeaponFireRotation = OrthoRotation(WeaponBoneCoords.XAxis, WeaponBoneCoords.YAxis, WeaponBoneCoords.ZAxis);

	// Calculate exact fire location
	WeaponFireLocation = WeaponBoneCoords.Origin + WeaponFireOffset * WeaponBoneCoords.XAxis + DualFireOffset * WeaponBoneCoords.YAxis;

	// Adjust fire rotation taking dual offset into account
	if (bDualIndependantTargeting)
		WeaponFireRotation = rotator(CurrentHitLocation - WeaponFireLocation);
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
	ignores AltFire;

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
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     DamageFactor=1.000000
     YawBone="MiniGunBase"
     PitchBone="MinigunBarrel"
     PitchUpLimit=14000
     WeaponFireAttachmentBone="MinigunFire"
     bAmbientFireSound=True
     RedSkin=Shader'Badgers_V2beta3.Skins.FlameBadgerRed'
     BlueSkin=Shader'Badgers_V2beta3.Skins.FlameBadgerBlue'
     FireInterval=0.100000
     AmbientEffectEmitterClass=Class'Badgers_V2beta3.FlameBadgerFlamethrowerEmitter'
     FireSoundClass=Sound'Badgers_V2beta3.FlamethrowerLoop'
     AmbientSoundScaling=2.000000
     ProjectileClass=Class'Badgers_V2beta3.FlameBadgerFlameProjectile'
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.500000,RefireRate=0.700000)
     Mesh=SkeletalMesh'Badgers_V2beta3.BadgerMinigun'
     SoundRadius=500.000000
}
