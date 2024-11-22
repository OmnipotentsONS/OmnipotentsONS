
class PersesOmniArtilleryShellChild extends ONSArtilleryShellSmall;


simulated function PostBeginPlay()
{
	if (!PhysicsVolume.bWaterVolume && Level.NetMode != NM_DedicatedServer)
		Trail = Spawn(class'FlakShellTrail', self);

	Super(Projectile).PostBeginPlay();
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
	PlaySound(ImpactSound, SLOT_None, 2.0);
	if (Level.NetMode != NM_DedicatedServer)
		Spawn(AirExplosionEffectClass);
	
	Explode(Location, Normal(Velocity));
	Destroy();
}

event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType);


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     ExplosionEffectClass=Class'PersesOmni.PersesOmniArtilleryAirExplosion'
     AirExplosionEffectClass=Class'PersesOmni.PersesOmniArtilleryAirExplosion'
     Damage=200.000000
     DamageRadius=500.000000
     ImpactSound=Sound'UT3SPMA.SPMAShellFragmentExplode'
     AmbientSound=None
     TransientSoundRadius=500.000000
     bProjTarget=False
}
