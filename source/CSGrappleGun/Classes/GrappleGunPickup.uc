class GrappleGunPickup extends UTWeaponPickup;

defaultproperties
{
    InventoryType=Class'GrappleGun'
    PickupMessage="You got the grapple gun."
    PickupSound=Sound'PickupSounds.SniperRiflePickup'
    PickupForce="SniperRiflePickup"
    DrawType=DT_Mesh
    Mesh=SkeletalMesh'Weapons.BallLauncher_3rd'
    DrawScale=0.4
    Physics=PHYS_Rotating
    bUnlit=true
    bDynamicLight=True
    //AmmoAmount=1
    bDropped=false
}
