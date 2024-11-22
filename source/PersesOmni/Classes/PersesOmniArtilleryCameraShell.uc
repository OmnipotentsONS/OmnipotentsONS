/******************************************************************************
PersesArtilleryCameraShell

Creation date: 2011-08-22 17:04
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/


class PersesOmniArtilleryCameraShell extends ONSMortarCamera;


/** Camera view offset scale. Interpolated to 0 while deploying. */
var float CVScale;

/** Maximum target trace range from camera. */
var float MaxTargetRange;

var Sound DeploySound, DeployedAmbientSound;

/** Player's aiming target location. */
var vector TargetLocation, TargetNormal;

var float NextAIDeployCheck;


var PersesOmniArtilleryTrajectory Trajectory;


function BeginPlay()
{
	// set up deploy check/message
	NextAIDeployCheck = Level.TimeSeconds + 1;
	SetTimer(0.25, false);
}

simulated function PostBeginPlay()
{
	if (!PhysicsVolume.bWaterVolume && Level.NetMode != NM_DedicatedServer)
		Trail = Spawn(class'FlakShellTrail', self);

	Super(Projectile).PostBeginPlay();

    if (Instigator != None)
        TeamNum = Instigator.GetTeamNum();
}

simulated function Destroyed()
{
	if (!bShotDown)
		ShotDown();
	
	if (Trajectory != None)
		Trajectory.Destroy();
	
	Super.Destroyed();
}

// unused by camera
function StartTimer(float Fuse);

// send deployment hint
function Timer()
{
	if (Instigator != None && PlayerController(Instigator.Controller) != None && PlayerController(Instigator.Controller).ViewTarget == Self)
	{
		PlayerController(Instigator.Controller).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 34);
	}
	
}

function bool IsStationary()
{
	return bDeployed && !bShotDown;
}

function Deploy()
{
	AnnounceTargetTime = Level.TimeSeconds + 1.5;
	DeployCamera();
}

simulated function DeployCamera()
{
	if (bShotDown)
	{
		// can't deploy if already disconnected
		return;
	}
	bDeployed = True;
	Velocity = vect(0,0,0);
	SpawnThrusters();
	SetPhysics(PHYS_Projectile);
	bOrientToVelocity = False;
	DesiredRotation = rot(-16384,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	RotationRate = rot(16384,16384,16384);
	bRotateToDesired = True;
	PlaySound(DeploySound);
	AmbientSound = DeployedAmbientSound;
	PlayAnim('Deploy', 1.0, 0.0);
	if (Trajectory == None)
		Trajectory = Spawn(class'PersesOmniArtilleryTrajectory', Self, '', Location);
	if (Trail != None)
		Trail.mRegen = False;
}

simulated event EndedRotation()
{
	bRotateToDesired = False;
	RotationRate = rot(0,0,0);
}

simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
	if (NewVolume.bWaterVolume)
		ShotDown();
}

// obsolete
function SetTarget(vector loc);

simulated function UpdateTargetLocation(vector NewTargetLocation, vector NewTargetNormal)
{
	local vector X, Y;
	
	TargetLocation = NewTargetLocation;
	TargetNormal   = NewTargetNormal;
	
	if (TargetBeam == None) {
		TargetBeam = Spawn(class'PersesOmniArtilleryTargetReticle', self,, Location, rot(0,0,0));
		TargetBeam.ArtilleryLocation = Instigator.Location;
	}
	if (TargetBeam != None) {
		TargetBeam.SetLocation(TargetLocation);
		
		// reticle StaticMesh uses TargetNormal as Z direction
		Y = Normal(TargetNormal Cross (TargetLocation - Instigator.Location));
		X = -(TargetNormal Cross Y);
		TargetBeam.SetRotation(OrthoRotation(X, Y, TargetNormal));
	}
}


/**
Reveal the camera to enemy bots, giving them a chance to target it.
*/
function ShowSelf(bool bCheckFOV)
{
	local Controller C;
	local Bot B;
	
	if (!bShotDown)
	{
		for (C = Level.ControllerList; C != None; C = C.NextController)
		{
			B = Bot(C);
			if (B != None && !B.SameTeamAs(Instigator.Controller) && B.Pawn != None && !B.Pawn.IsFiring() && (B.Enemy == None || B.Enemy == Instigator || B.Skill + B.Tactics > 2.0 + 3.0 * FRand() && !B.EnemyVisible()) && (!bCheckFOV || Normal(B.FocalPoint - B.Pawn.Location) dot (Location - B.Pawn.Location) > B.Pawn.PeripheralVision) && B.LineOfSightTo(self))
			{
				// give B a chance to shoot at me
				B.GoalString = "Destroy Mortar Camera";
				B.Target = self;
				B.SwitchToBestWeapon();
				if (B.Pawn.CanAttack(self))
				{
					B.DoRangedAttackOn(self);
					if (FRand() < 0.5)
						break;
				}
			}
		}
	}
}

