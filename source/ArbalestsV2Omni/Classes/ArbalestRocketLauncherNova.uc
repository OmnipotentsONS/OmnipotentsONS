//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ArbalestRocketLauncherNova extends ONSMASRocketPack;

var int firemode;
var int maxfiremode;
var Array<String> FireModeNames;

var bool canFireMEGADeemer;
var float MEGADeemerReload;

replication
{
  reliable if(Role == Role_Authority) 
           canFireMEGADeemer, firemode;
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
		local ArbalestRocketNovaPrime R;
		local float BestAim, BestDist;
	   	local ArbalestGuidedWarhead M;
	    	local PlayerController Possessor;
		local rotator MissileRot;

		if (firemode==1)
		{

			R = ArbalestRocketNovaPrime(SpawnProjectile(ProjectileClass, False));
			if (R != None)
			{
				if (AIController(C) != None)
				   	R.HomingTarget = C.Enemy;
				else
				{
					BestAim = LockAim;
					R.HomingTarget = C.PickTarget(BestAim, BestDist, vector(WeaponFireRotation), WeaponFireLocation, MaxLockRange);
				}
			}
		}
		if (Firemode==2)
		{
        		MissileRot=C.Rotation;
        		M = Spawn(Class'ArbalestGuidedWarhead',Self,,Location+Vect(0,0,256),MissileRot);

			if (M != None)
			{
				M.OldPawn = Instigator;
				//M.PlaySound(FireSound);
				Possessor = PlayerController(Instigator.Controller);
				Possessor.bAltFire = 0;
				if ( Possessor != None )
				{
					if ( Instigator.InCurrentCombo() )
						Possessor.Adrenaline = 0;
					Possessor.UnPossess();
					Instigator.SetOwner(Possessor);
					Instigator.PlayerReplicationInfo = Possessor.PlayerReplicationInfo;
					Possessor.Possess(M);
				}
				M.Velocity = M.AirSpeed * Vector(M.Rotation);
				M.Acceleration = M.Velocity;
				M.MyTeam = Possessor.PlayerReplicationInfo.Team;
			}

		}
		if (Firemode==3 && canFireMEGADeemer)
		{
        		MissileRot=C.Rotation;
        		M = Spawn(Class'ArbalestMEGAGuidedWarhead',Self,,Location+Vect(0,0,256),MissileRot);

			if (M != None)
			{
				M.OldPawn = Instigator;
				//M.PlaySound(FireSound);
				Possessor = PlayerController(Instigator.Controller);
				Possessor.bAltFire = 0;
				if ( Possessor != None )
				{
					if ( Instigator.InCurrentCombo() )
						Possessor.Adrenaline = 0;
					Possessor.UnPossess();
					Instigator.SetOwner(Possessor);
					Instigator.PlayerReplicationInfo = Possessor.PlayerReplicationInfo;
					Possessor.Possess(M);
				}
				M.Velocity = M.AirSpeed * Vector(M.Rotation);
				M.Acceleration = M.Velocity;
				M.MyTeam = Possessor.PlayerReplicationInfo.Team;
			}
			canFireMEGADeemer=false;
			SetTimer(MEGADeemerReload, false);
		}
	}

	function AltFire(Controller C)
    	{
		firemode++;
		if (firemode>maxfiremode)
			firemode=1;
    	}
	simulated function timer()
	{
		canFireMEGADeemer=true;
	}
}

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;
	
	if (!bAltFire && FireCountdown <= 0)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);

		if (firemode==1 || Firemode==3)
			FireCountdown = FireInterval;
		else
			FireCountdown = AltFireInterval;
		Fire(C);
			
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

		return True;
	}

	if (bAltFire && FireCountdown <= 0)
	{
		FireCountdown = FireInterval;
		AltFire(C);
		Return True;
	}
	return false;
}

defaultproperties
{
     FireMode=1
     maxfiremode=3
     FireModeNames(0)="AA Rockets"
     FireModeNames(1)="Weak Redeemers"
     FireModeNames(2)="Nova Missile"
     canFireMEGADeemer=True
     MEGADeemerReload=120.000000
     WeaponFireAttachmentBone="TankBarrel"
     FireInterval=0.500000
     AltFireInterval=1.000000
     FireSoundClass=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'
     ProjectileClass=Class'ArbalestsV2Omni.ArbalestRocketNovaPrime'
}
