class Weapon_DropShipWeapon extends ONSWeapon;


var float MinAim;
var float MaxLockRange, LockAim;
var vector FireLocA,FireLocB,FireLocC,FireLocD,FireLocE;

state ProjectileFireMode
{
    function Fire(Controller C)
	{
		local PROJ_DropShipRocket M;
		local float BestAim, BestDist;

		M = PROJ_DropShipRocket(SpawnProjectile(ProjectileClass, True));
		if (M != None)
		{
			if (AIController(C) != None)
			    M.HomingTarget = C.Enemy;

			else
			   {
				BestAim = LockAim;
				M.HomingTarget = Vehicle(C.PickTarget(BestAim, BestDist, vector(WeaponFireRotation), WeaponFireLocation, MaxLockRange));
  		       }
        }
        super.Fire(C);
	}

    function AltFire(Controller C)
    {
    }
}
function byte BestMode()
{
 		return 0;
}
/*
function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
    local int Damage;

    X = Vector(Dir);
    End = Start + TraceRange * X;
    //skip past vehicle driver
    if (ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
    {
      	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
       	Other = Trace(HitLocation, HitNormal, End, Start, True);
       	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
    }
    else
       	Other = Trace(HitLocation, HitNormal, End, Start, True);

    if (Other != None)
    {
	if (!Other.bWorldGeometry)
        {
            Damage = (DamageMin + Rand(DamageMax - DamageMin));
            Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
            HitNormal = vect(0,0,0);
        }
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }
    HitCount++;
    LastHitLocation = HitLocation;
    SpawnHitEffects(Other, HitLocation, HitNormal);
}
function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local ONSWeaponPawn WeaponPawn;
    local vector StartLocation, HitLocation, HitNormal, Extent;

    if (bDoOffsetTrace)
    {
       	Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
        Extent.Z = ProjClass.default.CollisionHeight;
       	WeaponPawn = ONSWeaponPawn(Owner);
    	if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
    	{
    		if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
	else
	{
		if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
    }
    else
    	StartLocation = WeaponFireLocation;


    P = spawn(ProjClass, self, , StartLocation, WeaponFireRotation);

     if (P != None)
    {
        if (bInheritVelocity)
            P.Velocity = Instigator.Velocity;

        FlashMuzzleFlash();

        // Play firing noise
        if (bAltFire)
        {
            if (bAmbientAltFireSound)
                AmbientSound = AltFireSoundClass;
            else
                PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
        }
        else
        {
            if (bAmbientFireSound)
                AmbientSound = FireSoundClass;
            else
                PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
    }

    return P;
}

state ProjectileFireMode
{
    function Fire(Controller C)
	{
		local PROJ_DropShipRocket M;
		local float BestAim, BestDist;

		M = PROJ_DropShipRocket(SpawnProjectile(ProjectileClass, True));
		if (M != None)
		{
			if (AIController(C) != None)
			    M.HomingTarget = C.Enemy;

			else
			   {
				BestAim = LockAim;
				M.HomingTarget = C.PickTarget(BestAim, BestDist, vector(WeaponFireRotation), WeaponFireLocation, MaxLockRange);
  		       }
        }
        super.Fire(C);
	}
}
*/

defaultproperties
{
    FireInterval=0.75
     MinAim=0.900000
     MaxLockRange=10000.000000
     LockAim=0.975000
     YawBone="PlasmaGunBarrel"
     PitchBone="PlasmaGunBarrel"
     PitchUpLimit=18000
     PitchDownLimit=49153
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     WeaponFireOffset=85.000000
     DualFireOffset=75.000000
     RotationsPerSecond=0.200000
     FireSoundClass=SoundGroup'WeaponSounds.AssaultRifle.AssaultRifleFire'
     FireForce="Laser01"
     ProjectileClass=Class'CSAPVerIV.PROJ_DropShipRocket'
     AIInfo(0)=(bLeadTarget=True,aimerror=400.000000,RefireRate=0.500000)
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
