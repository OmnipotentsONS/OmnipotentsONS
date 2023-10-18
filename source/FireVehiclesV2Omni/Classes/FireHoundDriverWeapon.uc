/******************************************************************************
FireHoundDriverWeapon Adapted from FireBugTurret
pooty 03/2023
*/

class FireHoundDriverWeapon extends HoverTankWeapon;


//=============================================================================
// Imports
//=============================================================================

//#exec obj load file="GeneralAmbience.uax"
//#exec audio import file=Sounds\FirebugFireLoop.wav


//=============================================================================
// Properties
//=============================================================================


//=============================================================================
// Variables
//=============================================================================



static function StaticPrecache(LevelInfo L)
{
	super.StaticPrecache(L);

	L.AddPrecacheMaterial(default.RedSkin);
	L.AddPrecacheMaterial(default.BlueSkin);
	
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'AS_Weapons_SM.Projectiles.Skaarj_Energy');
	super.UpdatePrecacheStaticMeshes();
}


simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(RedSkin);
	Level.AddPrecacheMaterial(BlueSkin);
	super.UpdatePrecacheMaterials();
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

	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     YawBone="Object83"
     PitchBone="Object83"
     WeaponFireAttachmentBone="Object85"
     GunnerAttachmentBone="Object83"
     RotationsPerSecond=3.000000
     bInstantRotation = True  // make it faster to spin
     bAmbientFireSound=True
     bIsRepeatingFF=True
     Spread=0.002000
     FireInterval=0.100000
     FireSoundVolume=900.000000
     FireSoundClass=Sound'WVHoverTankV2.FirebugFireLoop'
     AmbientSoundScaling=2.000000
     FireForce="minifireb"
     ProjectileClass=Class'FireVehiclesV2Omni.FireHoundFlameProjectile'
     AIInfo(0)=(bLeadTarget=True)
     CullDistance=8000.000000
     Mesh=SkeletalMesh'ONSFullAnimations.MASPassengerGun'
     DrawScale=0.500000
     DrawScale3D=(X=0.500000,Y=0.500000,Z=0.500000)
     
     
     WeaponFireOffset=10.000000
     DualFireOffset=8.0000
     bDoOffsetTrace=True
     AmbientEffectEmitterClass=Class'FireVehiclesV2Omni.FireHoundDriverFlameEmitter'
         
     SoundRadius=500.000000
     
}