// non-tick part of UT3 CalcCamera()
simulated function bool SpecialCalcView(out Actor ViewActor, out vector CameraLocation, out rotator CameraRotation, bool bBehindView)
{
	local vector HitNormal, HitLocation;
	
	ViewActor = Self;
	
	if (bBehindView)
		CameraLocation = Location + (MortarCameraOffset >> CameraRotation);
	else
		CameraLocation = Location + ((MortarCameraOffset * CVScale) >> CameraRotation);
	if (Trace(HitLocation, HitNormal, CameraLocation, Location, false, vect(12,12,12)) != None)
		CameraLocation = HitLocation;
	
	return True;
}

simulated function POVChanged(PlayerController PC, bool bBehindViewChanged)
{
	// always use first-person view so the camera is no longer rendered when setting bOwnerNoSee
	PC.bBehindView = False;
}

simulated function ShotDown()
{
	if (Instigator != None && PlayerController(Instigator.Controller) != None && PlayerController(Instigator.Controller).ViewTarget == Self)
	{
		if (Instigator.Controller.Pawn != None)
		{
			PlayerController(Instigator.Controller).bBehindView = Instigator.Controller.Pawn.PointOfView();
			PlayerController(Instigator.Controller).SetViewTarget(Instigator.Controller.Pawn);
		}
		else
		{
			PlayerController(Instigator.Controller).bBehindView = False;
			PlayerController(Instigator.Controller).SetViewTarget(Instigator.Controller);
		}
	}
	
	if (TargetBeam != None)
		TargetBeam.Destroy();
	
	if (Trajectory != None)
		Trajectory.Destroy();
	
	if (ONSArtilleryCannon(Owner) != None)
		ONSArtilleryCannon(Owner).AllowCameraLaunch();
	
	if (PersesOmniArtilleryTurretPawn(Instigator) != None)
		PersesOmniArtilleryTurretPawn(Instigator).MortarCamera = None;
	
    PlaySound(Sound'ONSBPSounds.Artillery.CameraShotDown', SLOT_None, 1.5);
    SetPhysics(PHYS_Falling);
	LifeSpan = FMin(LifeSpan, 5);
	bShotDown = True;
}

simulated function SpawnEffects(vector HitLocation, vector HitNormal)
{
	Super(ONSMortarShell).SpawnEffects(HitLocation, HitNormal);
}

/**
Slightly modified version of ONSMortarCamera::PostNetReceive() to account for
bDeployed reverting to False when shot down or manually disconnected.
*/
simulated function PostNetReceive()
{
	Super(ONSMortarShell).PostNetReceive();
	
	if (bDeployed != bLastDeployed)
	{
		bLastDeployed = bDeployed;
		if (bDeployed)
			DeployCamera();
	}
	
	if (bShotDown != bLastShotDown)
	{
		bLastShotDown = bShotDown;
		if (bShotDown)
			ShotDown();
	}
	
	if (RealLocation != LastRealLocation)
	{
		SetLocation(RealLocation);
		LastRealLocation = RealLocation;
	}
}

