/******************************************************************************
OdinIonTurret

Creation date: 2012-10-21 16:39
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class OdinIonTurret extends OVHoverTankWeapon dependson(ThickTraceHelper);


//=============================================================================
// Imports
//=============================================================================

#exec audio import file=Sounds\OdinMainCharge.wav
#exec audio import file=Sounds\OdinMainFire.wav


//=============================================================================
// Properties
//=============================================================================

var() Sound FireBuildUpSound;
var float BlastBuildUpDelay;
var name EffectsAttachBone;

var float OuterTraceOffset;
var float TraceThickness;

var() float FireRecoilAmount;


//=============================================================================
// Variables
//=============================================================================

var IonTurretAttachment TurretAttachment;



simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (TurretAttachment == None)
	{
		TurretAttachment = Spawn(class'IonTurretAttachment');
		AttachToBone(TurretAttachment, PitchBone);
	}
}

simulated function Destroyed()
{
	Super.Destroyed();

	if (TurretAttachment != None)
	{
		if (ONSVehicle(Base) != None && ONSVehicle(Base).bDestroyAppearance)
			TurretAttachment.PlayExplode();
		TurretAttachment.Destroy();
	}
	TurretAttachment = None;
}

simulated function SetTeam(byte T)
{
	Super.SetTeam(T);

	if (TurretAttachment != None)
	{
		TurretAttachment.SetTeam(T);
	}
}

simulated function SetOverlayMaterial(Material mat, float time, bool bOverride)
{
	Super.SetOverlayMaterial(mat, time, bOverride);

	if (TurretAttachment != None)
	{
		TurretAttachment.SetOverlayMaterial(mat, time, bOverride);
	}
}

function byte BestMode()
{
	return 0;
}

simulated function float ChargeBar()
{
	if (FireCountDown > FireInterval - BlastBuildUpDelay)
		return FClamp((FireCountDown - (FireInterval - BlastBuildUpDelay)) / BlastBuildUpDelay, 0.0, 0.999);
	else
		return FClamp(1 - FireCountDown / (FireInterval - BlastBuildUpDelay), 0.0, 0.999);
}

function bool CanAttack(Actor Other)
{
	local vector Dir, X, Y, Z;

	if (Other != None)
	{
		Dir = Normal(Other.Location - Location);
		GetAxes(Instigator.Rotation, X, Y, Z);

		if (Abs(Z dot Dir) > 0.6)
		{
			// too high/low, i.e. can't reach with turret
			return false;
		}
	}
	return Super.CanAttack(Other);
}

simulated state InstantFireMode
{
	function Fire(Controller C)
	{
		local Actor BuildUpEffect;

		PlayOwnedSound(FireBuildUpSound, SLOT_Misc, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);
		SetTimer(BlastBuildUpDelay, False);
		NetUpdateTime = Level.TimeSeconds - 1;
		bClientTrigger = !bClientTrigger;
		if (TurretAttachment != None)
		{
			if (Level.NetMode != NM_DedicatedServer) {
				//BuildUpEffect = TurretAttachment.Spawn(BuildUpEffectClass, TurretAttachment);
				if (BuildUpEffect != None)
					TurretAttachment.AttachToBone(BuildUpEffect, EffectsAttachBone);
			}
			TurretAttachment.PlayChargeUp();
		}
	}

	simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
	{
		local PlayerController PC;

		PC = Level.GetLocalPlayerController();
		if (PC != None && ((Instigator != None && Instigator.Controller == PC) || VSize(PC.ViewTarget.Location - HitLocation) < 5000)) {
			// TODO - impact effects
		}
	}

	simulated function Timer()
	{
		CalcWeaponFire();

		if (TurretAttachment != None)
		{
			TurretAttachment.PlayFire();
		}

		if (Role == ROLE_Authority)
		{
			FlashMuzzleFlash();
			PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);
			TraceFire(WeaponFireLocation, WeaponFireRotation);
		}
		else if (Instigator.IsLocallyControlled())
		{
			PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);
			FlashMuzzleFlash();
		}
	}

	simulated event OwnerEffects()
	{
		if (!bIsRepeatingFF) {
			ClientPlayForceFeedback(FireForce);
		}
		ShakeView();

		if (Role < ROLE_Authority) {
			FireCountdown = FireInterval;

			if (TurretAttachment != None)
			{
				TurretAttachment.PlayChargeUp();
			}

			AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

			if (AmbientEffectEmitter != None)
				AmbientEffectEmitter.SetEmitterStatus(true);

			// Play firing noise
			PlayOwnedSound(FireBuildUpSound, SLOT_Misc, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);
		}

		SetTimer(BlastBuildUpDelay, False);
	}
}

simulated function CalcWeaponFire()
{
	local coords WeaponBoneCoords;
	local vector CurrentFireOffset;

	if (TurretAttachment == None)
	{
		Super.CalcWeaponFire();
	}
	else
	{
		// Calculate fire offset in world space
		WeaponBoneCoords = TurretAttachment.GetBoneCoords(EffectsAttachBone);
		CurrentFireOffset = WeaponFireOffset * vect(1,0,0);

		// Calculate rotation of the gun
		WeaponFireRotation = rotator(vector(CurrentAim) >> Rotation);

		// Calculate exact fire location
		WeaponFireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> WeaponFireRotation);
	}
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int TraceDistance)
{
	local OdinIonBlastEmitter Beam;
	//local OdinIonHeatMark Mark;

	Beam = Spawn(class'OdinIonBlastEmitter', None,, Start, Dir);
	Beam.Instigator = None;
	Beam.HitLocation = HitLocation;
	Beam.SetBeamLength(VSize(HitLocation - Start));

	/*
	Mark = Spawn(class'OdinIonHeatMark', None,, Start, Dir);
	Mark.Initialize(TraceDistance);
	*/
}

