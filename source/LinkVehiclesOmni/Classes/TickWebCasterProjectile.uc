/**
WVWebCaster.WebCasterProjectile

Copyright (c) 2016, Wormbo

(1) This source code and any binaries compiled from it are provided "as-is",
without warranty of any kind. (In other words, if it breaks something for you,
that's entirely your problem, not mine.)
(2) You are allowed to reuse parts of this source code and binaries compiled
from it in any way that does not involve making money, breaking applicable laws
or restricting anyone's human or civil rights.
(3) You are allowed to distribute binaries compiled from modified versions of
this source code only if you make the modified sources available as well. I'd
prefer being mentioned in the credits for such binaries, but please do not make
it seem like I endorse them in any way.
*/

class TickWebCasterProjectile extends Projectile;


//=============================================================================
// Properties
//=============================================================================

var() class<Emitter> ProjectileEffectClass;

var() int BeamSubEmitterIndex1;
var() float SpringLength1;

var() int BeamSubEmitterIndex2;
var() float SpringLength2;

var() float ExplodeDelay;
var() sound StuckSound;

var() class<Actor> ExplodeEffect;
var() Sound ExplodeSound;

var() class<Actor> ExtraDamageClass;
var() float ExtraDamageMultiplier;

var() float PullForce;


//=============================================================================
// Variables
//=============================================================================

var Emitter ProjectileEffect;

var int BeamTargetProjectile1;
var int BeamTargetProjectile2;

var TickWebCasterProjectileLeader Leader;
var int ProjNumber;
var float LastTickTime;
var bool bBeingSucked;

var Actor StuckActor;
var vector StuckNormal;



//=============================================================================
// Replication
//=============================================================================

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		Leader, ProjNumber;
}


simulated function Destroyed()
{
	if (ProjectileEffect != None)
	{
		ProjectileEffect.Kill();
		ProjectileEffect = None;
	}
	
	if (Level.NetMode != NM_DedicatedServer && EffectIsRelevant(Location, false))
	{
		Spawn(ExplodeEffect,,, Location, rotator(StuckNormal));
		PlaySound(ExplodeSound,,2.5*TransientSoundVolume);
	}

	Super.Destroyed();
}


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Velocity = Speed * Vector(Rotation);

	if (Level.NetMode != NM_DedicatedServer)
	{
		ProjectileEffect = Spawn(ProjectileEffectClass, self,, Location, Rotation);
		ProjectileEffect.SetBase(self);
	}

	// On client - add this projectile in next free slot leaders list of projectiles.
	if (Role < ROLE_Authority)
	{
		if (Leader != None && ProjNumber != -1)
		{
			Leader.Projectiles[ProjNumber] = self;
		}
		else
		{
			bNetNotify = true; // We'll need the PostNetReceive to add this projectile to its leader.
		}
	}
}


simulated event PostNetReceive()
{
	if (Leader != None && ProjNumber != -1)
	{
		Leader.Projectiles[ProjNumber] = self;

		bNetNotify = false; // Don't need PostNetReceive any more.
	}
}


simulated function ProcessTouch(actor Other, vector HitLocation)
{
	//Don't hit the player that fired me
	if (Other == Instigator || Vehicle(Instigator) != None && Other == Vehicle(Instigator).Driver)
		return;

	// If we hit some stuff - just blow up straight away.
	if (Other.IsA('Projectile') || Other.bBlockProjectiles)
	{
		if (Role == ROLE_Authority)
			Leader.DetonateWeb();
	}
	else
	{
		StuckActor = Other;
		if (Level.NetMode != NM_Client && StuckActor != None && ClassIsChildOf(StuckActor.Class, ExtraDamageClass)
			&& Bot(Pawn(StuckActor).Controller) != None && Level.Game.GameDifficulty > 6 * FRand())
		{
			//about to blow up, so bot will bail
			Vehicle(StuckActor).VehicleLostTime = Level.TimeSeconds + 10;
			Vehicle(StuckActor).KDriverLeave(false);
		}
		StuckNormal = normal(HitLocation - Other.Location);
		GotoState('Stuck');
	}
}

