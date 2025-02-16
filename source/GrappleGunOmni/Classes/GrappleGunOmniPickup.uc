class GrappleGunOmniPickup extends UTWeaponPickup;

defaultproperties
{
     InventoryType=Class'GrappleGunOmni.GrappleGunOmni'
     PickupMessage="You got the )o( Grapple Gun (NOT LINK!)"
     Skins(0)=Shader'GrappleGunOmni_Tex.GrappleGun.GrappleGunShader'
     StandUp=(Y=0.250000,Z=0.000000)
     MaxDesireability=0.200000
     PickupSound=Sound'PickupSounds.ShieldGunPickup' // diff sound than link
     PickupForce="LinkGunPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'NewWeaponPickups.LinkPickupSM'
     DrawScale=0.650000
}
