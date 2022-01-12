//-----------------------------------------------------------
// borrowed some from wormbo
//-----------------------------------------------------------
class CSPallasMortarCamera extends ONSMortarCamera;

var CSPallasArtilleryTrajectory Trajectory;
var float MaxTargetRange;
var float TargetRange;
var float CVScale;
var vector TargetLocation, TargetNormal;

simulated function DeployCamera()
{
	bDeployed = True;
	RealLocation = Location;
    Velocity = vect(0,0,0);
    DeployedLocation = Location;
    SpawnThrusters();
    SetPhysics(PHYS_Projectile);

    bRotateToDesired = true;
    DesiredRotation = rot(-16384,0,0);
    PlayAnim('Deploy', 1.0, 0.0);
    if ( Instigator != None && Instigator.IsLocallyControlled() && Instigator.IsHumanControlled() )
    {
        TargetBeam = spawn(class'CSPallasV2.CSPallasArtilleryReticle', self,, Location, rot(0,0,100));
        TargetBeam.ArtilleryLocation = Instigator.Location;
        CSPallasArtilleryCannon(Owner).NotifyDeployed();
    }

	RealLocation = Location;
	if (Trajectory == None)
		Trajectory = Spawn(class'CSPallasArtilleryTrajectory', Self, '', Location);

	if (Trail != None)
		Trail.mRegen = False;
}

function Deploy()
{
	AnnounceTargetTime = Level.TimeSeconds + 1.5;
	DeployCamera();
}


simulated function Destroyed()
{
	if (!bShotDown)
		ShotDown();
	
	if (Trajectory != None)
		Trajectory.Destroy();
	
	Super.Destroyed();
}

simulated event EndedRotation()
{
	bRotateToDesired = False;
	RotationRate = rot(0,0,0);
}

function SetTarget(vector loc);


simulated function UpdateTargetLocation(vector NewTargetLocation, vector NewTargetNormal)
{
	local vector X, Y;
	
	TargetLocation = NewTargetLocation;
	TargetNormal   = NewTargetNormal;
	
	if (TargetBeam != None) {
		TargetBeam.SetLocation(TargetLocation);
		
		// reticle StaticMesh uses TargetNormal as Z direction
		Y = Normal(TargetNormal Cross (TargetLocation - Instigator.Location));
		X = -(TargetNormal Cross Y);
		TargetBeam.SetRotation(OrthoRotation(X, Y, TargetNormal));
	}
}

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

