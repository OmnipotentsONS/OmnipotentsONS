/******************************************************************************
OdinLinkTurret

Creation date: 2012-10-22 15:02
Last change: $Id$
Copyright � 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class OdinLinkTurret extends HoverTankWeapon;


#exec audio import file=Sounds\OdinLinkAmbient.wav


var() float DamagePerSecond;
var() int MinDamageAmount;
var() float HealMultiplier;
var() float SelfHealMultiplier;
var() float LinkBreakError;
var class<OdinLinkBeamEffect> BeamEffectClass;
var array<class<Projectile> > TeamProjectileClasses;

var OdinLinkBeamEffect Beam1, Beam2;
var bool bFiringBeam;
var Actor LinkedActor;
var float SavedDamage, SavedHeal;
var float DamageModifier;


simulated function DestroyEffects()
{
	if (Beam1 != None)
		Beam1.Destroy();
	if (Beam2 != None)
		Beam2.Destroy();

	Beam1 = None;
	Beam2 = None;

	Super.DestroyEffects();
}

function bool CanAttack(Actor Other)
{
	local vector HL, HN;
	local ONSWeaponPawn WeaponPawn;

	if (Super.CanAttack(Other))
	{
		WeaponPawn = ONSWeaponPawn(Owner);
		if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
			return WeaponPawn.VehicleBase.TraceThisActor(HL, HN, WeaponFireLocation, Other.Location);
		else
			return Owner.TraceThisActor(HL, HN, WeaponFireLocation, Other.Location);
	}

	return false;
}

simulated function CalcWeaponFire()
{
	local coords WeaponBoneCoords;
	local vector CurrentFireOffset;

	// Calculate fire offset in world space
	WeaponBoneCoords = GetBoneCoords(WeaponFireAttachmentBone);
	CurrentFireOffset = WeaponFireOffset * WeaponBoneCoords.XAxis;

	// Calculate rotation of the gun
	WeaponFireRotation = rotator(vector(CurrentAim) >> Rotation);

	// Calculate exact fire location
	WeaponFireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset /*>> WeaponFireRotation*/);
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	local Projectile P1, P2;
	local ONSWeaponPawn WeaponPawn;
	local vector StartLocation, HitLocation, HitNormal, Extent, X, Y, Z;

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
	{
		StartLocation = WeaponFireLocation;
	}

	GetAxes(WeaponFireRotation, X, Y, Z);

	P1 = Spawn(ProjClass, self,, StartLocation + DualFireOffset * Y, WeaponFireRotation);
	P2 = Spawn(ProjClass, self,, StartLocation - DualFireOffset * Y, WeaponFireRotation);

	if (P1 != None || P2 != None)
	{
		if (bInheritVelocity)
		{
			if (P1 != None)
				P1.Velocity += Instigator.Velocity;
			if (P2 != None)
				P2.Velocity += Instigator.Velocity;
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
	}

	if (P1 != None)
		return P1;
	else
		return P2;
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

	if (Role < ROLE_Authority && !bIsAltFire)
	{
		FireCountdown = FireInterval;

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

		FlashMuzzleFlash();

		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);

		if (!bAmbientFireSound)
			PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
	}
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (bFiringBeam != bClientTrigger)
	{
		UpdateBeamState();
	}

	if (bFiringBeam)
	{
		TraceBeamFire(DeltaTime);
	}
}

simulated function ClientTrigger()
{
	UpdateBeamState();
}

simulated function UpdateBeamState()
{
	if (bFiringBeam && !bClientTrigger)
	{
		if (Beam1 != None)
			Beam1.Destroy();
		if (Beam2 != None)
			Beam2.Destroy();
		Beam1 = None;
		Beam2 = None;
		LinkedActor = None;
	}
	else if (!bFiringBeam && bClientTrigger)
	{
		if (Level.NetMode != NM_DedicatedServer)
		{
			if (Beam1 == None)
			{
				Beam1 = Spawn(BeamEffectClass, Self);
				Beam1.SetUpBeam(Team, False);
			}
			//AttachToBone(Beam1, WeaponFireAttachmentBone);
			//Beam1.SetRelativeLocation((vect(1,0,0) * WeaponFireOffset + vect(0,1,0) * DualFireOffset) * DrawScale);

			if (Beam2 == None)
			{
				Beam2 = Spawn(BeamEffectClass, Self);
				Beam2.SetUpBeam(Team, True);
			}
			//AttachToBone(Beam2, WeaponFireAttachmentBone);
			//Beam2.SetRelativeLocation((vect(1,0,0) * WeaponFireOffset - vect(0,1,0) * DualFireOffset) * DrawScale);
		}
	}
	bFiringBeam = bClientTrigger;
	MaxRange();
}

