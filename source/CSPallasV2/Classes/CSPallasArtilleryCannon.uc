//-----------------------------------------------------------
// 
//-----------------------------------------------------------
class CSPallasArtilleryCannon extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSBPAnimations.ukx
#exec OBJ LOAD FILE=VMParticleTextures.utx
#exec OBJ LOAD FILE=ONSBPTextures.utx
#exec OBJ LOAD FILE=ONSBPSounds.uax
#exec OBJ LOAD FILE=DistantBooms.uax
#exec AUDIO IMPORT FILE=Sounds\bigshell.wav
#exec AUDIO IMPORT FILE=Sounds\artilleryambient.wav
#exec AUDIO IMPORT FILE=Sounds\weaponrotate.wav
//#exec TEXTURE IMPORT FORMAT=DXT5 FILE=Textures\CSPallasArtilleryTurretRed.dds
//#exec TEXTURE IMPORT FORMAT=DXT5 FILE=Textures\CSPallasArtilleryTurretBlue.dds
#exec OBJ LOAD FILE=Textures\CSPallasTex.utx PACKAGE=CSPallasV2

var ONSMortarShell MortarShell, LastMortarShell;
var CSPallasMortarCamera MortarCamera;
var CSPallasArtilleryTrajectory Trajectory;

var rotator TargetRotation;
var float NextTargetPredictionTime;

var float StartHoldTime;
var float MaxHoldTime; //wait this long between shots for full damage
var float MinSpeed, MaxSpeed;
var float MortarSpeed;
var bool bHoldingFire;
var bool bCanHitTarget;
var sound ChargingSound, ChargedLoop;
var float TargetPredictionTimeStep;
var float WeaponCharge;
var vector PredictedTargetLocation;
var float PredictedTimeToImpact;
var float LastCameraLaunch;
var float CameraLaunchWait;
var float LastBeepTime;
var() float TrajectoryErrorFactor;
var int CameraAttempts;

replication
{
    //reliable if (True)
    reliable if (bNetOwner && (Role == ROLE_Authority))
        MortarCamera;

    reliable if (Role < ROLE_Authority)
        ServerSetWeaponCharge;

	unreliable if (!bNetOwner)
		TargetRotation;
}

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'CSPallasV2.CSPallasArtilleryTurretRed');
    L.AddPrecacheMaterial(Material'CSPallasV2.CSPallasArtilleryTurretBlue');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'CSPallasV2.CSPallasArtilleryTurretRed');
    Level.AddPrecacheMaterial(Material'CSPallasV2.CSPallasArtilleryTurretBlue');

    Super.UpdatePrecacheMaterials();
}

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
// =====================================================================
// AI Interface

function AllowCameraLaunch()
{
	CameraAttempts = 0;
	LastCameraLaunch = Level.TimeSeconds - CameraLaunchWait;
}

function bool CanAttack(Actor Other)
{
    local actor HitActor;
    local vector HitNormal, HitLocation;

	if ( (Instigator == None) || (Instigator.Controller == None) )
        return false;

	if ( (Bot(Instigator.Controller) != None) && (Level.TimeSeconds - CSPallasVehicle(Owner).StartDrivingTime < 1) )
		return false;

	if ( MortarCamera == None )
	{
		if ( ((Level.TimeSeconds - LastCameraLaunch > CameraLaunchWait) && (VSize(Other.Location - Location) < 15000))
			|| ((Other == Instigator.Controller.Enemy) && (VSize(Other.Location - Location) < 4000) && Bot(Instigator.Controller).EnemyVisible()) )
			return true;
	}
	else
	{
		if ( !MortarCamera.bDeployed )
			return true;
		HitActor = Trace(HitLocation, HitNormal, Other.Location, MortarCamera.Location, false);
		if ( HitActor != None )
		{
            MortarCamera.Destroy();
            FireCountDown = AltFireInterval;
		}
		return true;
	}
	return false;
}

