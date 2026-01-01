class GrappleGunFire extends ProjectileFire;

var() Sound TransFireSound;
var() Sound RecallFireSound;
var() String TransFireForce;
var() String RecallFireForce;

simulated function PlayFiring()
{
    if (!GrappleGun(Weapon).bBeaconDeployed)
    {
        Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
        ClientPlayForceFeedback( TransFireForce );  // jdf
    }
}

function Rotator AdjustAim(Vector Start, float InAimError)
{
    return Instigator.Controller.Rotation;
}

/*
simulated function bool AllowFire()
{
    return ( GrappleGun(Weapon).AmmoChargeF >= 1.0 );
}
*/

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local GrappleGunBeacon GrappleGunBeacon;

    if(GrappleGun(Weapon).GrappleGunBeacon != None)
    {
        GrappleGun(Weapon).GrappleGunBeacon.Destroy();
        GrappleGun(Weapon).GrappleGunBeacon = None;
    }

    GrappleGunBeacon = Weapon.Spawn(class'GrappleGunBeacon',,, Start, Dir);
    GrappleGun(Weapon).GrappleGunBeacon = GrappleGunBeacon;
    Weapon.PlaySound(TransFireSound,SLOT_Interact,0.1,,,,false);

    return GrappleGunBeacon;
}

defaultproperties
{
     TransFireSound=SoundGroup'WeaponSounds.Translocator.TranslocatorFire'
     RecallFireSound=SoundGroup'WeaponSounds.Translocator.TranslocatorModuleRegeneration'
     TransFireForce="TranslocatorFire"
     RecallFireForce="TranslocatorModuleRegeneration"
     ProjSpawnOffset=(X=25.000000,Y=8.000000)
     bLeadTarget=False
     bWaitForRelease=True
     bModeExclusive=False
     FireAnimRate=1.500000
     FireRate=0.250000
     AmmoPerFire=1
     ProjectileClass=Class'GrappleGunBeacon'
     AmmoClass=class'GrappleGunAmmo'
     BotRefireRate=0.300000
}