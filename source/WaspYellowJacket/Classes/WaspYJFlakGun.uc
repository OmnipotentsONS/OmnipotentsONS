//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WaspYJFlakGun extends ONSAttackCraftGun;

var() int ProjPerFire;
var() int AltFireProjPerFire;
var() int ProjSpread;
var() int AltFireProjSpread;
var() enum ESpreadStyle
{
    SS_None,
    SS_Random, // spread is max random angle deviation
    SS_Line,   // spread is angle between each projectile
    SS_Ring
} SpreadStyle;
var() enum EAltFireSpreadStyle
{
    SS_None,
    SS_Random, // spread is max random angle deviation
    SS_Line,   // spread is angle between each projectile
    SS_Ring
} AltFireSpreadStyle;

var bool bProjOffset;
var bool bAltFireProjOffset;
var rotator ProjSpawnOffset;
var rotator AltFireProjSpawnOffset;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Texture'XEffects.FlakTrailTex');
    if ( L.DetailMode != DM_Low )
		L.AddPrecacheMaterial(Texture'XEffects.fexpt');
    L.AddPrecacheMaterial(Texture'XEffects.ExplosionFlashTex');
    L.AddPrecacheMaterial(Texture'XEffects.GoldGlow');
    L.AddPrecacheMaterial(Texture'WeaponSkins.FlakTex0');
    L.AddPrecacheMaterial(Texture'WeaponSkins.FlakTex1');
    L.AddPrecacheMaterial(Texture'WeaponSkins.FlakChunkTex');
    L.AddPrecacheMaterial(Texture'XWeapons.NewFlakSkin');
    L.AddPrecacheMaterial(Texture'XGameShaders.flak_flash');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.flakchunk');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.flakshell');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.FlakCannonPickup');

}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Texture'XEffects.FlakTrailTex');
    if ( Level.DetailMode != DM_Low )
		Level.AddPrecacheMaterial(Texture'XEffects.fexpt');
    Level.AddPrecacheMaterial(Texture'XEffects.ExplosionFlashTex');
    Level.AddPrecacheMaterial(Texture'XEffects.GoldGlow');
    Level.AddPrecacheMaterial(Texture'WeaponSkins.FlakTex0');
    Level.AddPrecacheMaterial(Texture'WeaponSkins.FlakTex1');
    Level.AddPrecacheMaterial(Texture'WeaponSkins.FlakChunkTex');
    Level.AddPrecacheMaterial(Texture'XWeapons.NewFlakSkin');
    Level.AddPrecacheMaterial(Texture'XGameShaders.flak_flash');

    Super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.flakchunk');
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.flakshell');
	Super.UpdatePrecacheStaticMeshes();
}

state ProjectileFireMode
{
    function Fire(Controller C)
    {
    	DoFireEffect(ProjectileClass, False);
    }

    function AltFire(Controller C)
    {
        if (AltFireProjectileClass == None)
            Fire(C);
        else
            DoFireEffect(AltFireProjectileClass, True);
    }
}
                                    
