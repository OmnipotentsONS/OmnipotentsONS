/******************************************************************************
FirebugFlameTurret

Creation date: 2012-10-11 19:41
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class FirebugFlameTurret extends HoverTankWeapon;


//=============================================================================
// Imports
//=============================================================================

//#exec obj load file="GeneralAmbience.uax"
//#exec audio import file=Sounds\FirebugFireLoop.wav


//=============================================================================
// Properties
//=============================================================================

var() Material RedSkin2;
var() Material BlueSkin2;


//=============================================================================
// Variables
//=============================================================================

var float DamageFactor;


static function StaticPrecache(LevelInfo L)
{
	super.StaticPrecache(L);

	L.AddPrecacheMaterial(default.RedSkin);
	L.AddPrecacheMaterial(default.RedSkin2);
	L.AddPrecacheMaterial(default.BlueSkin);
	L.AddPrecacheMaterial(default.BlueSkin2);

	L.AddPrecacheStaticMesh(StaticMesh'AS_Weapons_SM.ASTurret_Base');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'AS_Weapons_SM.ASTurret_Base');
	Level.AddPrecacheStaticMesh(StaticMesh'AS_Weapons_SM.Projectiles.Skaarj_Energy');

	super.UpdatePrecacheStaticMeshes();
}


simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(RedSkin);
	Level.AddPrecacheMaterial(RedSkin2);
	Level.AddPrecacheMaterial(BlueSkin);
	Level.AddPrecacheMaterial(BlueSkin2);

	super.UpdatePrecacheMaterials();
}

simulated function SetTeam(byte T)
{
	Super.SetTeam(T);
	if (T == 0 && RedSkin2 != None)
	{
		Skins[1] = RedSkin2;
	}
	else if (T == 1 && BlueSkin2 != None)
	{
		Skins[1] = BlueSkin2;
	}
}

function byte BestMode()
{
	return 0;
}

simulated function SetFireRateModifier(float Modifier)
{
	DamageFactor = Modifier;
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
     RedSkin2=Texture'WVHoverTankV2.Skins.ASTurret_Canon_Red'
     BlueSkin2=Texture'AS_Weapons_TX.Turret.ASTurret_Canon'
     DamageFactor=1.000000
     YawBone="Turret"
     PitchBone="Turret"
     PitchUpLimit=16000
     WeaponFireAttachmentBone="Turret"
     WeaponFireOffset=100.000000
     DualFireOffset=48.500000
     RotationsPerSecond=0.500000
     bAmbientFireSound=True
     RedSkin=Texture'WVHoverTankV2.Skins.ASTurret_Base_Red'
     BlueSkin=Texture'AS_Weapons_TX.Turret.ASTurret_Base'
     FireInterval=0.100000
     AmbientEffectEmitterClass=Class'FireVehiclesV2Omni.FirebugPilotFlameEmitter' 
     // this is the flames.  this is NOT the cause of framerate drop
     FireSoundClass=Sound'WVHoverTankV2.FirebugFireLoop'
     AmbientSoundScaling=2.000000
     ProjectileClass=Class'FireVehiclesV2Omni.FlamerProjectile'
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.500000,RefireRate=0.700000)
     Mesh=SkeletalMesh'WVHoverTankV2.Firebug.BallTurretTankGun'
     SoundRadius=500.000000
}
