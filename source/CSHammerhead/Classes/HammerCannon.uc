class HammerCannon extends ONSHoverTankCannon;

var() float RecoilMagnitude;

//Apply some recoil (it's a big gun!).
function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    Owner.KAddImpulse(-vector(WeaponFireRotation) * RecoilMagnitude, WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1));

    return Super.SpawnProjectile(ProjClass, bAltFire);
}

defaultproperties
{
     RecoilMagnitude=50000.000000
     YawEndConstraint=0.000000
     PitchBone="cannonrotation"
     WeaponFireAttachmentBone="cannonfire"
     RedSkin=Texture'CSHammerhead.hummertex_red'
     BlueSkin=Texture'CSHammerhead.hummertex_blue'
     FireSoundClass=Sound'CSHammerhead.HammerFire'
     ProjectileClass=Class'CSHammerhead.HammerProjectile'
     //Mesh=SkeletalMesh'CSHammerhead.HammerCannon'
     Mesh=SkeletalMesh'CSHammerhead.Cannon'
}
