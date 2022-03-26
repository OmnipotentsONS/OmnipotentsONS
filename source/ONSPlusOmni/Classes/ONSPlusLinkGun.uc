// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusLinkGun extends LinkGun;

var array<pawn> LockingPawns;

// Priority fix
simulated function PostBeginPlay()
{
	if (Level.Netmode != NM_DedicatedServer)
	{
		Class'ONSPlusLinkGun'.default.Priority = Class'LinkGun'.default.Priority;
		CustomCrosshair = Class'LinkGun'.default.CustomCrosshair;
		CustomCrosshairColor = Class'LinkGun'.default.CustomCrosshairColor;
		CustomCrosshairScale = Class'LinkGun'.default.CustomCrosshairScale;
		CustomCrosshairTextureName = Class'LinkGun'.default.CustomCrosshairTextureName;
		SaveConfig();
	}

	Super.PostBeginPlay();
}

defaultproperties
{
	PickupClass=class'ONSPlusLinkGunPickup'
	FireModeClass(0)=ONSPlusLinkAltFire
	FireModeClass(1)=ONSPlusLinkFire
}