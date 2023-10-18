/******************************************************************************
FireTankTurrent Adapted from FireBugTurret
pooty 03/2023
*/

class FireTankTurret extends HoverTankWeapon;


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
	L.AddPrecacheStaticMesh(StaticMesh'AS_Weapons_SM.ASTurret_Base');
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
     RedSkin=Texture'SieEng_Tex.FireTank.FireTankRed'
     BlueSkin=Texture'SieEng_Tex.FireTank.FireTankBlue'
     YawBone="Object01"
     PitchBone="Object02"
     //PitchUpLimit=70000
     PitchUpLimit=16400 // same as GoliathII
     //PitchDownLimit=56500
     WeaponFireAttachmentBone="Object02"
     WeaponFireOffset=85.000000
     DualFireOffset=8.0000
     RotationsPerSecond=3.000000
     bInstantRotation = True  // make it faster to spin
     bDoOffsetTrace=True
     bAmbientFireSound=True
     Spread=0.002
     
     FireInterval=0.100000
     AmbientEffectEmitterClass=Class'FireVehiclesV2Omni.FireTankTurretFlameEmitter'
     FireSoundClass=Sound'WVHoverTankV2.FirebugFireLoop'
     AmbientSoundScaling=2.000000
     ProjectileClass=Class'FireVehiclesV2Omni.FlameTurretProjectile'
     FireSoundVolume=900.000000
     FireForce="minifireb"
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.500000,RefireRate=0.700000)
     CullDistance=8000.000000
     Mesh=SkeletalMesh'ONSWeapons-A.TankMachineGun'
     SoundRadius=500.000000
}
