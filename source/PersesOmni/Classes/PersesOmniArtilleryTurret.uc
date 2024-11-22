/******************************************************************************
PersesArtilleryTurret

Creation date: 2011-08-22 16:42
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class PersesOmniArtilleryTurret extends ONSArtilleryCannon;


var() class<Emitter> DriverEffectEmitterClass;

var rotator TargetRotation;
var float NextTargetPredictionTime;


replication
{
	unreliable if (!bNetOwner)
		TargetRotation;
}


/**
Filter fire attempts so player needs to launch and deploy a camera first.
*/
event bool AttemptFire(Controller C, bool bAltFire)
{
	if (MortarCamera == None || MortarCamera.bShotDown)
	{
		// always fire camera first
		//log("No camera yet");
		return Super(ONSWeapon).AttemptFire(C, True);
	}
	else if (!bAltFire && MortarCamera.bDeployed)
	{
		// fire shell if camera is deployed
		//log("Firing shell");
		return Super(ONSWeapon).AttemptFire(C, False);
	}
	// else camera is out but should deploy or disconnect, which is handled by the vehicle
	//log("Not firing");
	return false;
}

function byte BestMode()
{
	// altfire really only takes down the camera, which the bots handles differently anyway
	return 0;
}

simulated event FlashMuzzleFlash()
{
    local PlayerController PC;
	
	PC = Level.GetLocalPlayerController();
	if (PC != None && PC.Pawn == Base && PC.ViewTarget == Base)
		EffectEmitterClass = DriverEffectEmitterClass;
	else
		EffectEmitterClass = default.EffectEmitterClass;
		
	Super.FlashMuzzleFlash();
}

function bool CanAttack(Actor Other)
{
	local rotator TestFireRotation;
	local float TestFireSpeed;
	
	if (Instigator == None || Bot(Instigator.Controller) == None)
		return false;
	
	// short range and direct line of sight (use like shotgun against fliers, if necessary)
	if (Other == Instigator.Controller.Enemy && VSize(Other.Location - Location) < 3000 && Bot(Instigator.Controller).EnemyVisible())
		return true;
	
	// don't bother attacking fast vehicles and fliers if they are not our enemy or too far away
	if (ONSVehicle(Other) != None && ONSVehicle(Other).FastVehicle() || Pawn(Other) != None && Pawn(Other).bCanFly)
		return false; 
	
	// long range, do quick trajectory check, ignoring other players
	if (GetFireDirection(Other.Location, TestFireRotation, TestFireSpeed) && TestTrajectory(Other.Location, TestFireRotation, TestFireSpeed, true))
		return true;
	
	return false;
}


function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	local Projectile P;
	local PersesOmniArtilleryCameraShell CamProj;
	local PersesOmniArtilleryShell ShellProj;
	local coords BarrelCoords;
	local vector HitLocation, HitNormal;
	local Controller C;
	local ONSIncomingShellSound ShellSoundMarker;

	if (!Instigator.IsLocallyControlled() || !Instigator.IsHumanControlled())
		PredictTarget();
	
	BarrelCoords = GetBoneCoords(PitchBone);
	if (Base.Trace(HitLocation, HitNormal, WeaponFireLocation, BarrelCoords.Origin, false, vect(0,0,0)) != None)
	{
		//log("Barrel clipping through world geometry");
		return None;
	}
	
	P = Super(ONSWeapon).SpawnProjectile(ProjClass, bAltFire);
	
	CamProj = PersesOmniArtilleryCameraShell(P);
	if (CamProj == None)
	{
		ShellProj = PersesOmniArtilleryShell(P);
		if (ShellProj != None)
		{
			if (MortarCamera == None)
			{
				ShellProj.LifeSpan = 0.3;
			}
			else
			{
				PersesOmniArtilleryCameraShell(MortarCamera).ShowSelf(false);
				ShellProj.Velocity = vector(WeaponFireRotation) * Lerp(WeaponCharge, MinSpeed, MaxSpeed);
				
				for (C = Level.ControllerList; C != None; C = C.nextController)
				{
					if (PlayerController(C) != None)
						PlayerController(C).ClientPlaySound(Sound'DistantBooms.DistantSPMA', true, 1);
				}

				ShellProj.StartTimer(FMax(0.6 * PredicatedTimeToImpact, 0.8 * PredicatedTimeToImpact - 0.7));
				ShellSoundMarker = Spawn(class'PersesOmniArtilleryIncomingShellSound', None, '', PredictedTargetLocation + vect(0,0,400));
				ShellSoundMarker.StartTimer(PredicatedTimeToImpact);
			}
		}
	}
	else if (Role == ROLE_Authority)
	{
		if (PlayerController(Instigator.Controller) != None)
		{
			PlayerController(Instigator.Controller).ClientSetViewTarget(CamProj);
			PlayerController(Instigator.Controller).SetViewTarget(CamProj);
			PlayerController(Instigator.Controller).bBehindView = False;
			CamProj.Velocity = vector(WeaponFireRotation) * MaxSpeed;
		}
		else
			CamProj.Velocity = vector(WeaponFireRotation) * Lerp(WeaponCharge, MinSpeed, MaxSpeed);
		MortarCamera = CamProj;
		if (PersesOmniArtilleryTurretPawn(Instigator) != None)
			PersesOmniArtilleryTurretPawn(Instigator).MortarCamera = CamProj;
	}
		
	return P;
}