simulated function Tick(float DeltaTime)
{
	local vector HitNormal, HitLocation;
	local float TargetRange;
	local PersesOmniArtilleryTurret TurretOwner;

	if (bShotDown || PersesOmniArtilleryTurretPawn(Instigator) == None || PersesOmniArtilleryTurretPawn(Instigator).Driver == None)
	{
		if (!bShotDown && Role == ROLE_Authority)
		{
			ShotDown();
			Disable('Tick');
		}
		return;
	}

	if (Region.Zone != None && Region.Zone.bDistanceFog)
		TargetRange = FMin(MaxTargetRange, Region.Zone.DistanceFogEnd);
	else
		TargetRange = MaxTargetRange;
	
	if (!bDeployed)
	{
		TargetLocation = Location;
	}
	else
	{
		if (CVScale > 0)
		{
			CVScale -= DeltaTime * 0.8;
			if (CVScale <= 0)
				CVScale = 0;
			if (CVScale < 0.25 && !bOwnerNoSee)
				bOwnerNoSee = true;
		}
		if (Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
		{
			if (Trace(HitLocation, HitNormal, Location + vector(Instigator.Controller.Rotation) * TargetRange,, True) == None)
			{
				HitLocation = Location + vector(Instigator.Controller.Rotation) * TargetRange;
				HitNormal = vect(0,0,1);
			}
			else
			{
				HitLocation += HitNormal * 50.0;
			}
			UpdateTargetLocation(HitLocation, HitNormal);
			
			TurretOwner = PersesOmniArtilleryTurret(Owner);
			TurretOwner.PredictTarget();
			
			if (Trajectory != None)
			{
				if (TurretOwner.FireCountdown <= 0 && vector(TurretOwner.WeaponFireRotation) dot vector(TurretOwner.TargetRotation) > 0.99)
				{
					Trajectory.UpdateTrajectory(True, TurretOwner.WeaponFireLocation, vector(TurretOwner.WeaponFireRotation) * Lerp(TurretOwner.WeaponCharge, TurretOwner.MinSpeed, TurretOwner.MaxSpeed), -PhysicsVolume.Gravity.Z, Region.Zone.KillZ, TurretOwner.bCanHitTarget);
				}
				else
				{
					Trajectory.UpdateTrajectory(False);
				}
			}
		}
	}
	
	if (Role < ROLE_Authority)
		return;
	
	if (!bDeployed)
	{
		if (Instigator != None && AIController(Instigator.Controller) != None && NextAIDeployCheck <= Level.TimeSeconds)
		{
			// try deploying if well into target range and have line of sight
			if (Instigator.Controller.Target != None && VSize(Instigator.Controller.Target.Location - Location) < 0.8 * TargetRange && LineOfSightTo(Instigator.Controller.Target))
			{
				Deploy();
			}
			else
			{
				NextAIDeployCheck = Level.TimeSeconds + 0.1;
			}
		}
	}
	else if (Level.TimeSeconds > AnnounceTargetTime)
	{
		AnnounceTargetTime = Level.TimeSeconds + 1.5;
		ShowSelf(True);
	}
}

/**
Simplified version of Controller.LineOfSightTo() that checks from this camera's location.
*/
function bool LineOfSightTo(Actor Other)
{
	local float dist;
	local vector X, Y, Z;

	if (Other == None)
		return False;

	dist = VSize(Location - Other.Location);
	if (dist > 1.1 * MaxTargetRange || Region.Zone.bDistanceFog && dist > Region.Zone.DistanceFogEnd + Other.CollisionRadius + Other.CollisionHeight)
		return false; // hidden in distance fog or beyond target range

	if (FastTrace(Other.Location, Location))
		return true;
	
	if (Other.CollisionHeight > 0 && FastTrace(Other.Location + vect(0,0,0.8) * Other.CollisionHeight, Location))
		return true;
	
	// only check sides if width of other is significant compared to distance
	if (Other.CollisionRadius / dist < 0.01)
		return false;

	GetAxes(rotator(Other.Location - Location), X, Y, Z); // we need Y to calculate cylinder side location (yes, I'm lazy)

	return FastTrace(Other.Location + Y * Other.CollisionRadius, Location) || FastTrace(Other.Location - Y * Other.CollisionRadius, Location);
}

simulated function ExplodeInAir()
{
	bExploded = true;
	PlaySound(ImpactSound, SLOT_None, 2.0);
	if (Level.NetMode != NM_DedicatedServer)
		Spawn(AirExplosionEffectClass);
	
	Explode(Location, Normal(Velocity));
	Destroy();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     CVScale=1.000000
     MaxTargetRange=10000.000000
     MortarCameraOffset=(X=-256.000000,Z=128.000000)
     ExplosionEffectClass=Class'PersesOmni.PersesOmniArtilleryAirExplosion'
     AirExplosionEffectClass=Class'PersesOmni.PersesOmniArtilleryAirExplosion'
     MyDamageType=Class'PersesOmni.DamTypePersesOmniArtilleryShell'
     ImpactSound=Sound'UT3SPMA.SPMAShellFragmentExplode'
     bAlwaysRelevant=True
     TransientSoundRadius=500.000000
     CollisionRadius=80.000000
     CollisionHeight=60.000000
     bOrientToVelocity=True
}