function TraceFire(Vector Start, Rotator Dir)
{
	local vector X, Y, Z, HitLocation, HitNormal, ImpactNormal, RefNormal;
	local vector TraceStart, TraceEnd;
	local float Dist, TraceDist, Damage;
	local Actor Other;
	local ONSWeaponPawn WeaponPawn;
	local int i, j;
	local array<ThickTraceHelper.THitInfo> Hits;

	MaxRange();

	if (bDoOffsetTrace) {
		WeaponPawn = ONSWeaponPawn(Owner);
		if (WeaponPawn != None && WeaponPawn.VehicleBase != None) {
			if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
				Start = HitLocation;
		}
		else if (!Owner.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (Owner.CollisionRadius * 1.5)))
			Start = HitLocation;
	}

	GetAxes(Dir + rot(0,0,1000), X, Y, Z);

	for (i = -1; i <= 1 && TraceDist < TraceRange; ++i) {
		for (j = -1; j <= 1; j++) {
			if (Abs(i) + Abs(j) >= 1) {
				TraceStart = Start + OuterTraceOffset * (i * Y + j * Z) / Sqrt(Max(i * i + j * j, 1));
				TraceEnd = TraceStart + TraceRange * X;
				Other = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, false);
				if (Other == None) {
					TraceDist = TraceRange;
					ImpactNormal = vect(0,0,0);
					break;
				}
				Dist = VSize(HitLocation - TraceStart);
				if (Dist > TraceDist) {
					TraceDist = Dist;
					ImpactNormal = HitNormal;
				}
			}
		}
	}

	TraceStart = Start;
	TraceEnd = Start + TraceDist * X;
	LastHitLocation = TraceEnd;
	/*
	foreach TraceActors(class'Actor', Other, HitLocation, HitNormal, TraceEnd, TraceStart, vect(1,1,1) * TraceThickness) {
		if (Other == Level || TerrainInfo(Other) != None || Other.bBlockProjectiles || ONSPowerCoreShield(Other) != None)
			break; // try to trace further with reduced extent
		if (Other != Self && Other != Instigator && (Other.bWorldGeometry || Other.bProjTarget || Other.bBlockActors)) {
			SpawnHitEffects(Other, HitLocation, HitNormal);
			if (Pawn(Other) != None && Pawn(Other).Weapon != None && Pawn(Other).Weapon.CheckReflect(HitLocation, RefNormal, (DamageMin + DamageMax) / 3)) {
				// successfully blocked by shieldgun, apply reduced damage but increased momentum
				Other.TakeDamage(RandRange(DamageMin, DamageMax) / 3, Instigator, HitLocation, 2 * Momentum * Normal(HitLocation - Start), DamageType);
				Other = None;
			}
			else {
				Other.TakeDamage(RandRange(DamageMin, DamageMax), Instigator, HitLocation, Momentum * Normal(HitLocation - Start), DamageType);
			}
		}
	}
	if (Other != None) { // continue with zero-width trace after hitting BSP or terrain
		TraceStart += X * VSize(TraceStart - HitLocation);
		foreach TraceActors(class'Actor', Other, HitLocation, HitNormal, TraceEnd, TraceStart) {
			if (Other != Self && Other != Instigator && (Other.bWorldGeometry || Other.bProjTarget || Other.bBlockActors)) {
				SpawnHitEffects(Other, HitLocation, HitNormal);
				if (Pawn(Other) != None && Pawn(Other).Weapon != None && Pawn(Other).Weapon.CheckReflect(HitLocation, RefNormal, (DamageMin + DamageMax) / 3)) {
					// successfully blocked by shieldgun, apply reduced damage but increased momentum
					Other.TakeDamage(RandRange(DamageMin, DamageMax) / 3, Instigator, HitLocation, 2 * Momentum * Normal(HitLocation - Start), DamageType);
				}
				else {
					Other.TakeDamage(RandRange(DamageMin, DamageMax), Instigator, HitLocation, Momentum * Normal(HitLocation - Start), DamageType);
				}
			}
			if (Other == Level || TerrainInfo(Other) != None || Other.bBlockProjectiles || ONSPowerCoreShield(Other) != None)
				break;
		}
	}
	*/

	Hits = class'ThickTraceHelper'.static.TraceHits(Self, TraceStart, TraceEnd, TraceThickness);
	for (i = 0; i < Hits.Length; i++)
	{
		Other = Hits[i].HitActor;

		if (Other.bBlockProjectiles || ONSPowerCoreShield(Other) != None)
			break;

		if (Other != Self && Other != Instigator && (Other.bWorldGeometry || Other.bProjTarget || Other.bBlockActors)) {
			SpawnHitEffects(Other, HitLocation, HitNormal);
			Damage = RandRange(DamageMin, DamageMax);
			if (Other.TraceThisActor(HitLocation, HitNormal, TraceEnd, TraceStart))
			{
				// grazing shot, reduce damage
				Damage *= 0.75;
			}
			HitLocation = Hits[i].HitLocation;
			HitNormal = Hits[i].Hitnormal;
			if (Pawn(Other) != None && Pawn(Other).Weapon != None && Pawn(Other).Weapon.CheckReflect(HitLocation, RefNormal, (DamageMin + DamageMax) / 3)) {
				// successfully blocked by shieldgun, apply reduced damage but increased momentum
				Other.TakeDamage(Damage * 0.4, Instigator, HitLocation, 2.5 * Momentum * Normal(HitLocation - Start), DamageType);
			}
			else {
				Other.TakeDamage(Damage, Instigator, HitLocation, Momentum * Normal(HitLocation - Start), DamageType);
			}
		}

	}

	if (ImpactNormal != vect(0,0,0))
	{
		HitCount++;
		SpawnHitEffects(Other, LastHitLocation, ImpactNormal);
	}
	SpawnBeamEffect(Start, Dir, LastHitLocation, ImpactNormal, int(TraceDist) + 50);
	Instigator.KAddImpulse(-FireRecoilAmount * vector(Dir), Start);

	NetUpdateTime = Level.TimeSeconds - 1;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     FireBuildUpSound=Sound'OdinV2Omni.OdinMainCharge'
     BlastBuildUpDelay=0.25000
     EffectsAttachBone="Muzzle"
     OuterTraceOffset=35.000000
     TraceThickness=180.000000
     FireRecoilAmount=80000.000000
     YawBone="PlasmaGunBarrel"
     YawEndConstraint=0.000000
     PitchBone="PlasmaGunBarrel"
     PitchUpLimit=6000
     WeaponFireAttachmentBone="Firepoint"
     RotationsPerSecond=0.200000
     bInstantFire=True
     FireInterval=3.500000
     FireSoundClass=Sound'OdinV2Omni.OdinMainFire'
     FireSoundVolume=512.000000
     DamageType=Class'OdinV2Omni.DamTypeOdinIonBeam'
     DamageMin=500
     DamageMax=625
     TraceRange=22000.000000
     Momentum=150000.000000
     AIInfo(0)=(bInstantHit=True,WarnTargetPct=0.900000,RefireRate=0.100000)
     Mesh=SkeletalMesh'WVHoverTankV2.Odin.IonTurretDummy'
     bForceSkelUpdate=True
     SoundRadius=1500.000000
}
