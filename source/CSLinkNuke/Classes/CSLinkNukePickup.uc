class CSLinkNukePickup extends RedeemerPickup;

#exec AUDIO IMPORT FILE=Sounds\ohyeah2.wav
//#exec OBJ LOAD FILE=StaticMeshes\CSLinkNukeMeshes.usx PACKAGE=CSLinkNuke

simulated function PostBeginPlay()
{
     super.PostBeginPlay();
     RespawnTime = class'MutUseLinkNuke'.default.RespawnTime;
}

defaultproperties
{
     bWeaponStay=True
     InventoryType=Class'CSLinkNuke.CSLinkNuke'
     RespawnTime=60.000000
     PickupMessage="OH YEAAAHHHHHHHHHH"
     PickupSound=Sound'CSLinkNuke.ohyeah2'
     StaticMesh=StaticMesh'CSLinkNuke.RedeemerPickup'
}