simulated function Tick(float DeltaTime)
{
	if (Role == ROLE_Authority)
	{
		// center turret if unoccupied
		if (Instigator != None && Instigator.Controller != None)
		{
			bForceCenterAim = False;
			bAimable = True;
			if (Level.TimeSeconds > NextTargetPredictionTime)
				PredictTarget();
		}
		else if (!bActive && CurrentAim != rot(0,0,0))
		{
			bForceCenterAim = True;
			bActive = True;
		}
		else if (bActive && CurrentAim == rot(0,0,0))
		{
			bActive = False;
		}
	}
	else if (Instigator != None && !Instigator.IsLocallyControlled())
	{
		Instigator.SetRotation(TargetRotation);
	}
	Super.Tick(DeltaTime);
}

/**
Returns whether the target offset is reachable, assuming clear shot.
Outputs the fire rotation that will get the shot to the desired target area.
*/
simulated function bool GetFireDirection(vector TargetLocation, optional out rotator FireRotation, optional out float FireSpeedFactor)
{
	local float dxy, dz, g;
	local float vXY, vZ, bestV, thisV;
	local float bestVXY, bestVZ;
	local vector /*PitchBoneOrigin, YawBoneOrigin, FireOffset,*/ TargetDirection;
	
	/* FIXME: predict WeaponFireLocation for target direction
	// approximate fire start for target direction
	YawBoneOrigin = GetBoneCoords(YawBone).Origin;
	FireOffset = WeaponFireLocation - YawBoneOrigin;
	FireOffset = (FireOffset >> rot(0,-1,0) * WeaponFireRotation.Yaw) >> rot(0,1,0) * rotator(TargetLocation - YawBoneOrigin).Yaw;
	*/
	TargetDirection = TargetLocation - WeaponFireLocation;
	g = Instigator.PhysicsVolume.Gravity.Z;
	dz = TargetDirection.Z;
	TargetDirection.Z = 0;
	dxy = VSize(TargetDirection);
	
	bestVXY = MinSpeed;
	bestVZ = dz * bestVXY / dxy - 0.5 * g * dxy / bestVXY;
	bestV  = Sqrt(Square(bestVXY) + Square(bestVZ));
	
	for (vXY = bestVXY + 200; vXY <= MaxSpeed; vXY += 200) {
		vZ = dz * vXY / dxy - 0.5 * g * dxy / vXY;
		thisV = Sqrt(Square(vXY) + Square(vZ));
		if (thisV < bestV) {
			bestVXY = vXY;
			bestVZ = vZ;
			bestV  = thisV;
		}
	}
	
	TargetDirection = Normal(TargetDirection) * bestVXY;
	TargetDirection.Z = bestVZ;
	FireRotation = rotator(TargetDirection);
	FireSpeedFactor = FClamp((bestV - MinSpeed) / (MaxSpeed - MinSpeed), 0.0, 1.0);
	
	return bestV <= MaxSpeed;
}

simulated function bool TestTrajectory(vector TargetLocation, rotator FireRotation, float FireSpeedFactor, bool bIgnoreActors, optional out vector HitLocation)
{
	local vector x0, v0, gHalf, LastLoc, NextLoc;
	local float tMax, t;
	local vector HitNormal;
	
	x0 = WeaponFireLocation; //GetBoneCoords(PitchBone).Origin;
	v0 = Lerp(FireSpeedFactor, MinSpeed, MaxSpeed, True) * vector(FireRotation);
	gHalf = 0.5 * Instigator.PhysicsVolume.Gravity;
	tMax = VSize((TargetLocation - x0) * vect(1,1,0)) / VSize(v0 * vect(1,1,0)) + 0.5 * TargetPredictionTimeStep;
	
	LastLoc = x0;
	for (t = TargetPredictionTimeStep; LastLoc.Z > Level.KillZ && t < tMax; t += TargetPredictionTimeStep)
	{
		NextLoc = x0 + v0 * t + gHalf * Square(t);
		if (Trace(HitLocation, HitNormal, NextLoc, LastLoc, /*!bIgnoreActors*/ False, vect(0,0,0)) != None)
		{
			return VSize(HitLocation - TargetLocation) < FMax(100.0, 0.001 * VSize(x0 - TargetLocation));
		}
		LastLoc = NextLoc;
	}
	
	if (t > tMax)
	{
		if (Trace(HitLocation, HitNormal, TargetLocation, LastLoc, !bIgnoreActors, vect(0,0,0)) == None)
			HitLocation = TargetLocation;
	}
	else
	{
		HitLocation = LastLoc;
	}
	return true;
}

