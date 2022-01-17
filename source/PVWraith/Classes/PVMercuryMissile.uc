//=============================================================================
// MercuryMissile
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// High speed rocket.
//=============================================================================


class PVMercuryMissile extends Projectile;


//=============================================================================
// Imports
//=============================================================================

#exec obj load file=PVMercuryMissileResources.usx package=PVWraith
#exec texture import file=Textures\MercHUDIcon.tga mips=off alpha=on lodset=LODSET_Interface uclampmode=clamp vclampmode=clamp

#exec audio import File=Sounds\Effects_AmpFireSound.Wav          
#exec audio import File=Sounds\Effects_MercFly.Wav               
#exec audio import File=Sounds\Effects_MercHitArmor.Wav          
#exec audio import File=Sounds\Effects_MercIgnite.Wav            
#exec audio import File=Sounds\Effects_MercPunchThrough.Wav      
#exec audio import File=Sounds\Effects_MercWaterImpact.Wav       

//=============================================================================
// Structs
//=============================================================================

struct TVictimInfo {
	var Actor Actor;
	var vector HL, HN;
};

struct TExplosionEffectInfo {
	var Actor Other;
	var vector HitLocation;
	var vector HitNormal;
};


//=============================================================================
// Properties
//=============================================================================

var class<DamageType> SplashDamageType;
var float SplashMomentum;
var float TransferDamageAmount, ImpactDamageAmount;

var class<DamageType> HeadHitDamage, DirectHitDamage, PunchThroughDamage, ThroughHeadDamage;
var float AccelRate, ThrusterTimeLimit;
var float HeadShotDamageMult, HeadShotSizeAdjust;
var float PunchThroughSpeed, PunchThroughVelocityLossPercent;
var float UDamageMomentumBoost, RocketJumpBoost;
var bool bAmped;
var byte Team;
var Sound ExplodeOnPlayerSound;
var Material TeamSkins[4];
var Material UDamageOverlay;

var array<ParticleEmitter.ParticleColorScale> UDamageThrusterColorScale;
var rangevector TrailLineColor[4];
var float DopplerStrength, DopplerBaseSpeed;


//=============================================================================
// Variables
//=============================================================================

/**
Replicated direction of flight to get around inaccurate rotator replication.
*/
var int Direction;

var PVMercuryMissileTrail Trail;

var vector PrevTouchLocation;

var transient vector TouchLocation, TouchNormal;
var transient vector WallLocation, WallNormal;
var transient Actor PrevTouched;

var TExplosionEffectInfo ExplosionEffectInfo;

var bool bFakeDestroyed, bCanHitOwner;


//=============================================================================
// Replication
//=============================================================================

replication
{
	reliable if (bNetInitial)
		Direction, Team, bAmped, bFakeDestroyed;

	reliable if (bNetDirty)
		ExplosionEffectInfo;
}


simulated function BeginPlay()
{
	if (Instigator != None && Instigator.PlayerReplicationInfo != None && Instigator.PlayerReplicationInfo.Team != None)
		Team = Instigator.PlayerReplicationInfo.Team.TeamIndex;
	else if (Level.Game != None && !Level.Game.bTeamGame && Vehicle(Instigator) != None)
		Team = Vehicle(Instigator).Team;

	Velocity = Speed * vector(Rotation);
	if (Role == ROLE_Authority) // replicate rotation with maximum precision
		Direction = (Rotation.Yaw & 0xffff) | (Rotation.Pitch << 16);

	Acceleration = AccelRate * vector(Rotation);

	Super.BeginPlay();
}


simulated function PostBeginPlay()
{
	if (PhysicsVolume.bWaterVolume)
		Velocity *= 0.6;

	if (Level.NetMode != NM_DedicatedServer)
		Trail = Spawn(class'PVMercuryMissileTrail', self,, Location, Rotation);

	Super.PostBeginPlay();

	PlaySound(SpawnSound, SLOT_Misc);
}

