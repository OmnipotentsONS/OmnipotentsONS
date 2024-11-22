/**
PersesNapalmRocket

Creation date: 2013-12-12 12:52
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniNapalmRocket extends PersesOmniProjectileBase;


#exec audio import file=Sounds\NapalmRocketExplode.wav


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     AccelRate=1500.000000
     FlightParticleSystem=Class'PersesOmni.PersesOmniNapalmRocketFlightEffects'
     ExplosionParticleSystem=Class'XEffects.NewExplosionA'
     ExplosionSound=Sound'PersesOmni.NapalmRocketExplode'
     TransferDamageAmount=0.004000
     SplashDamageType=Class'PersesOmni.DamTypePersesOmniNapalmRocket'
     SplashMomentum=20000.000000
     bAutoInit=True
     SubmunitionType=Class'PersesOmni.PersesOmniNapalmGlob'
     SubmunitionCount=10
     ProjectileName="Napalm Rocket"
     Speed=1500.000000
     MaxSpeed=3000.000000
     Damage=40.000000
     DamageRadius=400.000
     MomentumTransfer=4.000000
     MyDamageType=Class'PersesOmni.DamTypePersesOmniNapalmRocket'
     ExplosionDecal=Class'XEffects.RocketMark'
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=10.000000
     TransientSoundRadius=500.000000
     Mass=5.000000
}