simulated function float MaxRange()
{
	if (bFiringBeam)
	{
		if (Instigator != None && Instigator.Region.Zone != None && Instigator.Region.Zone.bDistanceFog)
			TraceRange = FClamp(Instigator.Region.Zone.DistanceFogEnd, 8000, default.TraceRange);
		else
			TraceRange = default.TraceRange;

		AimTraceRange = TraceRange;
	}
	else if (ProjectileClass != None)
		AimTraceRange = ProjectileClass.static.GetRange();
	else
		AimTraceRange = 10000;

	return AimTraceRange;
}

simulated function bool IsValidLinkTarget(Actor Target)
{
	local DestroyableObjective HealObjective;

	if (Target == None || !Target.bCollideActors || !Target.bProjTarget)
		return false;

	if (Vehicle(Target) != None && Vehicle(Target).Health > 0)
		return true; // link both friendly and enemy vehicles

	HealObjective = DestroyableObjective(Target);
	if (HealObjective == None)
		HealObjective = DestroyableObjective(Target.Owner);

	if (HealObjective != None && HealObjective.TeamLink(Instigator.GetTeamNum()))
		return true;

	return false;
}

simulated function TraceBeamFire(float DeltaTime)
{
	local vector HL, HN, Dir, HL2, HN2;
	local Actor HitActor, NewLinkedActor;
	local ONSWeaponPawn WeaponPawn;
	local Vehicle BaseVehicle;
	local int DamageAmount;

	CalcWeaponFire();

	WeaponPawn = ONSWeaponPawn(Owner);
	if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
		BaseVehicle = WeaponPawn.VehicleBase;
	else
		BaseVehicle = Vehicle(Owner);

	HitActor = Trace(HL, HN, WeaponFireLocation + vector(WeaponFireRotation) * TraceRange, WeaponFireLocation, True, vect(10,10,10));
	if (HitActor == None || HitActor == BaseVehicle || HitActor.bWorldGeometry)
	{
		// try again with zero extent
		HitActor = Trace(HL, HN, WeaponFireLocation + vector(WeaponFireRotation) * TraceRange, WeaponFireLocation, True, vect(0,0,0));
		if (HitActor == None)
		{
			HL = WeaponFireLocation + vector(WeaponFireRotation) * TraceRange;
			HN = vector(WeaponFireRotation);
		}
	}
	if (HitActor != BaseVehicle && IsValidLinkTarget(HitActor))
	{
		NewLinkedActor = HitActor;
	}
	else if (IsValidLinkTarget(LinkedActor))
	{
		Dir = LinkedActor.Location - WeaponFireLocation;
		if (VSize(Dir) < TraceRange && Normal(Dir) dot vector(WeaponFireRotation) > LinkBreakError)
		{
			HitActor = Trace(HL2, HN, LinkedActor.Location, WeaponFireLocation, True, vect(0,0,0));
			if (HitActor == None || HitActor == LinkedActor)
			{
				HL = HL2;
				HN = HN2;
				NewLinkedActor = LinkedActor;
			}
		}
	}
	else
	{
		NewLinkedActor = None;
	}

	LinkedActor = NewLinkedActor;

	if (Beam1 != None)
	{
		Beam1.EndEffect = HL;
		Beam1.bLockedOn = HitActor != None;
		Beam1.LinkedActor = LinkedActor;
		Beam1.bHitSomething = HitActor != None && HitActor.bWorldGeometry;
	}
	if (Beam2 != None)
	{
		Beam2.EndEffect = HL;
		Beam2.bLockedOn = HitActor != None;
		Beam2.LinkedActor = LinkedActor;
		Beam2.bHitSomething = HitActor != None && HitActor.bWorldGeometry;
	}

	if (Role == ROLE_Authority)
	{
		SavedDamage += DamagePerSecond * DeltaTime * DamageModifier;
		DamageAmount = int(SavedDamage);

		if (DamageAmount > MinDamageAmount)
		{
			SavedDamage -= DamageAmount;

			if (LinkedActor != None)
			{
				if (Level.Game.bTeamGame && (Vehicle(LinkedActor) != None && Vehicle(LinkedActor).GetTeamNum() == Instigator.GetTeamNum()) || DestroyableObjective(LinkedActor) != None || DestroyableObjective(LinkedActor.Owner) != None)
				{
					LinkedActor.HealDamage(Round(DamageAmount * HealMultiplier), Instigator.Controller, DamageType);
				}
				else
				{
					if (Vehicle(LinkedActor) != None && BaseVehicle.Health < BaseVehicle.HealthMax)
					{
						BaseVehicle.HealDamage(Round(DamageAmount * SelfHealMultiplier), Instigator.Controller, DamageType);
					}
					LinkedActor.TakeDamage(DamageAmount, Instigator, HL, DeltaTime * Momentum * vector(WeaponFireRotation), DamageType);
				}
			}
			else if (HitActor != None && !HitActor.bWorldGeometry && HitActor != BaseVehicle)
			{
				if (DestroyableObjective(HitActor) != None && DestroyableObjective(HitActor).Health > 0 || DestroyableObjective(HitActor.Owner) != None && DestroyableObjective(HitActor.Owner).Health > 0 && BaseVehicle.Health < BaseVehicle.HealthMax)
				{
					BaseVehicle.HealDamage(Round(DamageAmount * SelfHealMultiplier), Instigator.Controller, DamageType);
				}
				HitActor.TakeDamage(DamageAmount, Instigator, HL, DeltaTime * Momentum * vector(WeaponFireRotation), DamageType);
			}
		}
	}
}

