class CSPallasMortarShellSmall extends CSPallasMortarShell;

simulated function SpawnEffects(vector HitLocation, vector HitNormal)
{
    PlaySound(sound'WeaponSounds.ShockRifle.ShockComboFire',,3.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(class'ShockComboVortex',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'CSPallasVortexSmall',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'ShockCombo',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'CSPallasSphereDarkSmall',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'CSPallasExplosionRingSmall',,, HitLocation, rotator(vect(0,0,1)));

        Spawn(class'CSPallasExplosionRingSmall',,, HitLocation + (VRand()*10.0), rotator(vect(0,0,1)));
        Spawn(class'CSPallasExplosionRingSmall',,, HitLocation + (VRand()*10.0), rotator(vect(0,0,1)));
        Spawn(class'CSPallasExplosionRingSmall',,, HitLocation + (VRand()*10.0), rotator(vect(0,0,1)));
        Spawn(class'CSPallasExplosionRingSmall',,, HitLocation + (VRand()*10.0), rotator(vect(0,0,1)));
        Spawn(class'CSPallasExplosionRingSmall',,, HitLocation + (VRand()*10.0), rotator(vect(0,0,1)));

        Spawn(class'ShockComboExpRing',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'ShockComboFlash',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'CSPallasFlashExplosion',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'ONSTankHitRockEffect',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }
}

defaultproperties
{
     Damage=250.000000
     DamageRadius=800.000000
     bNetTemporary=True
     TransientSoundRadius=1000.000000
     TransientSoundVolume=0.1
     SoundVolume=100
}
