//=============================================================================
// MercuryMissile
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// High speed rocket.
//=============================================================================


class PersesOmniMercuryMissile extends PersesOmniProjectileBase;


//=============================================================================
// Imports
//=============================================================================

#exec audio import file=Sounds\MercPunchThrough.wav
#exec audio import file=Sounds\MercHitArmor.wav


//=============================================================================
// Properties
//=============================================================================

var float ImpactDamageAmount;

var class<DamageType> PunchThroughDamage;
var float PunchThroughSpeed, PunchThroughVelocityLossPercent;
var Sound ExplodeOnPlayerSound;
var float DopplerStrength, DopplerBaseSpeed;


/**
Adjust ambient sound to fake doppler effect.
*/
auto simulated state Flying
{
	simulated event Tick(float DeltaTime)
	{
		local PlayerController LocalPlayer;
		local float ApproachSpeed;

		if (Level.NetMode != NM_DedicatedServer && ProjEffects != None)
		{
			LocalPlayer = Level.GetLocalPlayerController();
			if (LocalPlayer != None)
			{
				ApproachSpeed = (Velocity + LocalPlayer.ViewTarget.Velocity) dot Normal(LocalPlayer.ViewTarget.Location - Location);
				ProjEffects.SoundPitch = ProjEffects.default.SoundPitch * (DopplerStrength ** (ApproachSpeed / DopplerBaseSpeed));
			}
		}
	}
}


/**
Returns how a contact with another object affects this projectile's movement.
*/
simulated function bool ShouldPenetrate(Actor Other, vector HitLocation, vector HitNormal)
{
	local vector RefNormal;
	
	return xPawn(Other) != None && !Other.IsInState('Frozen') && VSize(Velocity) - Normal(Velocity) dot Other.Velocity > PunchThroughSpeed && xPawn(Other).GetShieldStrength() == 0 && !xPawn(Other).CheckReflect(HitLocation, RefNormal, 0);
}

simulated function ProcessContact(Actor Other, vector HitLocation, vector HitNormal)
{
	if (ShouldPenetrate(Other, HitLocation, HitNormal))
	{
		Penetrate(Other, HitLocation);
	}
	else
	{
		if (UnrealPawn(Other) != None && !Other.IsInState('Frozen'))
			PlayBroadcastedSound(Other, ExplodeOnPlayerSound);
		
		ExplosionParticleSystem = GetExplosionClass(Other, HitLocation, HitNormal);
		Explode(HitLocation, HitNormal);
	}
}


simulated function Penetrate(Actor Other, vector HitLocation)
{
	local vector VDiff, Momentum;
	local float DamageAmount;
	
	VDiff = Velocity - Normal(Velocity) * (Normal(Velocity) dot Other.Velocity);
	VDiff *= PunchThroughVelocityLossPercent;
	
	if (Role == ROLE_Authority)
		MakeNoise(1.0);
	
	DamageAmount = TransferDamageAmount * 0.5 * (VSize(VDiff) + PunchThroughSpeed) + ImpactDamageAmount;
	Momentum = VDiff * MomentumTransfer;
	
	// apply UDamage factor if UDamage wore off or owner died
	if (bAmped && (Instigator == None || !Instigator.HasUDamage()))
		DamageAmount *= 2;

	if (int(DamageAmount) > 0 || VSize(Momentum) > 0)
	{
		Other.SetDelayedDamageInstigatorController(InstigatorController);
		Other.TakeDamage(DamageAmount, Instigator, HitLocation, Momentum, PunchThroughDamage);
	}

	if (Role == ROLE_Authority || Other == None || Other.Role < ROLE_Authority)
	{
		Velocity -= VDiff;
		SpawnPenetrationEffects(Other, HitLocation);
	}
}


/**
Play penetration sound and spawn a lot of blood after penetrating an unprotected player.
*/
simulated function SpawnPenetrationEffects(Actor Other, vector HitLocation)
{
	if (Other != None)
	{
		PlayBroadcastedSound(Other, ImpactSound);
		if (!class'GameInfo'.static.UseLowGore() && xPawn(Other) != None && xPawn(Other).GibGroupClass != None)
		{
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
simulated function class<PersesOmniMercuryExplosion> GetExplosionClass(Actor HitActor, vector HitLocation, vector HitNormal)
{
	local Material HitMaterial;
	local vector HL, HN;

	if (PhysicsVolume.bWaterVolume) {
		return class'PersesOmniMercuryExplosion';
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
				return class'PersesOmniMercuryExplosionDirt';
			case EST_Ice:
			case EST_Snow:
				return class'PersesOmniMercuryExplosionSnow';
		}
	}
	else if (HitActor != None) {
		switch (HitActor.SurfaceType) {
			case EST_Rock:
			case EST_Dirt:
			case EST_Wood:
			case EST_Plant:
				return class'PersesOmniMercuryExplosionDirt';
			case EST_Ice:
			case EST_Snow:
				return class'PersesOmniMercuryExplosionSnow';
		}
	}
	return class'PersesOmniMercuryExplosion';
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     ImpactDamageAmount=50.000000
     PunchThroughDamage=Class'PersesOmni.DamTypePersesOmniMercuryPunchThrough'
     PunchThroughSpeed=15000.000000
     PunchThroughVelocityLossPercent=0.400000
     ExplodeOnPlayerSound=Sound'PersesOmni.MercHitArmor'
     DopplerStrength=1.500000
     DopplerBaseSpeed=3000.000000
     FlightParticleSystem=Class'PersesOmni.PersesOmniMercuryMissileFlightEffects'
     FlightParticleSystemBlue=Class'PersesOmni.PersesOmniMercuryMissileFlightEffectsBlue'
     TransferDamageAmount=0.003000
     SplashDamageType=Class'PersesOmni.DamTypePersesOmniMercurySplashDamage'
     SplashMomentum=10000.000000
     bAutoInit=True
     ProjectileName="Perses Mercury Missile"
     Speed=8000.000000
     MaxSpeed=30000.000000
     AccelRate=15000.000000
     Damage=37.000000
     DamageRadius=500.000000
     MomentumTransfer=4.000000
     MyDamageType=Class'PersesOmni.DamTypePersesOmniMercuryDirectHit'
     ImpactSound=Sound'PersesOmni.MercPunchThrough'
     ExplosionDecal=Class'PersesOmni.PersesOmniMercuryImpactMark'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=20
     LightBrightness=255.000000
     LightRadius=5.000000
     bDynamicLight=False
     LifeSpan=6.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=500.000000
     Mass=3.000000
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
     DrawScale=2.0
     Skins(0)=TexScaler'WVMercuryMissiles_Tex.Skins.MercuryMissileTexNeutral'

}