simulated function PredictTarget()
{
	local float Vel2D, Dist2D, NewWeaponCharge;
	local Bot B;
	local Pawn TargetPawn;
	
	B = Bot(Instigator.Controller);
	if (B == None && (PersesOmniArtilleryCameraShell(MortarCamera) == None || !MortarCamera.bDeployed))
		return;
	
	NextTargetPredictionTime = Level.TimeSeconds + 0.1;
	CalcWeaponFire();
	if (Instigator.IsLocallyControlled())
	{
		if (B != None)
		{
			if (B.Target != None)
			{
				TargetPawn = Pawn(B.Target);
				PredictedTargetLocation = B.Target.Location;
			}
			else if (B.Enemy != None)
			{
				TargetPawn = B.Enemy;
				PredictedTargetLocation = B.Enemy.Location;
			}
			else
			{
				PredictedTargetLocation = B.FocalPoint;
			}
			
			// higher skill bots try to predict a moving target's future location
			if (B.Skill + B.Tactics > 4 && TargetPawn != None && !TargetPawn.bStationary)
			{
				// iteratively use the predicted time to target for the next predicted target location
				PredictedTargetLocation += Normal(TargetPawn.Velocity) * (FMin(VSize(TargetPawn.Velocity), 1500.0) * FMin(PredicatedTimeToImpact, 4.0));
			}
		}
		else if (PersesOmniArtilleryCameraShell(MortarCamera) != None)
		{
			PredictedTargetLocation = PersesOmniArtilleryCameraShell(MortarCamera).TargetLocation;
		}
		
		bCanHitTarget = GetFireDirection(PredictedTargetLocation, TargetRotation, NewWeaponCharge);
		SetWeaponCharge(NewWeaponCharge);
		
		if (bCanHitTarget)
		{
			bCanHitTarget = TestTrajectory(PredictedTargetLocation, TargetRotation, NewWeaponCharge, False, PredictedTargetLocation);
		}
		
		if (MortarCamera != None)
		{
			MortarCamera.SetReticleStatus(bCanHitTarget);
		}
		
		Vel2D = VSize(vector(TargetRotation) * vect(1,1,0)) * Lerp(WeaponCharge, MinSpeed, MaxSpeed);
		Dist2D = VSize((PredictedTargetLocation - WeaponFireLocation) * vect(1,1,0));
		PredicatedTimeToImpact = Dist2D / Vel2D;
	}
	else
	{
		// predict target location based on fire parameters send by client
		PredictTargetLocation(Lerp(WeaponCharge, MinSpeed, MaxSpeed), vector(PersesOmniArtilleryTurretPawn(Instigator).CustomAim));
	}
}

function PredictTargetLocation(float Speed, vector Direction)
{
	local vector x0, v0, gHalf, LastLoc, NextLoc;
	local float t, Vel2D, Dist2D;
	local vector HitLocation, HitNormal;
	local actor HitActor, TraceActor;
	
	x0 = WeaponFireLocation;
	v0 = Speed * Direction;
	gHalf = 0.5 * Instigator.PhysicsVolume.Gravity;
	
	LastLoc = x0;
	TraceActor = Self;
	for (t = TargetPredictionTimeStep; LastLoc.Z > Level.KillZ; t += TargetPredictionTimeStep) {
		NextLoc = x0 + v0 * t + gHalf * Square(t);
		HitActor = TraceActor.Trace(HitLocation, HitNormal, NextLoc, LastLoc, true, vect(0,0,0));
		if (HitActor != None)
		{
			LastLoc = HitLocation;
			if (Projectile(HitActor) == None && HitActor != Base)
				break;
			
			TraceActor = HitActor;
			t -= TargetPredictionTimeStep;
		}
		else
		{
			LastLoc = NextLoc;
		}
	}
	// LastLoc now is the impact location
	
	PredictedTargetLocation = LastLoc;
	Vel2D = VSize(v0 * vect(1,1,0));
	Dist2D = VSize((PredictedTargetLocation - x0) * vect(1,1,0));
	PredicatedTimeToImpact = Dist2D / Vel2D;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     DriverEffectEmitterClass=Class'Onslaught.ONSTankFireEffect'
     PitchUpLimit=16000
     PitchDownLimit=65000
     WeaponFireOffset=0.000000
     RotationsPerSecond=0.500000
     bDoOffsetTrace=True
     FireIntervalAimLock=0.300000
     FireInterval=3.500000
     AltFireInterval=1.500000
     ProjectileClass=Class'PersesOmni.PersesOmniArtilleryShell'
     AltFireProjectileClass=Class'PersesOmni.PersesOmniArtilleryCameraShell'
}
