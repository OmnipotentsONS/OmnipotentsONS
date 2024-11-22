/**
PersesHomingMissile

Creation date: 2013-12-12 12:52
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniHomingMissile extends PersesOmniProjectileBase;


//=============================================================================
// Properties
//=============================================================================

var() float HomingExtrapolationMaxTime;
var() float HomingExtrapolationMaxError;
var() float HomingAnglePerSecond;
var() float HomingPredictionTimeFactor;
var() float HomingPredictionMaxTime;
var() float HomingCheckInterval;
var() float HomingMaxAimAngle;

var() bool bAutoHoming;
var() float AutoHomingViewRange;
var() float AutoHomingViewAngle;

var() float InitialHomingViewRange;
var() float InitialHomingViewAngle;

var() float LateralDampenFactor;


//=============================================================================
// Variables
//=============================================================================

var Actor HomingTarget;
var bool bNoHomingTarget;

// fallback data in case HomingTarget is not relevant:
var vector HomingLocation, HomingVelocity;
var float HomingPositionTime;
var vector AlternateTargetOffset;
var float LastTargetCheckTime;

var struct THomingPosition
{
	var vector Location;
	var vector Velocity;
} RepHomingPosition, OldHomingPosition;


//=============================================================================
// Replication
//=============================================================================

replication
{
	reliable if (bNetDirty)
		HomingTarget, bNoHomingTarget;

	reliable if (bNetDirty && !bNoHomingTarget)
		RepHomingPosition, AlternateTargetOffset;
}

/*
function PostBeginPlay()
{
	LastTargetCheckTime = Level.TimeSeconds;
	SetHomingTarget(PickTarget(InitialHomingViewAngle, InitialHomingViewRange, vector(Rotation)));
}
*/

function Init(vector Direction)
{
	Super.Init(Direction);
	LastTargetCheckTime = Level.TimeSeconds;
	SetHomingTarget(PickTarget(InitialHomingViewAngle, InitialHomingViewRange, vector(Rotation)));
}


function SetHomingTarget(Actor NewTarget)
{
	if (HomingTarget != NewTarget)
	{
		if (Vehicle(HomingTarget) != None)
			Vehicle(HomingTarget).NotifyEnemyLostLock();

		HomingTarget = NewTarget;
		if (Vehicle(HomingTarget) != None)
			Vehicle(HomingTarget).NotifyEnemyLockedOn();

		bNoHomingTarget = (NewTarget == None);
		if (HomingTarget != None)
			AlternateTargetOffset = vect(0,0,1) * HomingTarget.CollisionHeight;
		
		NetUpdateTime = Level.TimeSeconds - 1;
	}
}

simulated event PostNetReceive()
{
	if (OldHomingPosition != RepHomingPosition)
	{
		OldHomingPosition = RepHomingPosition;
		HomingPositionTime = Level.TimeSeconds;
	}
}


simulated event ShutDown()
{
	SetHomingTarget(None);
	Super.ShutDown();
}


simulated event Destroyed()
{
	SetHomingTarget(None);
	Super.Destroyed();
}


simulated function UpdateHomingPosition()
{
	local THomingPosition NewPosition;

	if (HomingTarget != None)
	{
		if (Role == ROLE_Authority && (Level.TimeSeconds - HomingPositionTime > HomingExtrapolationMaxTime || VSize(RepHomingPosition.Location + (Level.TimeSeconds - HomingPositionTime) * RepHomingPosition.Velocity - HomingTarget.Location) > HomingExtrapolationMaxError))
		{
			NewPosition.Location = RoundVector(HomingTarget.Location);
			NewPosition.Velocity = RoundVector(HomingTarget.Velocity);
			RepHomingPosition = NewPosition;
		}
		HomingLocation = HomingTarget.Location;
		HomingVelocity = HomingTarget.Velocity;
		HomingPositionTime = Level.TimeSeconds;
	}
	else if (Role == ROLE_Authority && HomingLocation != vect(0,0,0))
	{
		HomingLocation = vect(0,0,0);
		HomingVelocity = vect(0,0,0);
		HomingPositionTime = Level.TimeSeconds;
		RepHomingPosition = NewPosition;
	}
	else if (Role < ROLE_Authority)
	{
		HomingVelocity = RepHomingPosition.Velocity;
		HomingLocation = RepHomingPosition.Location + (Level.TimeSeconds - HomingPositionTime) * HomingVelocity;
	}
}


