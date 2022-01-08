//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Weapon_PhantomBombDropper extends ONSWeapon;



var float MinAim;
var()       sound   DeploySound;
var     float           AltFireCountdown;
// Aiming
var()	float	AltFireIntervalAimLock; //fraction of FireInterval/AltFireInterval during which you can't move the gun
var	float		AltAimLockReleaseTime; //when this time is reached gun can move again
var vector FireOffset;
var float MSGDelay,NextMSGTime;
var vector FireLocA,FireLocB,FireLocC,FireLocD,FireLocE;
function byte BestMode()
{
	return 0;
}

//do effects (muzzle flash, force feedback, etc) immediately for the weapon's owner (don't wait for replication)
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
		   {
			AltFireCountdown = AltFireInterval;
			AltAimLockReleaseTime = Level.TimeSeconds + AltFireCountdown * AltFireIntervalAimLock;
		   }
        else
			FireCountdown = FireInterval;

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        FlashMuzzleFlash();

		if (AmbientEffectEmitter != None)
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

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;
   if (bAltFire)
		{
     if (AltFireCountdown <= 0)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
		if (bAltFire)
		{
			AltFireCountdown = AltFireInterval;
			AltFire(C);

		}

		AltAimLockReleaseTime = Level.TimeSeconds + AltFireCountdown * AltFireIntervalAimLock;

	    return True;
	}
   }
   else
	if (FireCountdown <= 0)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);

		       	FireCountdown = FireInterval;
		       	Fire(C);

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

	    return True;
	}

	return False;
}



function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local ONSWeaponPawn WeaponPawn;
    local vector StartLocation, HitLocation, HitNormal, Extent;
    WeaponPawn_PhantomBomber(Owner).dooropen();
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
    P = spawn(ProjClass, self, , Location + vect(0,0,-200), WeaponFireRotation);
    P.Velocity = Vector(WeaponFireRotation) * P.Speed;
    Proj_BombShell(P).StartTimer(1.8);
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
		Super.Fire(C);
	    SetTimer(5.0,false);
    }

	function AltFire(Controller C)
	{
		local Proj_NukeMissile NB;
        NextMSGTime = Level.TimeSeconds + MSGDelay;
		NB = Proj_NukeMissile(SpawnProjectile(AltFireProjectileClass, true));
	}
	function timer()
	{
	 WeaponPawn_PhantomBomber(Owner).doorClose();
	}
}

simulated function Tick(float DeltaTime)
{

  AltFireCountdown -= DeltaTime;

  if (AltFireCountdown <= 0)
     {
      if ( Level.TimeSeconds < NextMSGTime )
         {
          Instigator.ReceiveLocalizedMessage(class'MSG_BomberMessage', 0);
           NextMSGTime = Level.TimeSeconds + MSGDelay;
         }
     }
  else
     {
      if ( Level.TimeSeconds < NextMSGTime )
         {
          Instigator.ReceiveLocalizedMessage(class'MSG_BomberMessage', 1);
           NextMSGTime = Level.TimeSeconds + MSGDelay;
         }
     }

}

defaultproperties
{
     MinAim=0.900000
     DeploySound=Sound'IndoorAmbience.door4'
     MSGDelay=12.000000
     YawBone="PlasmaGunBarrel"
     PitchBone="PlasmaGunBarrel"
     PitchUpLimit=0
     PitchDownLimit=50000
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     DualFireOffset=1.000000
     RotationsPerSecond=1.200000
     AltFireInterval=30.000000
     FireSoundClass=Sound'ONSBPSounds.Artillery.ArtilleryFire'
     FireSoundVolume=256.000000
     AltFireSoundClass=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'
     FireForce="Laser01"
     AltFireForce="Laser01"
     ProjectileClass=Class'CSAPVerIV.Proj_BombShell'
     AltFireProjectileClass=Class'CSAPVerIV.Proj_NukeMissile'
     AIInfo(0)=(RefireRate=0.600000)
     AIInfo(1)=(RefireRate=45.000000)
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
