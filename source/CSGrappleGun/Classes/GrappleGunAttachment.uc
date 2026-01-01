class GrappleGunAttachment extends xWeaponAttachment;

function InitFor(Inventory I)
{
    Super.InitFor(I);
}

simulated event ThirdPersonEffects()
{
    Super.ThirdPersonEffects();
}

defaultproperties
{
     Mesh=SkeletalMesh'Weapons.BallLauncher_3rd'
}