simulated event Tick(float DeltaTime)
{
	local vector Dir;
	
	Super.Tick(DeltaTime);

	if (bShuttingDown)
		return;

	if (Role == ROLE_Authority && Level.TimeSeconds - LastTargetCheckTime > HomingCheckInterval)
	{
		LastTargetCheckTime = Level.TimeSeconds;
		if (bAutoHoming)
			PickNewHomingTarget();
		else if (!bNoHomingTarget && !IsValidTarget(HomingTarget))
			SetHomingTarget(None);

		if (Pawn(HomingTarget) != None && Pawn(HomingTarget).Controller != None)
			Pawn(HomingTarget).Controller.ReceiveProjectileWarning(self);
	}

	if (!bNoHomingTarget)
	{
		UpdateHomingPosition();
		UpdateRotation(DeltaTime);
	}
	
	Dir = vector(Rotation);
	Acceleration = AccelRate * Dir;
	
	if (Normal(Velocity) dot Dir ~= 1.0)
		return;
	
	Acceleration -= LateralDampenFactor * (Velocity - Dir * (Velocity dot Dir));
}


simulated function bool UpdateRotation(float DeltaTime)
{
	local float a, b, c, d;
	local float t1, t2, t;
	local vector TargetLocation, TargetDir;
	local vector X, Y, Z;
	local float TargetAngle;

	if (vector(Rotation) dot Normal(HomingLocation - Location) < HomingMaxAimAngle)
		return false; // can't see target anymore

	if (HomingPredictionMaxTime > 0 && VSize(HomingVelocity) > 0)
	{
		// calculate required target leading
		
		// upper bound: time towards stationary target
		t = FMin(VSize(Location - HomingLocation) / VSize(Velocity), HomingPredictionMaxTime);

		/*
		Assume linear movement of projectile and homing target, but assume
		unknown direction for projectile movement. For calculating the ideal
		interception point, the target is a moving point, while the rocket is
		an expanding sphere. The code below calculates the smallest t > 0 for
		which the moving point touches the sphere's surface, which is the time
		to interception on an ideal course.

		This boils down to a quadratic equation:
		a * t**2 + b * t + c == 0

		The parameters a, b and c are:
		a = |tVel|**2 - pSpeed**2
		b = (tLoc - pLoc) * tVel
		c = |tLoc - pLoc|**2

		pSpeed: projectile speed (scalar, assume MaxSpeed)
		tVel:   target velocity (vector, HomingVelocity)
		pLoc:   projectile location (vector, Location)
		tLoc:   target location (vector, HomingLocation)
		*/

		TargetDir = HomingLocation - Location;
		a = HomingVelocity dot HomingVelocity - Square(MaxSpeed);
		b = TargetDir dot HomingVelocity;
		c = TargetDir dot TargetDir;
		d = Square(b) - 4*a*c;

		if (d > 0) // otherwise can't reach target
		{
			t1 = -0.5 * (b - Sqrt(d)) / a;
			t2 = -0.5 * (b + Sqrt(d)) / a;

			if (t1 > 0 && t2 > t1)
			{
				t = FMin(t1 * HomingPredictionTimeFactor, t);
			}
			else if (t2 > 0 && t1 > t2)
			{
				t = FMin(t2 * HomingPredictionTimeFactor, t);
			}
		}
	}

	TargetLocation = HomingLocation + t * HomingVelocity;

	if (!FastTrace(TargetLocation, Location))
	{
		// computed target location isn't visible, i.e. would likely crash into wall first
		TargetLocation = HomingLocation;

		if (!FastTrace(TargetLocation, Location))
		{
			// target not visible directly either, can we see at least the top?
			TargetLocation += AlternateTargetOffset;

			if (AlternateTargetOffset != vect(0,0,0) && !FastTrace(TargetLocation, Location))
				return false; // I give up :/
		}
	}

	//TargetDir = Normal(Normal(TargetLocation - Location) - 0.5 * Normal(Velocity));
	TargetDir = Normal(TargetLocation - Location);

	// now try rotating towards target direction

	// The current direction (X) and the target direction span a plane. Based
	// on that, a rotation axis (Z) perpendicular that plane is calculated.
	// A helper vector (Y) in the same plane as the current and target
	// directions is calculated, such that it is perpendicular to the current
	// direction and the rotation axis and that the shortest rotation direction
	// from the current direction to the target direction is the same as the
	// shortest rotation direction from the current direction to the helper
	// vector.

	X = vector(Rotation);

	if (X dot TargetDir ~= 1.0 && Normal(Velocity) dot TargetDir ~= 1.0)
		return true; // already facing target direction

	Z = Normal(X cross TargetDir);
	Y = Z cross X;

	// now calculate the rotation angle
	TargetAngle = FMin(DeltaTime * HomingAnglePerSecond, ACos(X dot TargetDir));
	
	// finally, calculate the new target direction and apply it
	TargetDir = X * Cos(TargetAngle) + Y * Sin(TargetAngle);

	SetRotation(rotator(TargetDir));

	return true;
}


