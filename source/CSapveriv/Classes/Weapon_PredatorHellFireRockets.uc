//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Weapon_PredatorHellFireRockets extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var float MinAim;
var float MaxLockRange, LockAim;
var vector FireLocA,FireLocB,FireLocC,FireLocD,FireLocE;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');

    Super.UpdatePrecacheMaterials();
}

function byte BestMode()
{
		return 0;
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
    gotostate('FireRocketVolly');

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

state FireRocketVolly
{
 Begin:
      sleep(0.25);
      PlaySound(FireSoundClass,, 2.5*TransientSoundVolume);
      CalcWeaponFire();
      FireLocA = WeaponFireLocation + Vect(0,20,0);
      spawn(ProjectileClass, self, , FireLocA, WeaponFireRotation);
      sleep(0.25);
      PlaySound(FireSoundClass,, 2.5*TransientSoundVolume);
      CalcWeaponFire();
      FireLocB = WeaponFireLocation + Vect(0,-20,0);
      spawn(ProjectileClass, self, , FireLocB, WeaponFireRotation);
      sleep(0.25);
      PlaySound(FireSoundClass,, 2.5*TransientSoundVolume);
      CalcWeaponFire();
      FireLocC = WeaponFireLocation + Vect(0,-20,-20);
      spawn(ProjectileClass, self, , FireLocC, WeaponFireRotation);
      sleep(0.25);
      PlaySound(FireSoundClass,, 2.5*TransientSoundVolume);
      CalcWeaponFire();
      FireLocD = WeaponFireLocation + Vect(0,20,-20);
      spawn(ProjectileClass, self, , FireLocD, WeaponFireRotation);
      sleep(0.25);
      PlaySound(FireSoundClass,, 2.5*TransientSoundVolume);
      CalcWeaponFire();
      FireLocE = WeaponFireLocation + Vect(0,0,-20);
      spawn(ProjectileClass, self, , FireLocE, WeaponFireRotation);
      gotostate('ProjectileFireMode');
}

state ProjectileFireMode
{
   function Fire(Controller C)
	{
		local PROJ_PredatorRocket P;
		local float BestAim, BestDist;
        local vector StartVelocity;

		P = PROJ_PredatorRocket(SpawnProjectile(ProjectileClass, True));
		StartVelocity = Instigator.Velocity;
		P.Velocity = StartVelocity;	// Apply the velocity
        if (P != None)
		{
			if (AIController(C) != None)
			    {
			     P.HomingTarget = C.Enemy;
				 P.SetHomingTarget();
		        }
			else
			   {
				BestAim = LockAim;
				P.HomingTarget = C.PickTarget(BestAim, BestDist, vector(WeaponFireRotation), WeaponFireLocation, MaxLockRange);
  		        P.SetHomingTarget();
               }
        }
	}
}

defaultproperties
{
     MinAim=0.900000
     //MaxLockRange=30000.000000
     MaxLockRange=10000.000000
     LockAim=0.975000
     YawBone="PlasmaGunBarrel"
     PitchBone="PlasmaGunBarrel"
     PitchUpLimit=18000
     PitchDownLimit=49153
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     WeaponFireOffset=85.000000
     DualFireOffset=50.000000
     RotationsPerSecond=0.200000
     bInstantRotation=True
     bDualIndependantTargeting=True
     FireInterval=1.500000
     FireSoundClass=Sound'CicadaSnds.Missile.MissileIgnite'
     FireSoundVolume=70.000000
     AmbientSoundScaling=1.300000
     FireForce="Laser01"
     ProjectileClass=Class'CSAPVerIV.PROJ_PredatorRocket'
     AIInfo(0)=(bLeadTarget=True,aimerror=400.000000,RefireRate=0.500000)
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
