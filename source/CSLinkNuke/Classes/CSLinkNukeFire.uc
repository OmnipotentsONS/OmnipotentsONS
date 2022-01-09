class CSLinkNukeFire extends ProjectileFire;

//#exec AUDIO IMPORT FILE=Sounds\ohyeahhats.wav

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;
    
    if( ProjectileClass != None )
        p = Weapon.Spawn(ProjectileClass,Owner,, Start, Dir);

    if( p == None )
        return None;

    p.Damage *= DamageAtten;
    return p;
}

defaultproperties
{
     ProjSpawnOffset=(X=100.000000,Z=0.000000)
     bSplashDamage=True
     bRecommendSplashDamage=True
     TransientSoundVolume=1.000000
     FireSound=Sound'WeaponSounds.Misc.redeemer_shoot'
     FireForce="redeemer_shoot"
     FireRate=1.000000
     AmmoClass=Class'CSLinkNuke.CSLinkNukeAmmo'
     AmmoPerFire=1
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'CSLinkNuke.CSLinkNukeProjectile'
     BotRefireRate=0.500000
}
