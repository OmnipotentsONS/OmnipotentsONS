/**
WVDraco.DracoNapalmRocket

Creation date: 2013-11-11 09:21
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class DracoNapalmRocket extends Projectile;


//=============================================================================
// Imports
//=============================================================================

//#exec obj load file=NapalmRocket.usx package=WVDraco
//#exec audio import file=Sounds\NapalmRocketExplode.wav
// just reference them in code back to original.


//=============================================================================
// Structs
//=============================================================================

struct TVictimInfo {
	var Actor Actor;
	var vector HL, HN;
};


//=============================================================================
// Properties
//=============================================================================

/** Acceleration magnitude. By default, acceleration is in the same direction as velocity */
var float AccelRate;

var class<Emitter> FlightParticleSystem, FlightParticleSystemBlue;
var class<Emitter> ExplosionParticleSystem, ExplosionParticleSystemBlue;

/** The sound that is played when it explodes */
var Sound ExplosionSound;

var float TransferDamageAmount;
var class<DamageType> SplashDamageType;
var float SplashMomentum;

var class<DracoNapalmGlob> SubmunitionType;
var int SubmunitionCount;


//=============================================================================
// Variables
//=============================================================================

/** if true, the shutdown function has been called and 'new' effects shouldn't happen */
var bool bShuttingDown;

/** Spawned while the instigator had UDamage. */
var bool bAmped;

/**
If this projectile is fired by a vehicle passenger gun, this is the base vehicle
considered the same as Instigator for purposes of bBlockedByInstigator
*/
var Vehicle InstigatorBaseVehicle;
var bool bBlockedByInstigator;

var Emitter ProjEffects;

var Actor PrevTouched;
var vector PrevTouchLocation;
var transient vector TouchLocation, TouchNormal;
var transient vector WallLocation, WallNormal;


//=============================================================================
// Replication
//=============================================================================

replication
{
	reliable if (bNetInitial)
		bAmped;

	reliable if (bNetDirty && bReplicateInstigator)
		InstigatorBaseVehicle;
}


event PreBeginPlay()
{
	local ONSWeaponPawn WeaponPawn;

	// due to a crappy spawn collision check, submunition can't spawn inside
	// the simple collision of a static mesh, even though the parent projectile
	// moved there perfectly fine
	bCollideWorld = True;

	WeaponPawn = ONSWeaponPawn(Instigator);
	if (WeaponPawn != None)
	{
		InstigatorBaseVehicle = WeaponPawn.VehicleBase;
	}
	else if (Instigator != None && Instigator.DrivenVehicle != None)
	{
		InstigatorBaseVehicle = Instigator.DrivenVehicle;
	}

	if (Instigator != None)
	{
		InstigatorController = Instigator.Controller;
	}

	Super.PreBeginPlay();

	if (!bDeleteMe && InstigatorController != None && InstigatorController.ShotTarget != None && InstigatorController.ShotTarget.Controller != None)
	{
		InstigatorController.ShotTarget.Controller.ReceiveProjectileWarning(Self);
	}
}


// I'll do it my way. (actually, the UT3 way)
simulated event PostBeginPlay();


simulated event PostNetBeginPlay()
{
	bReadyToSplash = true;

	if (bDeleteMe || bShuttingDown)
		return;

	if (Instigator != None && Instigator.HasUDamage())
		bAmped = True;

	if (Role < ROLE_Authority)
		SetRotation(rotator(Velocity));
	
	// Spawn any effects needed for flight
	SpawnFlightEffects();
}

function UnTouch(Actor Other)
{
	if (Other == Instigator)
	{
		SetTimer(1.0, false);
	}
}

function Timer()
{
	bBlockedByInstigator = True;
}


simulated event SetInitialState()
{
	bScriptInitialized = true;

	if (Role < ROLE_Authority && AccelRate != 0.0)
	{
		GotoState('WaitingForVelocity');
	}
	else if (InitialState != 'None')
	{
		GotoState(InitialState);
	}
	else
	{
		GotoState('Auto');
	}

	if (Role == ROLE_Authority)
		Init(vector(Rotation));
}


