/******************************************************************************
PersesArtilleryShell

Creation date: 2011-08-22 16:32
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class PersesOmniArtilleryShell extends ONSMortarShell;


//#exec audio import file=Sounds\ShellBrakingExplode1.wav
//#exec audio import file=Sounds\ShellBrakingExplode2.wav
//#exec audio import file=Sounds\ShellFragmentExplode1.wav
//#exec audio import file=Sounds\ShellFragmentExplode2.wav


var Sound AirExplosionSound;
var class<Projectile> ChildProjectileClass;
var float SpreadFactor;
var Emitter SmokeTrail;


simulated function PostBeginPlay()
{
	if (!PhysicsVolume.bWaterVolume && Level.NetMode != NM_DedicatedServer)
		Trail = Spawn(class'FlakShellTrail', self);

	Super(Projectile).PostBeginPlay();
}

simulated function Timer()
{
	local int i, j;
	local Projectile Child;
	local float Mag;
	local vector CurrentVelocity, X, Y, Z;
	
	if (Level.NetMode != NM_DedicatedServer)
		Spawn(class'ONSArtilleryShellSplit', self, , Location, Rotation);
	
	CurrentVelocity = 0.85 * Velocity;
	GetAxes(rotator(CurrentVelocity), X, Y, Z);
	
	// one shell in each of 9 zones
	for (i = -1; i < 2; i++)
	{
		for (j= -1; j < 2; j++)
		{
			if (Abs(i) + Abs(j) > 1)
				Mag = 0.7;
			else
				Mag = 1.0;
			Child = Spawn(ChildProjectileClass, self,, Location);
			if (Child != None)
			{
				Child.Velocity = CurrentVelocity + SpreadFactor * (X * (FRand() - 0.5) + Mag * (Y * (RandRange(0.3, 1.0) * i) + Z * (RandRange(0.3, 1.0) * j)));
				Child.InstigatorController = InstigatorController;
			}
		}
	}
	ExplodeInAir();
}

simulated function SpawnEffects(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(ImpactSound, SLOT_None, 2.0);
	if (EffectIsRelevant(Location, false))
	{
		PC = Level.GetLocalPlayerController();
		if (PC.ViewTarget != None && VSize(PC.ViewTarget.Location - Location) < 3000)
			Spawn(ExplosionEffectClass,,, HitLocation + HitNormal * 16);
		Spawn(ExplosionEffectClass,,, HitLocation + HitNormal * 16);
		if (ExplosionDecal != None && Level.NetMode != NM_DedicatedServer)
			Spawn(ExplosionDecal, self,, HitLocation, rotator(-HitNormal));
	}
}

simulated function ExplodeInAir()
{
	bExploded = true;
	PlaySound(AirExplosionSound, SLOT_None, 2.0);
	if (Level.NetMode != NM_DedicatedServer)
		Spawn(AirExplosionEffectClass);
	
	Explode(Location, Normal(Velocity));
	Destroy();
}

event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    if (Damage > 0 && (EventInstigator == None || EventInstigator.Controller == None || InstigatorController == None || !EventInstigator.Controller.SameTeamAs(InstigatorController)))
	{
		if (EventInstigator != None)
			Instigator = EventInstigator;
        ExplodeInAir();
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     AirExplosionSound=Sound'UT3SPMA.SPMAShellBreakingExplode'
     ChildProjectileClass=Class'PersesOmni.PersesOmniArtilleryShellChild'
     SpreadFactor=400.000000
     ExplosionEffectClass=Class'PersesOmni.PersesOmniArtilleryAirExplosion'
     AirExplosionEffectClass=Class'PersesOmni.PersesOmniArtilleryAirExplosion'
     MyDamageType=Class'PersesOmni.DamTypePersesOmniArtilleryShell'
     ImpactSound=Sound'UT3SPMA.SPMAShellFragmentExplode'
     AmbientSound=None
     TransientSoundRadius=500.000000
}
