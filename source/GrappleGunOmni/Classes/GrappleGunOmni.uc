class GrappleGunOmni extends LinkGun;

//#exec TEXTURE IMPORT name=GrappleGunTex file=Textures/GrappleGunTex.dds

simulated function UpdateLinkColor( LinkAttachment.ELinkColor Color );

simulated function bool HasAmmo()
{
	return true;
}

simulated function bool StartFire(int Mode)
{
	return Super(Weapon).StartFire(Mode);
}

// Bots won't know how to use these properly
function bool FocusOnLeader(bool bLeaderFiring)
{
	return false;
}
function byte BestMode()
{
	return 0;
}
function float SuggestAttackStyle()
{
	return 0;
}
function float SuggestDefenseStyle()
{
    return 0;
}

// Infinite ammo, don't consume it
simulated function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
	return true;
}
function bool LinkedConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
	return true;
}

defaultproperties
{
     FireModeClass(0)=Class'GrappleGunOmni.GrappleGunOmniFire'
     FireModeClass(1)=Class'GrappleGunOmni.GrappleGunOmniFire'
     AIRating=0.000000
     CurrentRating=0.000000
     Description="Hitch a ride by linking to a friendly vehicle!"
     Priority=1
     PickupClass=Class'GrappleGunOmni.GrappleGunOmniPickup'
     ItemName="Grapple Gun Omni 1.0"
     Skins(0)=Shader'GrappleGunOmni_Tex.GrappleGunOmni.GrappleGunShader'
     InventoryGroup=2
}
