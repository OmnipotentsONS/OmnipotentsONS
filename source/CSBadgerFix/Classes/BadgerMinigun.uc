//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BadgerMinigun extends ONSWeapon;

var class<Emitter>            mTracerClass;
var() editinline Emitter      mTracer;
var() float				mTracerInterval;
var() float				mTracerPullback;
var() float				mTracerMinDistance;
var() float				mTracerSpeed;
var float                     mLastTracerTime;

state InstantFireMode 
{ 
      function AltFire(Controller C) 
      { 
           SpawnProjectile(AltFireProjectileClass, True); 
      } 
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'VMmeshEmitted.EJECTA.EjectedBRASSsm');
      L.AddPrecacheStaticMesh(StaticMesh'XEffects.MinigunFlashMesh');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'VMmeshEmitted.EJECTA.EjectedBRASSsm');
      Level.AddPrecacheStaticMesh(StaticMesh'XEffects.MinigunFlashMesh');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');

      Super.UpdatePrecacheMaterials();
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

        ProjMuzzleFlash();

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

simulated event ProjMuzzleFlash()
{
    if (Role == ROLE_Authority)
    {
    	FlashCount++;
    	NetUpdateTime = Level.TimeSeconds - 1;
    }
    else
        CalcWeaponFire();

    if (FlashEmitter != None)
        FlashEmitter.Trigger(Self, Instigator);

    if ( (EffectEmitterClass != None) && EffectIsRelevant(Location,false) )
        EffectEmitter = spawn(EffectEmitterClass, self,, WeaponFireLocation, WeaponFireRotation);
}

simulated event OwnerEffects() 
{ 
     if (!bIsRepeatingFF) 
     { 
          if (bIsAltFire) 
               ClientPlayForceFeedback( AltFireForce ); 
          else 
               ClientPlayForceFeedback( FireForce ); 
     } 
    ShakeView(); 
 
     if (Role < ROLE_Authority) 
     { 
          if (bIsAltFire) 
               FireCountdown = AltFireInterval; 
          else 
               FireCountdown = FireInterval; 
 
          AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock; 
 
        FlashMuzzleFlash(); 
 
          if (AmbientEffectEmitter != None && !bIsAltFire) 
               AmbientEffectEmitter.SetEmitterStatus(true); 
 
        // Play firing noise 
        if (!bAmbientFireSound) 
        { 
            if (bIsAltFire) 
                PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false); 
            else 
                PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false); 
        } 
     } 
}

function byte BestMode()
{
	return 0;
}


simulated function Destroyed()
{
	if (mTracer != None)
		mTracer.Destroy();

	Super.Destroyed();
}

simulated function UpdateTracer()
{
	local vector SpawnDir, SpawnVel;
	local float hitDist;

	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (mTracer == None)
	{
		mTracer = Spawn(mTracerClass);
	}

	if (Level.bDropDetail || Level.DetailMode == DM_Low)
		mTracerInterval = 2 * Default.mTracerInterval;
	else
		mTracerInterval = Default.mTracerInterval;

	if (mTracer != None && Level.TimeSeconds > mLastTracerTime + mTracerInterval)
	{
	        mTracer.SetLocation(WeaponFireLocation);

		hitDist = VSize(LastHitLocation - WeaponFireLocation) - mTracerPullback;

		if (Instigator != None && Instigator.IsLocallyControlled())
			SpawnDir = vector(WeaponFireRotation);
		else
			SpawnDir = Normal(LastHitLocation - WeaponFireLocation);

		if(hitDist > mTracerMinDistance)
		{
			SpawnVel = SpawnDir * mTracerSpeed;

			mTracer.Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;
			mTracer.Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;
			mTracer.Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;
			mTracer.Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;
			mTracer.Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;
			mTracer.Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;

			mTracer.Emitters[0].LifetimeRange.Min = hitDist / mTracerSpeed;
			mTracer.Emitters[0].LifetimeRange.Max = mTracer.Emitters[0].LifetimeRange.Min;

			mTracer.SpawnParticle(1);
		}

		mLastTracerTime = Level.TimeSeconds;
	}
}

simulated function FlashMuzzleFlash()
{
	Super.FlashMuzzleFlash();

	if (Role < ROLE_Authority)
		DualFireOffset *= -1;

	UpdateTracer();
}

defaultproperties
{
     mTracerClass=Class'CSBadgerFix.BadgerMinigunTracer'
     mTracerInterval=0.060000
     mTracerPullback=150.000000
     mTracerSpeed=18500.000000
     YawBone="MiniGunBase"
     YawStartConstraint=57344.000000
     YawEndConstraint=8192.000000
     PitchBone="MinigunBarrel"
     PitchUpLimit=8000
     PitchDownLimit=62500
     WeaponFireAttachmentBone="MinigunFire"
     WeaponFireOffset=192.000000
     RotationsPerSecond=2.000000
     bInstantRotation=True
     bInstantFire=True
     bDoOffsetTrace=True
     bAmbientFireSound=True
     bIsRepeatingFF=True
     bReflective=True
     Spread=0.010000
     RedSkin=Texture'Badger_Tex.Badger.BadgerRed'
     BlueSkin=Texture'Badger_Tex.Badger.BadgerBlue'
     FireInterval=0.100000
     AltFireInterval=2.400000
     EffectEmitterClass=Class'CSBadgerFix.BadgerMinigunFireEffect'
     AmbientEffectEmitterClass=Class'CSBadgerFix.BadgerMinigunFireEffect'
     FireSoundClass=Sound'Badger_Sound.BadgerMinigun'
     AltFireSoundClass=Sound'NewWeaponSounds.NewGrenadeShoot'
     AltFireSoundVolume=3.000000
     AmbientSoundScaling=1.300000
     FireForce="minifireb"
     DamageType=Class'CSBadgerFix.BadgerMinigun_Kill'
     DamageMin=15
     DamageMax=15
     TraceRange=15000.000000
     AltFireProjectileClass=Class'CSBadgerFix.BadgerGrenade'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=50.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=1.000000,Y=1.000000,Z=1.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     AIInfo(0)=(bInstantHit=True,aimerror=750.000000)
     CullDistance=8000.000000
     Mesh=SkeletalMesh'CSBadgerFix.BadgerMinigun'
     bSelected=True
}