function DoFireEffect(class<Projectile> ProjClass, bool bAltFire)
{
	local Rotator R, AdjustedAim;
	local int p;
	local int SpawnCount;
	local float theta;
	local ONSWeaponPawn WeaponPawn;
	local vector StartLocation, HitLocation, HitNormal, Extent, X;

	AdjustedAim = WeaponFireRotation;

	if (!bAltFire && bProjOffset)
		AdjustedAim = WeaponFireRotation + ProjSpawnOffset;
	if (bAltFire && bAltFireProjOffset)
		AdjustedAim = WeaponFireRotation + AltFireProjSpawnOffset;

	if (bDoOffsetTrace)
	{
		Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
		Extent.Z = ProjClass.default.CollisionHeight;
		WeaponPawn = ONSWeaponPawn(Owner);
		if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
    		{
			if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(AdjustedAim) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5), Extent))
				StartLocation = HitLocation;
			else
				StartLocation = WeaponFireLocation + vector(AdjustedAim) * (ProjClass.default.CollisionRadius * 1.1);
		}
		else
		{
			if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(AdjustedAim) * (Owner.CollisionRadius * 1.5), Extent))
				StartLocation = HitLocation;
			else
				StartLocation = WeaponFireLocation + vector(AdjustedAim) * (ProjClass.default.CollisionRadius * 1.1);
		}
	}
	else
		StartLocation = WeaponFireLocation;

	if (!bAltFire)
	{
		SpawnCount = Max(1, ProjPerFire);

		switch (SpreadStyle)
		{
			case SS_Random:
				X = Vector(AdjustedAim);
				for (p = 0; p < SpawnCount; p++)
				{
					R.Yaw = ProjSpread * (FRand()-0.5);
					R.Pitch = ProjSpread * (FRand()-0.5);
					R.Roll = ProjSpread * (FRand()-0.5);
					SpawnAdvancedProjectile(ProjClass,bAltFire,StartLocation, Rotator(X >> R));
				}
				break;
			case SS_Line:
				for (p = 0; p < SpawnCount; p++)
				{
					theta = ProjSpread*PI/32768*(p - float(SpawnCount-1)/2.0);
					X.X = Cos(theta);
					X.Y = Sin(theta);
					X.Z = 0.0;
					SpawnAdvancedProjectile(ProjClass,bAltFire,StartLocation, Rotator(X >> AdjustedAim));
				}
				break;
			default:
				SpawnAdvancedProjectile(ProjClass,bAltFire,StartLocation,AdjustedAim);
		}
		if (bAmbientFireSound)
			AmbientSound = FireSoundClass;
		else
			PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
	}
	else
	{
		SpawnCount = Max(1, AltFireProjPerFire);

		switch (AltFireSpreadStyle)
		{
			case SS_Random:
				X = Vector(AdjustedAim);
				for (p = 0; p < SpawnCount; p++)
				{
					R.Yaw = AltFireProjSpread * (FRand()-0.5);
					R.Pitch = AltFireProjSpread * (FRand()-0.5);
					R.Roll = AltFireProjSpread * (FRand()-0.5);
					SpawnAdvancedProjectile(ProjClass,bAltFire,StartLocation, Rotator(X >> R));
				}
				break;
			case SS_Line:
				for (p = 0; p < SpawnCount; p++)
				{
					theta = AltFireProjSpread*PI/32768*(p - float(SpawnCount-1)/2.0);
					X.X = Cos(theta);
					X.Y = Sin(theta);
					X.Z = 0.0;
					SpawnAdvancedProjectile(ProjClass,bAltFire,StartLocation, Rotator(X >> AdjustedAim));
				}
				break;
			default:
				SpawnAdvancedProjectile(ProjClass,bAltFire,StartLocation,AdjustedAim);
		}
		if (bAmbientAltFireSound)
			AmbientSound = AltFireSoundClass;
		else
			PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
	}
}

function Projectile SpawnAdvancedProjectile(class<Projectile> ProjClass, bool bAltFire, vector Loc, rotator Rot)
{
    local Projectile P;

    P = spawn(ProjClass, self, , Loc, Rot);

    if (P != None)
    {
        if (bInheritVelocity)
            P.Velocity = Instigator.Velocity;

        FlashMuzzleFlash();

    }
    return P;
}

defaultproperties
{
     ProjPerFire=5
     AltFireProjPerFire=10
     ProjSpread=500
     AltFireProjSpread=1000
     SpreadStyle=SS_Random
     AltFireSpreadStyle=SS_Random
     PitchUpLimit=15000
     DualFireOffset=15.000000
     bDoOffsetTrace=True
     FireInterval=0.500000
     AltFireInterval=0.800000
     FireSoundClass=SoundGroup'WeaponSounds.FlakCannon.FlakCannonFire'
     AltFireSoundClass=SoundGroup'WeaponSounds.FlakCannon.FlakCannonAltFire'
     FireForce="FlakCannonFire"
     AltFireForce="FlakCannonAltFire"
     ProjectileClass=Class'WaspYellowJacket.WaspYJFlakChunk'
     AltFireProjectileClass=Class'WaspYellowJacket.WaspYJFlakChunk'
     AIInfo(0)=(aimerror=200.000000,RefireRate=1.500000)
}