simulated function PostNetBeginPlay()
{
	local rotator DirRot;

	if (Role < ROLE_Authority && Direction != -1) {
		// adjust direction of flight accordingly to prevent replication-related inaccuracies
		DirRot.Yaw = Direction & 0xffff;
		DirRot.Pitch = Direction >> 16;
		Acceleration = AccelRate * vector(DirRot);
		Velocity = VSize(Velocity) * vector(DirRot);
	}
	if (Instigator != None && Instigator.HasUDamage()) {
		bAmped = True;
	}
	if (Team < ArrayCount(TeamSkins)) {
		Skins[0] = TeamSkins[Team];
	}
	if (bAmped) {
		SetOverlayMaterial(UDamageOverlay, LifeSpan, true);
	}
	if (Trail != None) {
		if (bAmped) {
			Trail.Emitters[0].ColorScale = UDamageThrusterColorScale;
			Trail.Emitters[2].ColorScale = UDamageThrusterColorScale;
		}
		if (Team < ArrayCount(TrailLineColor))
			Trail.Emitters[1].ColorMultiplierRange = TrailLineColor[Team];
		Trail.Emitters[1].Disabled = false;
	}
	if (bFakeDestroyed && Level.NetMode == NM_Client) {
		bFakeDestroyed = False;
		TornOff();
	}
}


/**
Sets the projectile in a "would-be destroyed" state.
Doesn't differ from calling Destroy() if the prjectile has RemoteRole < ROLE_SimulatedProxy.
NOTE: This function may not have the desired results if projectile is bNetTemporary!
*/
simulated function FakeDestroy()
{
	if (Level.NetMode == NM_Standalone || Level.NetMode == NM_Client || RemoteRole < ROLE_SimulatedProxy) {
		Destroy();
	}
	else {
		GotoState('WasFakeDestroyed');
	}
}

/**
Called after the projectile is FakeDestroy()ed.
Do not rely on the projectile continuing to exist after this function call since FakeDestroy() may call Destroy() right after calling this function!
*/
simulated function FakeDestroyed()
{
	if (Trail != None) {
		Trail.Kill();
		Trail = None;
	}

	if (InstigatorController == None || Role < ROLE_Authority) {
		return;
	}
}


/**
Called by the engine on clients after bTearOff was set to True, i.e. also when the projectile was FakeDestroy()ed.
*/
simulated function TornOff()
{
	ProcessContact(false, ExplosionEffectInfo.Other, ExplosionEffectInfo.HitLocation, Normal(ExplosionEffectInfo.HitNormal));
	Destroy();
}


/**
Wait a bit before allowing owner hits.
Adjust ambient sound to fake doppler effect.
*/
auto simulated state Flying
{
	/**
	Fake doppler effect.
	*/
	simulated event Tick(float DeltaTime)
	{
		local PlayerController LocalPlayer;
		local float ApproachSpeed;

		if (Level.NetMode != NM_DedicatedServer) {
			LocalPlayer = Level.GetLocalPlayerController();
			if (LocalPlayer != None) {
				ApproachSpeed = (Velocity + LocalPlayer.ViewTarget.Velocity) dot Normal(LocalPlayer.ViewTarget.Location - Location);
				SoundPitch = default.SoundPitch * (DopplerStrength ** (ApproachSpeed / DopplerBaseSpeed));
			}
		}
	}

Begin:
	do {
		Sleep(0.1);
	} until (Instigator != None && VSize(Instigator.Location - Location) < 10.0 * (Instigator.CollisionRadius + Instigator.CollisionHeight));

	SetOwner(None);
	bCanHitOwner = True;
}


/**
The fake-destroyed state. The server enters this state after FakeDestroy() was called.
*/
state WasFakeDestroyed
{
	ignores Touch, Bump, HitWall, TakeDamage, EncroachingOn, Timer;

	/**
	Hides the projectile and disables its collision and movement upon entering the fake-destroyed state.
	*/
	simulated function BeginState()
	{
		Assert(Level.NetMode != NM_Client && Level.NetMode != NM_Standalone);
		bFakeDestroyed = True;
		FakeDestroyed();
		LifeSpan = 0.5;
		bHidden = True;
		SetPhysics(PHYS_None);
		SetCollision(False, False, False);
		bCollideWorld = False;
		LightType = LT_None;
		AmbientSound = None;
	}

Begin:
	Sleep(0.0);
	bTearOff = True;
}


/**
Unregister from any projectile modifiers and potential parent projectiles.
*/
simulated function Destroyed()
{
	if (!bFakeDestroyed) {
		FakeDestroyed();
	}
}


/**
Returns how a contact with another object affects this projectile's movement.
*/
simulated function bool ShouldPenetrate(Actor Other, vector HitNormal)
{
	return UnrealPawn(Other) != None && !Other.IsInState('Frozen') && VSize(Velocity) - Normal(Velocity) dot Other.Velocity > PunchThroughSpeed && UnrealPawn(Other).GetShieldStrength() == 0;
}