state WaitingForVelocity
{
	simulated function Tick(float DeltaTime)
	{
		if (Velocity != vect(0,0,0))
		{
			Acceleration = AccelRate * Normal(Velocity);

			if (InitialState != 'None')
			{
				GotoState(InitialState);
			}
			else
			{
				GotoState('Auto');
			}
		}
	}
}


function Init(vector Direction)
{
	SetRotation(rotator(Direction));

	Velocity = Speed * Direction;
	Velocity.Z += TossZ;
	Acceleration = AccelRate * Normal(Velocity);
}


simulated static function float GetRange()
{
	local float AccelTime;

	if (default.LifeSpan == 0.0)
		return 15000;
	else if (default.AccelRate == 0.0)
		return default.Speed * default.LifeSpan;


	AccelTime = (default.MaxSpeed - default.Speed) / default.AccelRate;
	return 0.5 * default.AccelRate * Square(AccelTime) + default.Speed * AccelTime + default.MaxSpeed * (default.LifeSpan - AccelTime);
}

simulated function Shutdown()
{
	local vector HitLocation, HitNormal;

	if (bShuttingDown)
		return;

	bShuttingDown = true;
	HitNormal = Normal(-Velocity);
	Trace(HitLocation, HitNormal, Location + HitNormal * -32, Location + HitNormal * 32, true, vect(0,0,0));

	SetPhysics(PHYS_None);

	if (ProjEffects != None)
	{
		ProjEffects.Kill();
	}

	if (!bNoFX)
	{
		Explode(Location, HitNormal);
	}

	HideProjectile();
	SetCollision(false, false);

	Destroy();
}

simulated event TornOff()
{
	ShutDown();
}


simulated event Destroyed()
{
	// Final Failsafe check for explosion effect
	if (!bNoFX)
	{
		Explode(Location, -vector(Rotation));
	}

	if (ProjEffects != None)
	{
		ProjEffects.Kill();
		ProjEffects = None;
	}
}


simulated function HideProjectile()
{
	bHidden = True;
	AmbientSound = None;
}


simulated singular function HitWall(vector HitNormal, Actor Wall)
{
	//log(Self @ 'HitWall' @ Location @ HitNormal @ Wall);
	HurtWall = Wall;
	WallLocation = Location;
	WallNormal = HitNormal;
	ProcessContact(Wall, WallLocation + ExploWallOut * WallNormal, WallNormal);
	HurtWall = None;
}


simulated singular function Touch(Actor Other)
{
	if (bTearOff || Other == None || Other.bDeleteMe || PrevTouched == Other && VSize(Location - PrevTouchLocation) < 250.0)
		return;

	if (LifeSpan > 0 && default.Lifespan - Lifespan < 1.0 && (Other == Instigator || Other == InstigatorBaseVehicle))
		return;

	// don't allow projectiles to explode while spawning on clients
	// because if that were accurate, the projectile would've been destroyed immediately on the server
	// and therefore it wouldn't have been replicated to the client
	if ((Other.bProjTarget || Other.bBlockActors || bProjTarget && Projectile(Other) != None) && (Role == ROLE_Authority || bReadyToSplash) && (bBlockedByInstigator || Other != Instigator && Other != InstigatorBaseVehicle) )
	{
		PrevTouched = Other;
		PrevTouchLocation = Location;

		if (Other.TraceThisActor(TouchLocation, TouchNormal, Location, Location - 0.5 * Velocity))
		{
			TouchLocation = Location;
			TouchNormal = -Normal(Velocity);
		}

		//log(Self @ 'Touch' @ TouchLocation @ TouchNormal @ Other);
		LastTouched = Other;
		ProcessContact(Other, TouchLocation, TouchNormal);
		LastTouched = None;
	}
}

simulated event FellOutOfWorld(eKillZType KillType)
{
	//log(Self @ 'FellOutOfWorld' @ GetEnum(enum'eKillZType', KillType) @ Location);
	Explode(Location, -Normal(Velocity));
	Super.FellOutOfWorld(KillType);
}

/**
Obsolete. Use ProcessContact() instead.
*/
simulated function ClientSideTouch(Actor Other, vector HitLocation)
{
	Assert(false);
}

