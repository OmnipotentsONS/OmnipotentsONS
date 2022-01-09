class HellHoundDriverWeapon extends ONSWeapon;


var() int ProjPerFire;
var() int AltFireProjPerFire;
var() int ProjSpread;
var() int AltFireProjSpread;
var() enum ESpreadStyle
{
    SS_None,
    SS_Random,
    SS_Line,
    SS_Ring
} SpreadStyle;
var() enum EAltFireSpreadStyle
{
    SS_None,
    SS_Random,
    SS_Line,
    SS_Ring
} AltFireSpreadStyle;

var bool bProjOffset;
var bool bAltFireProjOffset;
var rotator ProjSpawnOffset;
var rotator AltFireProjSpawnOffset;


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
     ProjPerFire=1
     AltFireProjPerFire=8
     AltFireProjSpread=1800
     AltFireSpreadStyle=SS_Random
     YawBone="Object83"
     PitchBone="Object83"
     WeaponFireAttachmentBone="Object85"
     GunnerAttachmentBone="Object83"
     FireInterval=0.200000
     AltFireInterval=1.500000
     FireSoundClass=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeFire01'
     AltFireSoundClass=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeFire01'
     FireForce="HoverBikeFire"
     AltFireForce="HoverBikeFire"
     ProjectileClass=Class'CSHellHound.HellHoundPlasmaProjectile'
     AltFireProjectileClass=Class'CSHellHound.HellHoundPlasmaProjectile'
     Mesh=SkeletalMesh'ONSFullAnimations.MASPassengerGun'
     DrawScale=0.500000
     DrawScale3D=(X=0.500000,Y=0.500000,Z=0.500000)
}