simulated function Tick(float DT)
{
    local actor HitActor;
    local vector HitNormal, HitLocation;
	local Controller C;
	local Bot B;
	local CSPallasArtilleryCannon TurretOwner;

	if (bShotDown || CSPallasVehicle(Instigator) == None || CSPallasVehicle(Instigator).Driver == None)
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

    if ( Level.TimeSeconds - MessageUpdateTime > 2.0 )
    {
		if ( (Instigator != None) && (Instigator.Controller != None)
			&& (Instigator.Controller == Level.GetLocalPlayerController()) && (Level.GetLocalPlayerController().ViewTarget == self) )
		{
			if (bDeployed)
				PlayerController(Instigator.Controller).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 33);
			else
				PlayerController(Instigator.Controller).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 34);
		}
        MessageUpdateTime = Level.TimeSeconds;
    }

    if (!bDeployed)
	{
		TargetLocation = Location;
        SetRotation(Rotator(Velocity));

		//bot
		if ( (Instigator != None) && (AIController(Instigator.Controller) != None) && (Velocity.Z <= 0) )
        {
			if ( MaxHeight == 0 )
			{
				MaxHeight = Location.Z;
				DeployRand = FRand();
				if ( DeployRand < 0.5 )
					DeployRand = 1;
			}
			if ( Location.Z - TargetZ > (0.2 + 0.8*DeployRand) * (MaxHeight - TargetZ) )
				return;
			HitActor = Trace(HitLocation, HitNormal, Instigator.Controller.Target.Location, Location, false);
			if ( HitActor == None )
			{
				Deploy();
			}
		}
	}
	else if ( (Level.TimeSeconds - AnnounceTargetTime > 1.0) && (Role == ROLE_Authority) )
	{
		if ( (Instigator == None) || (Instigator.Controller == None) || (CSPallasArtilleryCannon(Owner) == None) )
		{
			Disable('Tick');
			return;
		}
		AnnounceTargetTime = Level.TimeSeconds;

		if ( !bShotDown )
		{
			For ( C=Level.ControllerList; C!=None; C=C.NextController )
			{
				B = Bot(C);
				if ( (B != None) && !B.SameTeamAs(Instigator.Controller) && (B.Pawn != None) && !B.Pawn.IsFiring()
					&& ((B.Enemy == None) || (B.Enemy == Instigator) || !B.EnemyVisible())
					&& B.LineOfSightTo(self) )
				{
					// give B a chance to shoot at me
					B.GoalString = "Destroy Mortar Camera";
					B.Target = self;
					B.SwitchToBestWeapon();
					if ( B.Pawn.CanAttack(self) )
					{
						B.DoRangedAttackOn(self);
						if ( FRand() < 0.5 )
							break;
					}
				}
			}
		}
	}

	if (CVScale > 0)
	{
		CVScale -= DT * 0.2;
		if (CVScale <= 0)
			CVScale = 0;
		if (CVScale < 0.25 && !bOwnerNoSee)
			bOwnerNoSee = true;
	}

	//if ( (Instigator != None) && (Instigator.Controller == Level.GetLocalPlayerController()) && (CSPallasArtilleryCannon(Owner) != None) )
	if ( Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
    {
        // Target Prediction
		if (Trace(HitLocation, HitNormal, Location + vector(Instigator.Controller.Rotation) * TargetRange,, False) == None)
		{
			HitLocation = Location + vector(Instigator.Controller.Rotation) * TargetRange;
			HitNormal = vect(0,0,1);
		}
		else
		{
			HitLocation += HitNormal * 50.0;
		}
		UpdateTargetLocation(HitLocation, HitNormal);
		TurretOwner = CSPallasArtilleryCannon(Owner);
        TurretOwner.PredictTarget();
		if (Trajectory != None)
		{
			Trajectory.UpdateTrajectory(True, TurretOwner.WeaponFireLocation, vector(TurretOwner.WeaponFireRotation) * Lerp(TurretOwner.WeaponCharge, TurretOwner.MinSpeed, TurretOwner.MaxSpeed), -PhysicsVolume.Gravity.Z, Region.Zone.KillZ, TurretOwner.bCanHitTarget);
		}
    }
}

simulated function ShotDown()
{
	local int i;
	if (Instigator != None && PlayerController(Instigator.Controller) != None && PlayerController(Instigator.Controller).ViewTarget == Self)
	{
		if (Instigator.Controller.Pawn != None)
		{
			log("setviewtarget2");
			PlayerController(Instigator.Controller).bBehindView = Instigator.Controller.Pawn.PointOfView();
			PlayerController(Instigator.Controller).SetViewTarget(Instigator.Controller.Pawn);
		}
		else
		{
			log("setviewtarget3");
			PlayerController(Instigator.Controller).bBehindView = False;
			PlayerController(Instigator.Controller).SetViewTarget(Instigator.Controller);
		}
	}

	for (i = 0; i < ArrayCount(Thruster); i++)
	{
		if (Thruster[i] != None)
			Thruster[i].Kill();
	}

	if (TargetBeam != None)
		TargetBeam.Destroy();
	
	if (Trajectory != None)
		Trajectory.Destroy();
	
	if ( CSPallasArtilleryCannon(Owner) != None )
    {
		CSPallasArtilleryCannon(Owner).AllowCameraLaunch();
    }
	if ( CSPallasVehicle(Instigator) != None )
    {
		CSPallasVehicle(Instigator).MortarCamera = None;
    }
	
    PlaySound(sound'ONSBPSounds.Artillery.CameraShotDown', SLOT_None, 1.5);
    SetPhysics(PHYS_Falling);
	LifeSpan = FMin(LifeSpan, 5);
	bShotDown = true;
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

defaultproperties
{
     MaxTargetRange=10000.000000
     MortarCameraOffset=(X=-256.000000,Z=128.000000)
     CullDistance=0.000000
     bAlwaysRelevant=True
     TransientSoundRadius=500.000000
     CollisionRadius=35.000000
     CollisionHeight=45.000000
	 CVScale=1.0
	 DrawScale=0.5
	 bOrientToVelocity=True
}