function PickNewHomingTarget()
{
	local Actor NewTarget;
	local float BestRating, Rating;
	local bool bTargetVisible;
	local vector TargetLocation;

	if (IsValidTarget(HomingTarget))
	{
		TargetLocation = HomingTarget.Location;
		if (FastTrace(TargetLocation, Location))
		{
			bTargetVisible = True;
			BestRating = RateTargetLocation(HomingTarget.Location, vector(Rotation));
		}
		TargetLocation = HomingTarget.Location + vect(0,0,1) * HomingTarget.CollisionHeight;
		if (bTargetVisible || FastTrace(TargetLocation, Location))
		{
			Rating = RateTargetLocation(TargetLocation, vector(Rotation));
			if (bTargetVisible)
				BestRating = FMin(BestRating, Rating);
			else
				BestRating = Rating;
			bTargetVisible = True;
		}
		TargetLocation = HomingTarget.Location - vect(0,0,1) * HomingTarget.CollisionHeight;
		if (bTargetVisible || FastTrace(TargetLocation, Location))
		{
			Rating = RateTargetLocation(TargetLocation, vector(Rotation));
			if (bTargetVisible)
				BestRating = FMin(BestRating, Rating);
			else
				BestRating = Rating;
			bTargetVisible = True;
		}
	}

	NewTarget = PickTarget(AutoHomingViewAngle, AutoHomingViewRange, GetCheckDir(), Rating);

	if (!bTargetVisible || NewTarget != None && Rating < BestRating)
	{
		SetHomingTarget(NewTarget);
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     HomingExtrapolationMaxTime=1.000000
     HomingExtrapolationMaxError=10.000000
     HomingAnglePerSecond=6.000000
     HomingPredictionTimeFactor=0.500000
     HomingPredictionMaxTime=1.000000
     HomingCheckInterval=0.100000
     HomingMaxAimAngle=0.100000
     bAutoHoming=True
     AutoHomingViewRange=3500.000000
     AutoHomingViewAngle=0.500000
     InitialHomingViewRange=10000.000000
     InitialHomingViewAngle=0.850000
     LateralDampenFactor=0.500000
     bNoHomingTarget=True
     AccelRate=5000.000000
     FlightParticleSystem=Class'PersesOmni.PersesOmniHomingMissileFlightEffects'
     ExplosionParticleSystem=Class'XEffects.NewExplosionA'
     ExplosionSound=Sound'WeaponSounds.BaseImpactAndExplosions.BExplosion3'
     TransferDamageAmount=0.004000
     SplashDamageType=Class'PersesOmni.DamTypePersesOmniHomingSplash'
     SplashMomentum=50000.000000
     bAutoInit=True
     ProjectileName="Homing Missile"
     Speed=2450.000000
     MaxSpeed=3700.000000
     Damage=75.000000  // 1.0 multiplier
     DamageRadius=150.000000
     MomentumTransfer=4.5000
     MyDamageType=Class'PersesOmni.DamTypePersesOmniHomingHit'
     ExplosionDecal=Class'XEffects.RocketMark'
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     NetPriority=2.650000
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=6.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=500.000000
     bNetNotify=True
     Mass=3.000000
     DrawScale=2.0
}
