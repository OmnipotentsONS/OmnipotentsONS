//class CSLinkNuke extends Redeemer;
class CSLinkNuke extends Weapon
	config(user);

#exec OBJ LOAD FILE="Animations\CSLinkNukeAnimations.ukx" PACKAGE=CSLinkNuke
#exec OBJ LOAD FILE="StaticMeshes\CSLinkNukeMeshes.usx" PACKAGE=CSLinkNuke

var() bool bHealNodes;
var() int NodeHealRate;
var() float NodeHealDuration;

var() bool bHealPlayers;
var() int PlayerHealRate;
var() float PlayerHealDuration;
var() int PlayerHealMax;

var() bool bHealVehicles;
var() int VehicleHealRate;
var() float VehicleHealDuration;
var() int VehicleHealMax;

var() bool bFlipNodes;
var() int NodeDamage;

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheMaterial(Material'XEffectMat.Shield.RedShield');
	L.AddPrecacheMaterial(Material'XEffectMat.Shield.BlueShield');

}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Material'XEffectMat.Shield.RedShield');
	Level.AddPrecacheMaterial(Material'XEffectMat.Shield.BlueShield');
	super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	super.UpdatePrecacheStaticMeshes();
	Level.AddPrecacheStaticMesh(StaticMesh'CSLinkNuke.RedeemerPickup');
	Level.AddPrecacheStaticMesh(StaticMesh'CSLinkNuke.RedeemerMissile');
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	bFlipNodes = class'MutUseLinkNuke'.default.bFlipNodes;

	bHealPlayers = class'MutUseLinkNuke'.default.bHealPlayers;
	PlayerHealRate = class'MutUseLinkNuke'.default.PlayerHealRate;
	PlayerHealDuration = class'MutUseLinkNuke'.default.PlayerHealRate;
	PlayerHealMax = class'MutUseLinkNuke'.default.PlayerHealMax;

	bHealVehicles = class'MutUseLinkNuke'.default.bHealVehicles;
	VehicleHealRate = class'MutUseLinkNuke'.default.VehicleHealRate;
	VehicleHealDuration = class'MutUseLinkNuke'.default.VehicleHealDuration;
	VehicleHealMax = class'MutUseLinkNuke'.default.VehicleHealMax;
}

simulated function SuperMaxOutAmmo()
{
}

defaultproperties
{
     FireModeClass(0)=Class'CSLinkNuke.CSLinkNukeFire'
     FireModeClass(1)=Class'CSLinkNuke.CSLinkNukeFire'
     SelectAnim="Pickup"
     PutDownAnim="PutDown"
     SelectAnimRate=0.667000
     PutDownAnimRate=1.000000
     PutDownTime=0.450000
     BringUpTime=0.675000
     SelectSound=Sound'WeaponSounds.Misc.redeemer_change'
     SelectForce="SwitchToFlakCannon"
     AIRating=1.500000
     CurrentRating=1.500000
     Description="YEAAAHHHHHHHHHHH Nuke 2.2"
     DisplayFOV=60.000000
     Priority=16
     SmallViewOffset=(X=26.000000,Y=6.000000,Z=-34.000000)
     CustomCrosshair=13
     CustomCrossHairColor=(B=128)
     CustomCrossHairScale=2.000000
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Circle2"
     InventoryGroup=0
     GroupOffset=1
     PickupClass=Class'CSLinkNuke.CSLinkNukePickup'
     PlayerViewOffset=(X=14.000000,Z=-28.000000)
     PlayerViewPivot=(Pitch=1000,Yaw=-400)
     BobDamping=1.400000
     AttachmentClass=Class'CSLinkNuke.CSLinkNukeAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=4,Y1=350,X2=110,Y2=395)
     ItemName="YEAAAHHHHHHHHHH Nuke 2.2"
     Mesh=SkeletalMesh'CSLinkNuke.Redeemer_1st'
     DrawScale=1.200000

	bHealNodes=True
	NodeHealRate=150
	NodeHealDuration=5.0
	bFlipNodes=True

	bHealPlayers=True
	PlayerHealRate=10
	PlayerHealDuration=5.0
	PlayerHealMax=199

	bHealVehicles=True
	VehicleHealRate=100
	VehicleHealDuration=5.0
	VehicleHealMax=800
}