simulated function HitWall(vector HitNormal, Actor Wall)
{
	if (Wall.bBlockProjectiles)
	{
		if (Role == ROLE_Authority)
			Leader.DetonateWeb();

		return;
	}

	StuckActor = Wall;
	StuckNormal = HitNormal;
	GoToState('Stuck');
}

// Server-side only
function Explode(vector HitLocation, vector HitNormal)
{
	GotoState(''); // so Stuck.BaseChange() won't be called
	BlowUp(HitLocation);
	Destroy();
}

function BlowUp(vector HitLocation)
{
	NetUpdateTime = Level.TimeSeconds - 1;
	if (StuckActor != None && ClassIsChildOf(StuckActor.Class, ExtraDamageClass))
		Damage *= ExtraDamageMultiplier;

	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	MakeNoise(1.0);
}


state Stuck
{
	simulated function BeginState()
	{
		if (Leader != None)
			Leader.NotifyStuck();

		NetPriority = 1.5;
		NetUpdateTime = Level.TimeSeconds - 1;
		SetPhysics(PHYS_None);

		PlaySound(StuckSound,,2.5*TransientSoundVolume);

		if (StuckActor != None)
		{
			StuckActor.TakeDamage(0, Instigator, Location, Mass * Velocity, MyDamageType);
			LastTouched = StuckActor;
			SetBase(StuckActor);
		}

		SetCollision(false, false);
		bCollideWorld = false;

		if (Role == ROLE_Authority)
			SetTimer(ExplodeDelay, false);
	}

	function Timer()
	{
		// Should only happen on Authority, where Leader should always be valid.
		if ( Leader != None )
			Leader.DetonateWeb();
		else
			Explode(Location,StuckNormal);
		NetUpdateTime = Level.TimeSeconds - 1;
	}
	
	function BaseChanged()
	{
		if (Base == None) {
			// no longer stuck, blow up now
			Timer();
		}
	}
}


simulated function Tick(float DeltaTime)
{
	if (Leader != None)
		Leader.TryPreAllProjectileTick(DeltaTime);
	
	LastTickTime = Level.TimeSeconds;
	if (StuckActor != None) {
		if (StuckActor.Physics == PHYS_Karma)
			StuckActor.KAddImpulse(DeltaTime * PullForce * Acceleration, Location);
		else if (StuckActor.Physics == PHYS_KarmaRagdoll)
			StuckActor.KAddImpulse(DeltaTime * Acceleration * StuckActor.Mass, Location);
		else if (Pawn(StuckActor) != None)
			Pawn(StuckActor).AddVelocity(DeltaTime * PullForce * Acceleration / StuckActor.Mass);
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     ProjectileEffectClass=Class'LinkVehiclesOmni.TickWebCasterProjectileEffect'
     BeamSubEmitterIndex1=2
     SpringLength1=100.000000
     BeamSubEmitterIndex2=4
     SpringLength2=100.000000
     ExplodeDelay=3.000000
     StuckSound=Sound'ONSVehicleSounds-S.WebLauncher.WebStick'
    // ExplodeEffect=Class'XEffects.GoopSparks'
     ExplodeEffect=Class'LinkVehiclesOmni.TickScorp3GoopSparksPurple'
     ExplodeSound=SoundGroup'WeaponSounds.BioRifle.BioRifleGoo1'
     ExtraDamageClass=Class'Onslaught.ONSHoverBike'
     ExtraDamageMultiplier=1.500000
     PullForce=15.000000
     ProjNumber=-1
     Speed=2500.000000
     MaxSpeed=3000.000000
     Damage=55.000000
     DamageRadius=150.000000
     MomentumTransfer=10000.000000
     MyDamageType=Class'LinkVehiclesOmni.DamTypeTickWebCaster'
     DrawType=DT_None
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     NetUpdateFrequency=10.000000
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     Mass=10.000000
}