/**
Obsolete. Use ProcessContact() instead.
*/
simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	Assert(false);
}

/**
Obsolete. Use ProcessContact() and related functions instead.
*/
simulated function BlowUp(vector HitLocation)
{
	Assert(false);
}


simulated function ProcessContact(Actor Other, vector HitLocation, vector HitNormal)
{
	Explode(HitLocation, HitNormal);
}


simulated function Explode(vector HitLocation, vector HitNormal)
{
	local vector VDiff, SpawnDir;
	local int i;
	local DracoNapalmGlob P;

	bNoFX = True;
	if (Role == ROLE_Authority)
		MakeNoise(1.0);

	if (DamageRadius > 0)
	{
		if (LastTouched != None)
			VDiff = Velocity - Normal(Velocity) * (Normal(Velocity) dot LastTouched.Velocity);
		else if (HurtWall != None)
			VDiff = Velocity - Normal(Velocity) * (Normal(Velocity) dot HurtWall.Velocity);
		else
			VDiff = Velocity;

		ProjectileHurtRadius(HitLocation, VDiff, MyDamageType, TransferDamageAmount);
	}
	else if (LastTouched != None)
	{
		LastTouched.TakeDamage(Damage, Instigator, HitLocation, Normal(Velocity) * MomentumTransfer, MyDamageType);
	}
	else if (HurtWall != None)
	{
		HurtWall.TakeDamage(Damage, Instigator, HitLocation, Normal(Velocity) * MomentumTransfer, MyDamageType);
	}

	if (SubmunitionType != None && SubmunitionCount > 0 && Role == ROLE_Authority)
	{
		SetCollision(false, false, false);

		if (HurtWall != None)
			SpawnDir = HitNormal;

		for (i = 0; i < SubmunitionCount; i++)
		{
			P = Spawn(SubmunitionType, Owner, '', HitLocation + 10 * SpawnDir, rotator(VRand() + 0.75 * SpawnDir));
			if (P != None)
			{
				P.InstigatorController = InstigatorController;
			}
		}
	}

	SpawnExplosionEffects(HitLocation, HitNormal);
	ShutDown();
}


