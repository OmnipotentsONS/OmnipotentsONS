class OmniRedeemerIIFire extends ProjectileFire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    p = Super.SpawnProjectile(Start,Dir);
    if ( p == None )
        p = Super.SpawnProjectile(Instigator.Location,Dir);
    if ( p == None )
    {
	 	Weapon.Spawn(class'SmallRedeemerExplosion');
		Weapon.HurtRadius(500, 400, class'DamTypeOmniNukeRedeemerII', 100000, Instigator.Location);
	}
    return p;
}

function float MaxRange()
{
	return 30000;
}

defaultproperties
{
     ProjSpawnOffset=(X=100.000000,Z=0.000000)
     bSplashDamage=True
     bRecommendSplashDamage=True
     TransientSoundVolume=1.000000
     FireSound=Sound'OmniNukesSounds.OmniNukes.WLFire'
     FireForce="redeemer_shoot"
     FireRate=1.000000
     AmmoClass=Class'OmniNukes.OmniRedeemerIIAmmo'
     AmmoPerFire=1
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'OmniNukes.OmniRedeemerIIProjectile'
     BotRefireRate=0.500000
}