/**
Called when the projectile hits a wall. This just sets HurtWall, the actual magic is in ProcessContact().
*/
simulated singular function HitWall(vector HitNormal, Actor Wall)
{
	HurtWall = Wall;
	WallLocation = Location;
	WallNormal = HitNormal;
	ProcessContact(ShouldPenetrate(Wall, HitNormal), Wall, Location, HitNormal);
	HurtWall = None;
}


/**
Called when the projectile touches something. This just sets LastTouched, the actual magic is in ProcessContact().
*/
simulated singular function Touch(Actor Other)
{
	if (bTearOff || Other == None || PrevTouched == Other && VSize(Location - PrevTouchLocation) < 250.0 || Other == Instigator && !bCanHitOwner) {
		return;
	}
	if (Other.bProjTarget || Other.bBlockActors) {
		PrevTouched = Other;
		LastTouched = Other;
		if (Velocity == vect(0,0,0)) {
			Velocity = vector(Rotation);
		}

		if (Other.TraceThisActor(TouchLocation, TouchNormal, Location, Location - 0.5 * Velocity)) {
			TouchLocation = Location;
			TouchNormal = -Normal(Velocity);
		}
		PrevTouchLocation = TouchLocation;
		ProcessContact(ShouldPenetrate(Other, TouchNormal), Other, TouchLocation, TouchNormal);
		LastTouched = None;
	}
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

/**
Called by ONSPowerCoreShield.Touch(), detects actual hit location/normal and calls ProcessContact without penetration.
*/
simulated function Explode(vector HitLocation, vector HitNormal)
{
	ProcessContact(False, Trace(HitLocation, HitNormal, HitLocation + 10 * HitNormal, HitLocation - 10 * HitNormal, True), HitLocation, HitNormal);
}


simulated function ProcessContact(bool bPenetrate, Actor Other, vector HitLocation, vector HitNormal)
{
	local vector VDiff;
	local PlayerController PC;
	local class<DamageType> DamageType;
	local Pawn HeadshotPawn;

	// check for headshot
	if (Vehicle(Other) != None) {
		HeadShotPawn = Vehicle(Other).CheckForHeadShot(HitLocation, Normal(Velocity), HeadShotSizeAdjust);
	}
	if (HeadShotPawn != None) {
		if (LastTouched == Other)
			LastTouched = HeadShotPawn;
		bPenetrate = ShouldPenetrate(HeadShotPawn, HitNormal);
		Other = HeadShotPawn;
	}
	else if (Pawn(Other) != None && Pawn(Other).IsHeadShot(HitLocation, Normal(Velocity), HeadShotSizeAdjust)) {
		HeadShotPawn = Pawn(Other);
	}

	VDiff = Velocity - Normal(Velocity) * (Normal(Velocity) dot Other.Velocity);
	if (bPenetrate) {
		VDiff *= PunchThroughVelocityLossPercent;
		if (HeadShotPawn != None) {
			DamageType = ThroughHeadDamage;
		}
		else {
			DamageType = PunchThroughDamage;
		}
	}
	else {
		if (HeadShotPawn != None) {
			DamageType = HeadHitDamage;
		}
		else {
			DamageType = DirectHitDamage;
		}
	}
	if (Role == ROLE_Authority && HeadshotPawn != None) {
		PC = PlayerController(HeadShotPawn.Controller);
	}

	if (Role == ROLE_Authority && Level.NetMode == NM_Client) {
		// already torn off, do nothing
		return;
	}
	if (Role == ROLE_Authority) {
		MakeNoise(1.0);
	}
	ApplyDamage(HitLocation, VDiff, bPenetrate, DamageType, HeadshotPawn);
	if (!bPenetrate) {
		SpawnExplosionEffects(Other, HitLocation, HitNormal);
	}
	if (Role == ROLE_Authority || Other == None || Other.Role < ROLE_Authority) {
		if (bPenetrate) {
			Velocity -= VDiff;
			SpawnPenetrationEffects(Other, HitLocation, HitNormal);
		}
		else {
			if (Role == ROLE_Authority) {
				ExplosionEffectInfo.Other = Other;
				ExplosionEffectInfo.HitLocation = HitLocation;
				ExplosionEffectInfo.HitNormal = HitNormal * 1000;
				ExplosionEffectInfo = ExplosionEffectInfo;
				SetLocation(HitLocation);
				FakeDestroy();
			}
			else {
				Destroy();
			}
			return;
		}
	}

	if (PC != None && (HeadshotPawn == None || HeadshotPawn.bDeleteMe || HeadshotPawn.Health <= 0)) {
		PC.ReceiveLocalizedMessage(class'PVHeadshotVictimMessage',, InstigatorController.PlayerReplicationInfo);
	}
}


/**
Hurt all actors within the specified radius.
*/
simulated function ApplyDamage(vector HitLocation, vector VDiff, bool bPenetrate, class<DamageType> DamageType, Pawn HeadshotPawn)
{
	local Vehicle TargetVehicle;
	local array<TVictimInfo> Victims;
	local TVictimInfo VictimInfo;
	local float dist;
	local int i, j;
	local float DamageAmount, SplashDamageAmount;
	local vector Momentum;
	local bool bSplashHit;

	if (bHurtEntry) return;

	bHurtEntry = true;

	if (!bPenetrate) {
		foreach VisibleCollidingActors(class'Actor', VictimInfo.Actor, DamageRadius + 300, HitLocation) {
			if (VictimInfo.Actor.Role == ROLE_Authority && VictimInfo.Actor != LastTouched && VictimInfo.Actor != HurtWall && VictimInfo.Actor != Self && FluidSurfaceInfo(VictimInfo.Actor) == None && !VictimInfo.Actor.TraceThisActor(VictimInfo.HL, VictimInfo.HN, HitLocation + Normal(VictimInfo.Actor.Location - HitLocation) * DamageRadius, HitLocation)) {
				Victims[Victims.Length] = VictimInfo;
			}
		}
	}

	if (LastTouched != None) {
		VictimInfo.HL = TouchLocation;
		VictimInfo.HN = TouchNormal;
		VictimInfo.Actor = LastTouched;
		Victims[Victims.Length] = VictimInfo;
	}
	if (HurtWall != None) {
		VictimInfo.HL = WallLocation;
		VictimInfo.HN = WallNormal;
		VictimInfo.Actor = HurtWall;
		Victims[Victims.Length] = VictimInfo;
	}

	for (i = 0; i < Victims.Length; i++) {
		if (Victims[i].Actor != None) {
			bSplashHit = Victims[i].Actor != LastTouched && Victims[i].Actor != HurtWall;
			dist = VSize(Victims[i].HL - HitLocation);

			// splash damage
			if (bPenetrate || bSplashHit && dist >= DamageRadius) {
				SplashDamageAmount = 0;
			}
			else {
				SplashDamageAmount = Damage * (1 - dist / DamageRadius);
			}

			// splash momentum
			if (dist < DamageRadius && !bPenetrate) {
				Momentum = Normal(Victims[i].Actor.Location - HitLocation) * SplashMomentum * (1 - dist / DamageRadius);
				if (Victims[i].Actor == Instigator) {
					if (Instigator.HasUDamage())
						Momentum *= RocketJumpBoost * UDamageMomentumBoost;
					else
						Momentum *= RocketJumpBoost;
				}
				else if (Instigator != None && Instigator.HasUDamage()) {
					Momentum *= UDamageMomentumBoost;
				}
			}
			else {
				Momentum = vect(0,0,0);
			}

			if (bSplashHit) {
				// no impact damage
				DamageAmount = 0;
			}
			else {
				// impact damage
				DamageAmount = TransferDamageAmount * 0.5 * (VSize(VDiff) + PunchThroughSpeed);
				if (bPenetrate) {
					// add fixed penetration damage
					DamageAmount += ImpactDamageAmount;
				}
				// increase impact damage if headshot
				if (Victims[i].Actor == HeadshotPawn) {
					DamageAmount *= HeadShotDamageMult;
				}

				// add impact momentum
				Momentum += VDiff * MomentumTransfer;
			}

			// combine damage values
			DamageAmount = FMax(DamageAmount + SplashDamageAmount, 0);

			// apply UDamage factor if UDamage wore off or owner died
			if (bAmped && (Instigator == None || !Instigator.HasUDamage())) {
				DamageAmount *= 2;
			}

			if (int(DamageAmount) > 0 || VSize(Momentum) > 0) {
				Victims[i].Actor.SetDelayedDamageInstigatorController(InstigatorController);
				if (bSplashHit)
					Victims[i].Actor.TakeDamage(DamageAmount, Instigator, Victims[i].HL, Momentum, SplashDamageType);
				else
					Victims[i].Actor.TakeDamage(DamageAmount, Instigator, Victims[i].HL, Momentum, DamageType);
			}

			// apply damage to vehicle drivers as well
			if (Vehicle(Victims[i].Actor) != None && Vehicle(Victims[i].Actor).Health > 0) {
				TargetVehicle = Vehicle(Victims[i].Actor);
				VictimInfo.HN = vect(0,0,0);
				VictimInfo.Actor = TargetVehicle.Driver;
				if (!TargetVehicle.bRemoteControlled && VictimInfo.Actor != None && VictimInfo.Actor != LastTouched && VictimInfo.Actor != HurtWall && !VictimInfo.Actor.bCollideActors && VictimInfo.Actor.Role == ROLE_Authority) {
					VictimInfo.HL = VictimInfo.Actor.Location;
					Victims[Victims.Length] = VictimInfo;
				}
				if (ONSVehicle(TargetVehicle) != None) {
					for (j = 0; j < ONSVehicle(TargetVehicle).WeaponPawns.Length; j++) {
						VictimInfo.Actor = ONSVehicle(TargetVehicle).WeaponPawns[j].Driver;
						if (!ONSVehicle(TargetVehicle).WeaponPawns[j].bCollideActors && !ONSVehicle(TargetVehicle).WeaponPawns[j].bRemoteControlled && VictimInfo.Actor != None && VictimInfo.Actor != LastTouched && VictimInfo.Actor != HurtWall && !VictimInfo.Actor.bCollideActors && VictimInfo.Actor.Role == ROLE_Authority) {
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


/**
Spawns explosion/punch-through effects.
*/
simulated function SpawnExplosionEffects(Actor Other, vector HitLocation, vector HitNormal)
{
	local PlayerController PC;
	local class<PVMercuryExplosion> ExplosionClass;
	local rotator EffectRotationOffset;

	if (UnrealPawn(Other) != None && !Other.IsInState('Frozen')) {
		PlayBroadcastedSound(Other, ExplodeOnPlayerSound);
	}
	ExplosionClass = GetExplosionClass(Other, HitLocation, HitNormal, EffectRotationOffset);
	if (ExplosionClass != None) {
		Spawn(ExplosionClass,,, HitLocation, rotator(-HitNormal) + EffectRotationOffset).bWaterExplosion = PhysicsVolume.bWaterVolume;
	}
	if (ExplosionDecal != None && Level.NetMode != NM_DedicatedServer)	{
		// spawn explosion decal with random Roll, if within view range
		PC = Level.GetLocalPlayerController();
		if (!PC.BeyondViewDistance(Location, ExplosionDecal.Default.CullDistance))
			Spawn(ExplosionDecal, self,, Location, rotator(-HitNormal) + rot(0,0,1) * Rand(0x10000));
		else if (InstigatorController != None && PC == InstigatorController && !PC.BeyondViewDistance(Location, 2 * ExplosionDecal.Default.CullDistance))
			Spawn(ExplosionDecal, self,, Location, rotator(-HitNormal) + rot(0,0,1) * Rand(0x10000));
	}
}


/**
Play penetration sound and spawn a lot of blood after penetrating an unprotected player.
*/
simulated function SpawnPenetrationEffects(Actor Other, vector HitLocation, vector HitNormal)
{
	if (Other != None) {
		PlayBroadcastedSound(Other, ImpactSound);
		if (!class'GameInfo'.static.UseLowGore() && xPawn(Other) != None && xPawn(Other).GibGroupClass != None) {
			if ((HitLocation - Other.Location) dot Velocity < 0)
				HitLocation += Normal(Velocity) * Other.CollisionRadius;
			Spawn(xPawn(Other).GibGroupClass.default.BloodGibClass, Other,, HitLocation);
		}
	}
}


/**
Called from simulated functions to trick PlaySound() into broadcasting the sound instead of playing it locally.
*/
function PlayBroadcastedSound(Actor SoundOwner, Sound Sound)
{
	if (Level.NetMode != NM_Client && SoundOwner != None && Sound != None) {
		SoundOwner.PlaySound(Sound, SLOT_Misc, TransientSoundVolume, false, TransientSoundRadius);
	}
}


/**
Return an explosion effect class with dirt or snow particles if a corresponding surface was hit.
Non-simulated so effect is only spawned on server.
*/
simulated function class<PVMercuryExplosion> GetExplosionClass(Actor HitActor, vector HitLocation, vector HitNormal, out rotator EffectRotationOffset)
{
	local Material HitMaterial;
	local vector HL, HN;

	EffectRotationOffset = rot(16384,0,16384);

	if (PhysicsVolume.bWaterVolume) {
		return class'PVMercuryExplosion';
	}

	if (HitActor == None || HitActor.bWorldGeometry) {
		HitActor = Trace(HL, HN, HitLocation - 16 * HitNormal, HitLocation + HitNormal, True,, HitMaterial);
	}
	if (HitMaterial != None) {
		switch (HitMaterial.SurfaceType) {
			case EST_Rock:
			case EST_Dirt:
			case EST_Wood:
			case EST_Plant:
				return class'PVMercuryExplosionDirt';
			case EST_Ice:
			case EST_Snow:
				return class'PVMercuryExplosionSnow';
		}
	}
	else if (HitActor != None) {
		switch (HitActor.SurfaceType) {
			case EST_Rock:
			case EST_Dirt:
			case EST_Wood:
			case EST_Plant:
				return class'PVMercuryExplosionDirt';
			case EST_Ice:
			case EST_Snow:
				return class'PVMercuryExplosionSnow';
		}
	}
	return class'PVMercuryExplosion';
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     SplashDamageType=Class'PVWraith.PVDamTypeMercurySplashDamage'
     SplashMomentum=10000.000000
     TransferDamageAmount=0.003000
     ImpactDamageAmount=40.000000
     HeadHitDamage=Class'PVWraith.PVDamTypeMercuryHeadHit'
     DirectHitDamage=Class'PVWraith.PVDamTypeMercuryDirectHit'
     PunchThroughDamage=Class'PVWraith.PVDamTypeMercuryPunchThrough'
     ThroughHeadDamage=Class'PVWraith.PVDamTypeMercuryPunchThroughHead'
     AccelRate=15000.000000
     HeadShotDamageMult=2.500000
     HeadShotSizeAdjust=1.200000
     PunchThroughSpeed=7000.000000
     PunchThroughVelocityLossPercent=0.400000
     UDamageMomentumBoost=1.500000
     RocketJumpBoost=3.000000
     Team=255
     ExplodeOnPlayerSound=Sound'PVWraith.Effects_MercHitArmor'
     TeamSkins(0)=TexScaler'PVWraith.Skins.MercuryMissileTexRed'
     TeamSkins(1)=TexScaler'PVWraith.Skins.MercuryMissileTexBlue'
     TeamSkins(2)=TexScaler'PVWraith.Skins.MercuryMissileTexGreen'
     TeamSkins(3)=TexScaler'PVWraith.Skins.MercuryMissileTexGold'
     UDamageOverlay=Shader'XGameShaders.PlayerShaders.WeaponUDamageShader'
     UDamageThrusterColorScale(0)=(Color=(B=255,G=128,R=255,A=255))
     UDamageThrusterColorScale(1)=(RelativeTime=1.000000,Color=(B=128,R=128))
     TrailLineColor(0)=(X=(Min=1.000000,Max=1.000000),Y=(Min=0.300000,Max=0.300000),Z=(Min=0.300000,Max=0.300000))
     TrailLineColor(1)=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=1.000000,Max=1.000000))
     TrailLineColor(2)=(X=(Min=0.500000,Max=0.500000),Y=(Min=1.000000,Max=1.000000),Z=(Min=0.500000,Max=0.500000))
     TrailLineColor(3)=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=0.300000,Max=0.300000))
     DopplerStrength=1.500000
     DopplerBaseSpeed=3000.000000
     direction=-1
     Speed=5000.000000
     MaxSpeed=25000.000000
     Damage=50.000000
     DamageRadius=500.000000
     MomentumTransfer=4.000000
     MyDamageType=Class'PVWraith.PVDamTypeMercuryDirectHit'
     ImpactSound=Sound'PVWraith.Effects_MercPunchThrough'
     ExplosionDecal=Class'PVWraith.PVMercuryImpactMark'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=20
     LightBrightness=255.000000
     LightRadius=5.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'VMWeaponsSM.AVRiLGroup.AVRiLprojectileSM'
     bDynamicLight=True
     bIgnoreVehicles=True
     AmbientSound=Sound'PVWraith.Effects_MercFly'
     LifeSpan=6.000000
     DrawScale=0.200000
     DrawScale3D=(X=1.100000,Y=0.500000,Z=0.500000)
     Skins(0)=TexScaler'PVWraith.Skins.MercuryMissileTexNeutral'
     AmbientGlow=96
     SurfaceType=EST_Metal
     SoundVolume=160
     SoundPitch=70
     SoundRadius=350.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=700.000000
     bBounce=True
     bFixedRotationDir=True
     Mass=4.000000
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