/**
Hurt all actors within the specified radius.
*/
// Should this be simulated? Should only need to run on server
//simulated function ProjectileHurtRadius(vector HurtOrigin, vector VDiff, class<DamageType> ImpactedActorDamageType, float ImpactedActorDamageAmount)
function ProjectileHurtRadius(vector HurtOrigin, vector VDiff, class<DamageType> ImpactedActorDamageType, float ImpactedActorDamageAmount)
{
	local Vehicle TargetVehicle;
	local array<TVictimInfo> Victims;
	local TVictimInfo VictimInfo;
	local float dist;
	local int i, j;
	local float DamageAmount, SplashDamageAmount;
	local vector Momentum;
	local bool bSplashHit;

	if (bHurtEntry)
		return;

	bHurtEntry = true;

	foreach VisibleCollidingActors(class'Actor', VictimInfo.Actor, DamageRadius + 300, HurtOrigin)
	{
		//log(VictimInfo.Actor @ LastTouched @ HurtWall @ Self @ VictimInfo.Actor.TraceThisActor(VictimInfo.HL, VictimInfo.HN, HurtOrigin + Normal(VictimInfo.Actor.Location - HurtOrigin) * DamageRadius, HurtOrigin) @ HurtOrigin @ VictimInfo.Actor.Location @ Normal(VictimInfo.Actor.Location - HurtOrigin) * DamageRadius);
		if (VictimInfo.Actor.Role == ROLE_Authority && VictimInfo.Actor != LastTouched && VictimInfo.Actor != HurtWall && VictimInfo.Actor != Self && FluidSurfaceInfo(VictimInfo.Actor) == None && !VictimInfo.Actor.TraceThisActor(VictimInfo.HL, VictimInfo.HN, HurtOrigin + Normal(VictimInfo.Actor.Location - HurtOrigin) * DamageRadius, HurtOrigin - Normal(VictimInfo.Actor.Location - HurtOrigin) * DamageRadius))
		{
			Victims[Victims.Length] = VictimInfo;
		}
	}

	if (LastTouched != None)
	{
		VictimInfo.HL = TouchLocation;
		VictimInfo.HN = TouchNormal;
		VictimInfo.Actor = LastTouched;
		Victims[Victims.Length] = VictimInfo;
	}

	if (HurtWall != None)
	{
		VictimInfo.HL = WallLocation;
		VictimInfo.HN = WallNormal;
		VictimInfo.Actor = HurtWall;
		Victims[Victims.Length] = VictimInfo;
	}

	for (i = 0; i < Victims.Length; i++)
	{
		if (Victims[i].Actor != None)
		{
			bSplashHit = Victims[i].Actor != LastTouched && Victims[i].Actor != HurtWall;
			dist = VSize(Victims[i].HL - HurtOrigin);

			// splash damage
			SplashDamageAmount = FMax(0, Damage * (1 - dist / DamageRadius));

			// splash momentum
			if (dist < DamageRadius)
				Momentum = Normal(Victims[i].Actor.Location - HurtOrigin) * SplashMomentum * (1 - dist / DamageRadius);
			else
				Momentum = vect(0,0,0);

			if (bSplashHit)
			{
				// no impact damage
				DamageAmount = 0;
			}
			else
			{
				// impact damage
				DamageAmount = ImpactedActorDamageAmount * VSize(VDiff);

				// add impact momentum
				Momentum += VDiff * MomentumTransfer;
			}

			// combine damage values
			DamageAmount = FMax(DamageAmount + SplashDamageAmount, 0);

			// apply UDamage factor if UDamage wore off or owner died
			if (bAmped && (Instigator == None || !Instigator.HasUDamage()))
				DamageAmount *= 2;

			//log(Self@Victims[i].Actor@DamageAmount@VDiff@bSplashHit@SplashDamageAmount@dist@ImpactedActorDamageType@SplashDamageType);

			if (int(DamageAmount) > 0 || VSize(Momentum) > 0)
			{
				Victims[i].Actor.SetDelayedDamageInstigatorController(InstigatorController);

				if (bSplashHit)
					Victims[i].Actor.TakeDamage(DamageAmount, Instigator, Victims[i].HL, Momentum, SplashDamageType);
				else
					Victims[i].Actor.TakeDamage(DamageAmount, Instigator, Victims[i].HL, Momentum, ImpactedActorDamageType);
			}

			// apply damage to vehicle drivers as well
			if (Vehicle(Victims[i].Actor) != None && Vehicle(Victims[i].Actor).Health > 0)
			{
				TargetVehicle = Vehicle(Victims[i].Actor);
				VictimInfo.HN = vect(0,0,0);
				VictimInfo.Actor = TargetVehicle.Driver;

				if (!TargetVehicle.bRemoteControlled && VictimInfo.Actor != None && VictimInfo.Actor != LastTouched && VictimInfo.Actor != HurtWall && !VictimInfo.Actor.bCollideActors && VictimInfo.Actor.Role == ROLE_Authority)
				{
					VictimInfo.HL = VictimInfo.Actor.Location;
					Victims[Victims.Length] = VictimInfo;
				}
				if (ONSVehicle(TargetVehicle) != None )
				{
					for (j = 0; j < ONSVehicle(TargetVehicle).WeaponPawns.Length; j++)
					{
						VictimInfo.Actor = ONSVehicle(TargetVehicle).WeaponPawns[j].Driver;

						if (!ONSVehicle(TargetVehicle).WeaponPawns[j].bCollideActors && !ONSVehicle(TargetVehicle).WeaponPawns[j].bRemoteControlled && VictimInfo.Actor != None && VictimInfo.Actor != LastTouched && VictimInfo.Actor != HurtWall && !VictimInfo.Actor.bCollideActors && VictimInfo.Actor.Role == ROLE_Authority)
						{
							VictimInfo.HL = VictimInfo.Actor.Location;
							Victims[Victims.Length] = VictimInfo;
						}
					}
				}
			}
		}
	}

	bHurtEntry = false;
}


