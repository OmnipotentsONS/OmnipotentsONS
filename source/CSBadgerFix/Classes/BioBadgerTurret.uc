//=============================================================================
// BioBadgerTurret.
//=============================================================================
class BioBadgerTurret extends BadgerTurret;

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

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx
#exec OBJ LOAD FILE=..\Textures\BenTex01.utx

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
     AltFireProjPerFire=1
     ProjSpread=1500
     AltFireProjSpread=100
     SpreadStyle=SS_Random
     AltFireSpreadStyle=SS_Random
     RotationsPerSecond=0.300000
     RedSkin=Texture'MoreBadgers.BioBadger.BioBadgerRed'
     BlueSkin=Texture'MoreBadgers.BioBadger.BioBadgerBlue'
     FireInterval=0.850000
     AltFireInterval=1.400000
     FlashEmitterClass=Class'CSBadgerFix.BioMuzzleFlash'
     EffectEmitterClass=None
     FireSoundClass=Sound'ONSVehicleSounds-S.WebLauncher.WebStick'
     FireSoundVolume=600.000000
     AltFireSoundClass=SoundGroup'WeaponSounds.BioRifle.BioRifleFire'
     AltFireSoundVolume=800.000000
     RotateSound=Sound'BioAegis_Sound.BioTank.BiotankTurret'
     FireForce="BioFire"
     AltFireForce="biofire"
     ProjectileClass=Class'CSBadgerFix.BiotankGlob'
     AltFireProjectileClass=Class'CSBadgerFix.BioTankGlobBomb'
     ShakeRotMag=(Z=0.000000)
     ShakeRotRate=(Z=0.000000)
     ShakeRotTime=0.000000
     ShakeOffsetMag=(Z=0.000000)
     ShakeOffsetRate=(Z=0.000000)
     ShakeOffsetTime=0.000000
}