function byte BestMode()
{
	local bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Target == None) )
		return 0;

	if ( MortarCamera == None )
	{
		if ( VSize(B.Pawn.Location - B.Target.Location) > 4000 )
			return 1;
		if ( B.Target == B.Enemy )
		{
			if ( !B.EnemyVisible() )
				return 1;
		}
		else if ( !B.LineOfSightTo(B.Target) )
			return 1;
	}

	return 0;
}

function float CalcZSpeed(float XYSpeed, float FlightSize, float FlightZ)
{
	local float FlightTime;

	FlightTime = FlightSize/XYSpeed;
	if ( FlightTime == 0 )
		return XYSpeed;

	return FlightZ/FlightTime - 0.5 * PhysicsVolume.Gravity.Z * FlightTime;
}

/* SetMuzzleVelocity()
return adjustment to Z component of aiming vector to compensate for arc given the target
distance
*/
function vector SetMuzzleVelocity(vector Start, vector End, float StartXYPct)
{
	local vector Flight, FlightDir, TraceStart, TraceEnd, StartVel, HitLocation, HitNormal, Mid1, Mid2, Mid3;
	local float XYSpeed, ZSpeed, XYPct, FlightZ, FlightSize, FlightTime;
	local bool bFailed;
	local Actor HitActor;

	Flight = End - Start;
	FlightZ = Flight.Z;
	Flight.Z = 0;
	FlightSize = VSize(Flight);

	XYPct = StartXYPct;
	XYSpeed = XYPct*MaxSpeed;
	ZSpeed = CalcZSpeed(XYSpeed, FlightSize, FlightZ);

	while ( (XYPct < 1.0) && (ZSpeed*ZSpeed + XYSpeed * XYSpeed > MaxSpeed * MaxSpeed) )
	{
		// pick an XYSpeed
		XYPct += 0.05;
		XYSpeed = XYPct*MaxSpeed;
		ZSpeed = CalcZSpeed(XYSpeed, FlightSize, FlightZ);
	}

	// trace check trajectory
	bFailed = true;
	FlightDir = Normal(Flight);
	while ( bFailed && (XYPct > 0) )
	{
		StartVel = XYSpeed*FlightDir + ZSpeed*vect(0,0,1);
		TraceStart = Start;
		FlightTime = 0.25 * FlightSize/XYSpeed;
		TraceEnd = Start + StartVel*FlightTime + (0.5 * PhysicsVolume.Gravity.Z * FlightTime * FlightTime ) * vect(0,0,1) - vect(0,0,40);
		Mid1 = TraceEnd;

		if ( FastTrace(TraceEnd,TraceStart) )
		{
			// next segment
			TraceStart = TraceEnd;
			FlightTime = 0.5 * FlightSize/XYSpeed;
			TraceEnd = Start + StartVel*FlightTime + (0.5 * PhysicsVolume.Gravity.Z * FlightTime * FlightTime ) * vect(0,0,1) - vect(0,0,40);
			Mid2 = TraceEnd;
			if ( FastTrace(TraceEnd,TraceStart) )
			{
				// next segment
				TraceStart = TraceEnd;
				FlightTime = 0.75 * FlightSize/XYSpeed;
				TraceEnd = Start + StartVel*FlightTime + (0.5 * PhysicsVolume.Gravity.Z * FlightTime * FlightTime ) * vect(0,0,1) - vect(0,0,40);
				Mid3 = TraceEnd;
				if ( FastTrace(TraceEnd,TraceStart) )
				{
					// next segment
					TraceStart = TraceEnd;
					FlightTime = FlightSize/XYSpeed;
					TraceEnd = Start + StartVel*FlightTime + (0.5 * PhysicsVolume.Gravity.Z * FlightTime * FlightTime ) * vect(0,0,1);
					bFailed = !FastTrace(TraceEnd,TraceStart);
				}
			}

			if ( !bFailed )
			{
				// trace with extent check since projectile has extent
				HitActor = Trace(HitLocation, HitNormal, Mid2, Mid1, false, vect(20,20,20));
				if ( HitActor == None )
				{
					HitActor = Trace(HitLocation, HitNormal, Mid3, Mid2, false, vect(20,20,20));
					if ( HitActor == None )
					{
						HitActor = Trace(HitLocation, HitNormal, Mid1, Start, false, vect(20,20,20));
					}
				}
				bFailed = ( HitActor != None );
			}
		}

		if ( bFailed )
		{
			// if failed and trajectory already lowered, destroy camera
			if ( XYPct > StartXYPct )
			{
				CameraAttempts = 0;
				LastCameraLaunch = Level.TimeSeconds;
				if ( MortarCamera != None )
				{
					MortarCamera.Destroy();
					FireCountDown = AltFireInterval;
				}
				bFailed = false;
			}
			else
			{
				// else raise trajectory
				XYPct -= 0.1;
				XYSpeed = XYPct*MaxSpeed;
				ZSpeed = CalcZSpeed(XYSpeed, FlightSize, FlightZ);
				if ( ZSpeed*ZSpeed + XYSpeed * XYSpeed > MaxSpeed * MaxSpeed )
				{
					CameraAttempts = 0;
					LastCameraLaunch = Level.TimeSeconds;
					if ( MortarCamera != None )
					{
						MortarCamera.Destroy();
						FireCountDown = AltFireInterval;
					}
					bFailed = false;
				}
			}
		}
	}
	return XYSpeed*FlightDir + ZSpeed*vect(0,0,1);
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local vector StartLocation, HitLocation, HitNormal, Extent, TargetLoc;
    local ONSIncomingShellSound ShellSoundMarker;
    local Controller C;
    local CSPallasVehicle pallasVehicle;

	local bool bFailed;

	if (!Instigator.IsLocallyControlled() || !Instigator.IsHumanControlled())
		PredictTarget();

    pallasVehicle = CSPallasVehicle(Owner);

    for ( C=Level.ControllerList; C!=None; C=C.nextController )
		if ( PlayerController(C)!=None  && pallasVehicle != None)
		{
            if(pallasVehicle.MortarCamera != None)
            {
                PlayerController(C).ClientPlaySound(sound'CSPallasV2.artilleryambient',true,1);
            }
		}

	if ( AIController(Instigator.Controller) != None )
	{
		if ( Instigator.Controller.Target == None )
		{
			if ( Instigator.Controller.Enemy != None )
				TargetLoc = Instigator.Controller.Enemy.Location;
			else
				TargetLoc = Instigator.Controller.FocalPoint;
		}
		else
			TargetLoc = Instigator.Controller.Target.Location;

		if ( !bAltFire && ((MortarCamera == None) || MortarCamera.bShotDown)
			&& ((VSize(TargetLoc - WeaponFireLocation) > 4000) || !Instigator.Controller.LineOfSightTo(Instigator.Controller.Target)) )
		{
			ProjClass = AltFireProjectileClass;
			bAltFire = true;
		}
	}
    if (bDoOffsetTrace)
    {
       	Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
        Extent.Z = ProjClass.default.CollisionHeight;
        if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
            StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
    }
    else
    	StartLocation = WeaponFireLocation;

    P = spawn(ProjClass, self, , StartLocation, WeaponFireRotation);

    if (P != None)
    {
 		if ( AIController(Instigator.Controller) == None )
		{
			P.Velocity = Vector(WeaponFireRotation) * P.Speed;
		}
		else
		{
			//BOT
			if ( P.IsA('CSPallasMortarCamera') )
			{
				P.Velocity = SetMuzzleVelocity(StartLocation, TargetLoc,0.25);
				CSPallasMortarCamera(P).TargetZ = TargetLoc.Z;
			}
			else
				P.Velocity = SetMuzzleVelocity(StartLocation, TargetLoc,0.5);
			WeaponFireRotation = Rotator(P.Velocity);
			CSPallasVehicle(Owner).bAltFocalPoint = true;
			CSPallasVehicle(Owner).AltFocalPoint = StartLocation + P.Velocity;
		}
		if ( !P.IsA('CSPallasMortarCamera') )
        {
           if (MortarCamera != None)
            {
				if ( AIController(Instigator.Controller) == None )
				{
					MortarSpeed = FClamp(WeaponCharge * (MaxSpeed - MinSpeed) + MinSpeed, MinSpeed, MaxSpeed);
					ONSMortarShell(P).Velocity = Normal(P.Velocity) * MortarSpeed;
				}
				ONSMortarShell(P).StartTimer(3.0 + (WeaponCharge * 2.5));
                ShellSoundMarker = spawn(class'CSPallasV2.CSPallasIncomingShellSound',,, PredictedTargetLocation + vect(0,0,400));
                ShellSoundMarker.StartTimer(PredictedTimeToImpact);
            }
			//else
				//P.LifeSpan = 2.0;
        }

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

        if (CSPallasMortarCamera(P) != None)
        {
			if (PlayerController(Instigator.Controller) != None 
				&& PlayerController(Instigator.Controller).Pawn != None 
				&& PlayerController(Instigator.Controller).Pawn.IsHumanControlled())
			{
				log("setviewtarget1");
				PlayerController(Instigator.Controller).ClientSetViewTarget(P);
				PlayerController(Instigator.Controller).SetViewTarget(P);
				P.Velocity = vector(WeaponFireRotation) * MaxSpeed;
			}
			else
				P.Velocity = vector(WeaponFireRotation) * Lerp(WeaponCharge, MinSpeed, MaxSpeed);				

			CameraAttempts = 0;
			LastCameraLaunch = Level.TimeSeconds;
            MortarCamera = CSPallasMortarCamera(P);
            if (CSPallasVehicle(Owner) != None)
                CSPallasVehicle(Owner).MortarCamera = MortarCamera;

        }
        else
            MortarShell = ONSMortarShell(P);
    }
	else if ( AIController(Instigator.Controller) != None )
	{
		bFailed = CSPallasMortarCamera(P) == None;
		if ( !bFailed )
		{
			// allow 2 tries
			CameraAttempts++;
			bFailed = ( CameraAttempts > 1 );
		}

		if ( bFailed )
		{
			CameraAttempts = 0;
			LastCameraLaunch = Level.TimeSeconds;
			if ( MortarCamera != None )
			{
				MortarCamera.Destroy();
			}
		}
	}
    return P;
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
        if (!bIsAltFire && (MortarCamera != None) && MortarCamera.bDeployed && !bCanHitTarget)
            return;

		if (bIsAltFire)
			FireCountdown = AltFireInterval;
		else
			FireCountdown = FireInterval;

        FlashMuzzleFlash();

		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);

        // Play firing noise
        if (!bAmbientFireSound)
        {
            if (bIsAltFire)
            {
                if (MortarCamera == None)
                    PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
            }
            else
                PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
	}
	if ( !bIsAltFire && (MortarCamera != None) && MortarCamera.bDeployed && bCanHitTarget && (PlayerController(Instigator.Controller) != None) && (Viewport(PlayerController(Instigator.Controller).Player) != None) )
		PlayerController(Instigator.Controller).ClientPlaySound(FireSoundClass);
}