simulated function SpawnFlightEffects()
{
	if (Level.NetMode != NM_DedicatedServer && FlightParticleSystem != None)
	{
		if (ProjEffects != None)
			ProjEffects.Kill();

		ProjEffects = Spawn(FlightParticleSystem, Self);
		ProjEffects.SetBase(Self);
	}
}

simulated function bool IsEffectRelevant(vector SpawnLocation, bool bForceDedicated, optional float MaxDistance)
{
	local PlayerController PC;
	local bool bResult;

	if (Level.NetMode == NM_DedicatedServer)
	{
		return bForceDedicated;
	}

	if (Level.NetMode == NM_ListenServer && Level.Game.NumPlayers > 1)
	{
		if (bForceDedicated)
			return true;
		if (Instigator != None && Instigator.IsHumanControlled() && Instigator.IsLocallyControlled())
			return true;
	}
	else if (Instigator != None && Instigator.IsHumanControlled())
	{
		return true;
	}

	PC = Level.GetLocalPlayerController();

	if (VSize(SpawnLocation - Location) < 100)
	{
		bResult = Level.TimeSeconds - LastRenderTime < 0.5 || PC != None && PC.ViewTarget != None && VSize(PC.ViewTarget.Location - Location) < 256.0;
	}
	else if (Instigator != None && Level.TimeSeconds - Instigator.LastRenderTime < 1.0)
	{
		bResult = true;
	}

	if (bResult && PC != None && PC.ViewTarget != None)
	{
		if (PC.Pawn == Instigator && Instigator != None)
		{
			return true;
		}
		else
		{
			return !PC.BeyondViewDistance(SpawnLocation, MaxDistance);
		}
	}

	return bResult;
}

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local Emitter ProjExplosion;
	local Actor EffectAttachActor;

	if (Level.NetMode != NM_DedicatedServer)
	{
		if (LightType != LT_None)
			LightType = LT_None;

		if (ExplosionParticleSystem != None && IsEffectRelevant(Location, false, MaxEffectDistance))
		{
			//Attach to non-pawns, pawns if we allow it, or vehicles if we allow it
			if (LastTouched != None)
			{
				EffectAttachActor = LastTouched;
			}
			else if (HurtWall != None)
			{
				EffectAttachActor = HurtWall;
			}

			if (Pawn(EffectAttachActor) != None)
			{
				EffectAttachActor = None;
			}

			ProjExplosion = Spawn(ExplosionParticleSystem, Self, '', Location, Rotation);

			if (EffectAttachActor != None && ProjExplosion != None)
				ProjExplosion.SetBase(EffectAttachActor);

			if (!Level.bDropDetail && ExplosionDecal != None && IsEffectRelevant(Location, false, ExplosionDecal.default.CullDistance))
			{
				if (Pawn(EffectAttachActor) == None && DestroyableObjective(EffectAttachActor) == None)
				{
					Spawn(ExplosionDecal, self,, HitLocation, rotator(-HitNormal));
				}
			}
		}

		if (ExplosionSound != None)
		{
			PlaySound(ExplosionSound);
		}

		bNoFX = true; // so we don't get called again
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     AccelRate=2000.000000
     FlightParticleSystem=Class'WVDraco.NapalmRocketFlightEffects'
     ExplosionParticleSystem=Class'XEffects.NewExplosionA'
     ExplosionSound=Sound'WVDraco.NapalmRocketExplode'
     TransferDamageAmount=0.004000
     SplashDamageType=Class'FireVehiclesV2Omni.DamTypeDracoNapalmRocket'
     SplashMomentum=20000.000000
     SubmunitionType=Class'FireVehiclesV2Omni.DracoNapalmGlob'
     SubmunitionCount=12
     Speed=1500.000000
     MaxSpeed=3500.000000
     TossZ=0.000000
     Damage=60.000000
     MomentumTransfer=4.000000
     MyDamageType=Class'FireVehiclesV2Omni.DamTypeDracoNapalmRocket'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_None
     bNetInitialRotation=False
     bIgnoreVehicles=True
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     TransientSoundVolume=0.750000
     TransientSoundRadius=500.000000
     bCollideWorld=False
     bBounce=True
     Mass=5.000000
}