simulated function SetFireRateModifier(float Modifier)
{
	FireInterval = default.FireInterval / Modifier;
	DamageModifier = Modifier;
}

function byte BestMode()
{
	if (Instigator == None || Instigator.Controller == None)
		return 0;

	if (Instigator.Controller.Target != None && VSize(Instigator.Controller.Target.Location - Location) < TraceRange)
		return 1;

	if (Instigator.Controller.Enemy != None && VSize(Instigator.Controller.Enemy.Location - Location) < TraceRange)
		return 1;

	return 0;
}

state ProjectileFireMode
{
	function Fire(Controller C)
	{
		if (!bClientTrigger)
		{
			if (Team < TeamProjectileClasses.Length && TeamProjectileClasses[Team] != None)
				SpawnProjectile(TeamProjectileClasses[Team], False);
			else
				SpawnProjectile(ProjectileClass, False);
		}
	}

	function AltFire(Controller C)
	{
		AmbientSound = AltFireSoundClass;
		bClientTrigger = True;
		UpdateBeamState();

		NetUpdateTime = Level.TimeSeconds - 1;
	}

	function WeaponCeaseFire(Controller C, bool bWasAltFire)
	{
		if (bWasAltFire)
		{
			AmbientSound = None;
			bClientTrigger = False;
			UpdateBeamState();

			NetUpdateTime = Level.TimeSeconds - 1;
		}
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     DamagePerSecond=150.000000
     MinDamageAmount=10
     HealMultiplier=0.800000
     SelfHealMultiplier=0.800000
     LinkBreakError=0.950000
     BeamEffectClass=Class'OdinV2Omni.OdinLinkBeamEffect'
     TeamProjectileClasses(0)=Class'OdinV2Omni.OdinLinkPlasmaProjectileRed'
     TeamProjectileClasses(1)=Class'OdinV2Omni.OdinLinkPlasmaProjectileBlue'
     DamageModifier=1.000000
     YawBone="Object83"
     PitchBone="Object84"
     PitchUpLimit=15000
     WeaponFireAttachmentBone="Object85"
     GunnerAttachmentBone="Object83"
     WeaponFireOffset=30.000000
     DualFireOffset=18.000000
     bAmbientAltFireSound=True
     FireInterval=0.300000
     AltFireInterval=0.100000
     FireSoundClass=Sound'ONSVehicleSounds-S.LaserSounds.Laser17'
     AltFireSoundClass=Sound'OdinV2Omni.OdinLinkAmbient'
     FireForce="Laser01"
     DamageType=Class'OdinV2Omni.DamTypeOdinLinkBeam'
     DamageMin=15
     DamageMax=15
     TraceRange=2000.000000
     Momentum=-30000.000000
     ProjectileClass=Class'WVHoverTankV2.OdinLinkPlasmaProjectile'
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.200000,RefireRate=0.700000)
     AIInfo(1)=(bInstantHit=True,WarnTargetPct=0.200000)
     Mesh=SkeletalMesh'ONSFullAnimations.MASPassengerGun'
     DrawScale=0.600000
     Skins(0)=Texture'ONSFullTextures.MASGroup.LEVnoColor'
}