simulated function SetWeaponCharge(float Charge)
{
    WeaponCharge = Charge;
    if (Role < ROLE_Authority)
        ServerSetWeaponCharge(WeaponCharge);
}

function ServerSetWeaponCharge(float Charge)
{
    WeaponCharge = Charge;
}

function SetTarget(vector loc);

simulated function float ChargeBar()
{
	return FClamp(1.0 - (FireCountDown / FireInterval), 0.0, 1.0);
}

simulated function NotifyDeployed()
{
    local vector LevelCameraPosition;
    local float LevelCameraDistance;

    // Roughly estimate what the WeaponCharge should be so that the reticle is close by
    LevelCameraPosition = MortarCamera.Location;
    LevelCameraPosition.Z = Location.Z;
    LevelCameraDistance = VSize(LevelCameraPosition - Location);
    WeaponCharge = FClamp((LevelCameraDistance - 3400.0)/10000.0, 0.0, 1.0);
}


simulated function PredictTarget()
{
	local float Vel2D, Dist2D, NewWeaponCharge;
	local Bot B;
	local Pawn TargetPawn;
	
	B = Bot(Instigator.Controller);
	if (B == None && MortarCamera == None || (MortarCamera != None && !MortarCamera.bDeployed))
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
				PredictedTargetLocation += Normal(TargetPawn.Velocity) * (FMin(VSize(TargetPawn.Velocity), 1500.0) * FMin(PredictedTimeToImpact, 4.0));
			}
		}
		else if (MortarCamera != None)
		{
			PredictedTargetLocation = MortarCamera.TargetLocation;
		}
		
		bCanHitTarget = GetFireDirection(PredictedTargetLocation, TargetRotation, NewWeaponCharge);
		SetWeaponCharge(NewWeaponCharge);
		
		// test trajectory anyway to calculate correct time to target
		bCanHitTarget = TestTrajectory(PredictedTargetLocation, TargetRotation, NewWeaponCharge, False, PredictedTargetLocation) && bCanHitTarget;
		
		if (MortarCamera != None)
		{
			MortarCamera.SetReticleStatus(bCanHitTarget);
		}
		
		Vel2D = VSize(vector(TargetRotation) * vect(1,1,0)) * Lerp(WeaponCharge, MinSpeed, MaxSpeed);
		Dist2D = VSize((PredictedTargetLocation - WeaponFireLocation) * vect(1,1,0));
		PredictedTimeToImpact = Dist2D / Vel2D;
	}
	else
	{
		// predict target location based on fire parameters send by client
		PredictTargetLocation(Lerp(WeaponCharge, MinSpeed, MaxSpeed), vector(CSPallasVehicle(Owner).CustomAim));
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
	PredictedTimeToImpact = Dist2D / Vel2D;
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
	else if (Instigator != None && !Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
	{
		Instigator.SetRotation(TargetRotation);
	}
	Super.Tick(DeltaTime);
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

defaultproperties
{
     MaxHoldTime=1.500000
     MinSpeed=1000.000000
     MaxSpeed=6000.000000
     TargetPredictionTimeStep=0.300000
     WeaponCharge=0.250000
     CameraLaunchWait=5.000000
     TrajectoryErrorFactor=150.000000
     YawBone="8WheelerTop"
     PitchBone="TurretAttach"
     PitchUpLimit=16000
     PitchDownLimit=49153
     WeaponFireAttachmentBone="Firepoint"
     RotationsPerSecond=0.180000
     bDoOffsetTrace=True
     FireIntervalAimLock=0.300000
     Spread=0.015000
     RedSkin=Shader'CSPallasV2.ArtilleryTurretRedShader'
     BlueSkin=Shader'CSPallasV2.ArtilleryTurretBlueShader'
     FireInterval=3.000000
     AltFireInterval=3.000000
     EffectEmitterClass=Class'OnslaughtBP.ONSShockTankMuzzleFlash'
     FireSoundClass=Sound'CSPallasV2.bigshell'
     FireSoundVolume=512.000000
     AltFireSoundClass=Sound'CSPallasV2.bigshell'
     //RotateSound=Sound'ONSBPSounds.Artillery.CannonRotate'
     RotateSound=Sound'CSPallasV2.weaponrotate'
     FireForce="Explosion05"
     ProjectileClass=Class'CSPallasV2.CSPallasMortarShell'
     AltFireProjectileClass=Class'CSPallasV2.CSPallasMortarCamera'
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     AIInfo(0)=(bTossed=True,bTrySplash=True,bLeadTarget=True,WarnTargetPct=1.000000,RefireRate=0.990000)
     AIInfo(1)=(bTossed=True,bTrySplash=True,bLeadTarget=True,WarnTargetPct=1.000000,RefireRate=0.990000)
     Mesh=SkeletalMesh'ONSBPAnimations.ShockTankCannonMesh'
}
