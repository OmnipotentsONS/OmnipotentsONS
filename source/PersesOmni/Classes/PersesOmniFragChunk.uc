/**
PersesFragChunk

Creation date: 2013-12-12 12:52
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniFragChunk extends PersesOmniProjectileBase;


//=============================================================================
// Imports
//=============================================================================

#exec audio import file=Sounds\FragBounce1.wav
#exec audio import file=Sounds\FragBounce2.wav


//=============================================================================
// Properties
//=============================================================================

var array<Sound> ImpactSounds;


//=============================================================================
// Variables
//=============================================================================

var byte RemainingBounces;


replication
{
	reliable if (bNetInitial)
		RemainingBounces;
}


simulated function ProcessContact(Actor Other, vector HitLocation, vector HitNormal)
{
	ExplosionSound = ImpactSounds[Rand(ImpactSounds.Length)];
	
	if (Other != None && (Other.bStatic || Other.bWorldGeometry) && RemainingBounces != 0)
	{
		Bounce(HitLocation, HitNormal);
	}
	else
	{
		Damage *= VSize(Velocity) / MaxSpeed;
		Explode(HitLocation, HitNormal);
	}
}

simulated function Bounce(vector HitLocation, vector HitNormal)
{
	RemainingBounces--;
	
	if (Role == ROLE_Authority)
		MakeNoise(0.5);

	if (LastTouched != None)
	{
		LastTouched.TakeDamage(Damage * VSize(Velocity) / MaxSpeed, Instigator, HitLocation, Normal(Velocity) * MomentumTransfer, MyDamageType);
	}
	else if (HurtWall != None)
	{
		HurtWall.TakeDamage(Damage * VSize(Velocity) / MaxSpeed, Instigator, HitLocation, Normal(Velocity) * MomentumTransfer, MyDamageType);
	}
	SpawnExplosionEffects(HitLocation, HitNormal);
	
	Velocity = MirrorVectorByNormal(Velocity, HitNormal) * 0.85;
	
	if (ProjEffects != None)
	{
		ProjEffects.SetBase(None);
		ProjEffects.SetLocation(HitLocation);
	}
	SpawnFlightEffects(); // create a new trail so the old one ends at the impact location
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     ImpactSounds(0)=Sound'PersesOmni.FragBounce1'
     ImpactSounds(1)=Sound'PersesOmni.FragBounce2'
     RemainingBounces=3
     bBlockedByInstigator=True
     FlightParticleSystem=Class'PersesOmni.PersesOmniFragChunkFlightEffects'
     ExplosionParticleSystem=Class'PersesOmni.PersesOmniFragImpactSparks'
     Speed=6000.000000
     MaxSpeed=8000.000000
     Damage=20.000000
     DamageRadius=0.000000
     MomentumTransfer=10000.000000
     MyDamageType=Class'PersesOmni.DamTypePersesOmniFragChunk'
     ExplosionDecal=Class'XEffects.BulletDecal'
     MaxEffectDistance=5000.000000
     Physics=PHYS_Falling
     LifeSpan=1.000000
     bIgnoreTerminalVelocity=True
     Mass=1.000000
     DrawScale=2.0000
}
