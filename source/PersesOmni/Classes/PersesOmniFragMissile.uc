/**
.PersesFragMissile

Creation date: 2013-12-12 12:52
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniFragMissile extends PersesOmniProjectileBase;


#exec audio import file=Sounds\FragMissileExplode.wav


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     AccelRate=1200.000000
     FlightParticleSystem=Class'PersesOmni.PersesOmniFragMissileFlightEffects'
     ExplosionParticleSystem=Class'XEffects.NewExplosionA'
     ExplosionSound=Sound'PersesOmni.FragMissileExplode'
     TransferDamageAmount=0.004500
     SplashDamageType=Class'PersesOmni.DamTypePersesOmniFragMissile'
     SplashMomentum=50000.000000
     bAutoInit=True
     SubmunitionType=Class'PersesOmni.PersesOmniFragChunk'
     SubmunitionCount=15
     ProjectileName="Perses Flak Missile"
     Speed=1500.000000
     MaxSpeed=5000.000000
     Damage=90.000000 // 60
     DamageRadius=250.000000
     MomentumTransfer=4.0000
     MyDamageType=Class'PersesOmni.DamTypePersesOmniFragMissile'
     ExplosionDecal=Class'XEffects.RocketMark'
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     TransientSoundRadius=500.000000
     Mass=3.000000
}
