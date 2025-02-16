class GrappleGunOmni extends Weapon;

//#exec TEXTURE IMPORT name=GrappleGunTex file=Textures/GrappleGunTex.dds

#exec OBJ LOAD FILE=GrappleGunOmni_Tex.utx

var() int Links;
var() bool Linking;

replication
{
    unreliable if (Role == ROLE_Authority)
        Linking, Links;
}


simulated function bool HasAmmo()
{
	return true;
}

simulated function UpdateLinkColor( GrappleGunOmniAttachment.ELinkColor Color );


simulated function vector GetEffectStart()
{
    local Vector X,Y,Z, Offset;
    local float Extra;

    // 1st person
    if ( Instigator.IsFirstPerson() )
    {
        if ( WeaponCentered() )
            return CenteredEffectStart();

        GetViewAxes(X, Y, Z);
        if ( class'PlayerController'.Default.bSmallWeapons )
            Offset = SmallEffectOffset;
        else
            Offset = EffectOffset;

        if ( Hand == 0 )
        {
            if ( bUseOldWeaponMesh )
                Offset.Z -= 10;
            else
                Offset.Z -= 14;
            Extra = 3;
        }
        else if ( !bUseOldWeaponMesh )
            Offset.Z -= 10;

        return (Instigator.Location +
                Instigator.CalcDrawOffset(self) +
                Offset.X * X  +
                (Offset.Y * Hand + Extra) * Y +
                Offset.Z * Z);
    }
    // 3rd person
    else
    {
        return (Instigator.Location +
            Instigator.EyeHeight*Vect(0,0,0.5) +
            Vector(Instigator.Rotation) * 40.0);
    }
}

// Bots won't know how to use these properly
function bool FocusOnLeader(bool bLeaderFiring)
{
	return false;
}

function float GetAIRating()
{
	return 0;
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

function bool CanHeal(Actor Other)
{
       return false;
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
     Description="Hitch a ride by linking to a vehicle!"
     Priority=20
     PickupClass=Class'GrappleGunOmni.GrappleGunOmniPickup'
     ItemName="GrappleGun Omni 1.03 (NOT LINK!)"
     Skins(0)=Shader'GrappleGunOmni_Tex.GrappleGunOmni.GrappleGunShader'
     InventoryGroup=6 // wanted this in 2, but prev/next doesn't work in 2 which makes no sense -- nothing in next/prev makes 2 any different, it works fine in ANY other slot
     GroupOffset=2
     Mesh=SkeletalMesh'NewWeapons2004.FatLinkGun'
     AttachmentClass=Class'GrappleGunOmni.GrappleGunOmniAttachment'
     SelectSound=Sound'WeaponSounds.Misc.translocator_change'
     SelectForce="Translocator_change"


// From LinkGun Defaults..
     PutDownAnim="PutDown"
     IdleAnimRate=0.030000
//     SelectSound=Sound'NewWeaponSounds.NewLinkSelect'
//     SelectForce="SwitchToLinkGun"

     OldMesh=SkeletalMesh'Weapons.LinkGun_1st'
     OldPickup="WeaponStaticMesh.LinkGunPickup"
     OldCenteredOffsetY=-12.000000
     OldPlayerViewOffset=(X=-2.000000,Y=-2.000000,Z=-3.000000)
     OldSmallViewOffset=(X=10.000000,Y=4.000000,Z=-9.000000)
     OldPlayerViewPivot=(Yaw=500)
     OldCenteredRoll=3000
     OldCenteredYaw=-300
     EffectOffset=(X=100.000000,Y=25.000000,Z=-3.000000)
     DisplayFOV=60.000000
     HudColor=(B=128,R=128)
     SmallViewOffset=(X=2.000000,Z=-1.500000)
     CenteredOffsetY=-5.000000
     CenteredRoll=3000
     CenteredYaw=-1000
     CustomCrosshair=10
     CustomCrossHairColor=(B=128,R=128)
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Bracket1"
     PlayerViewOffset=(X=-5.000000,Y=-3.000000)
     PlayerViewPivot=(Yaw=500)
     BobDamping=1.575000
     //AttachmentClass=Class'XWeapons.LinkAttachment'
     //IconMaterial=Texture'HUDContent.Generic.HUD'
     IconMaterial=Texture'GrappleGunOmni_Tex.HUD.GrappleHUD'
     //IconCoords=(X1=169,Y1=78,X2=244,Y2=124)
     //IconCoords=(X1=6,Y1=1,X2=69,Y2=45)
     IconCoords=(X1=16,Y1=10,X2=79,Y2=35)
     //IconCoords=(X1=6,Y1=5,X2=81,Y2=51)
     //Mesh=SkeletalMesh'NewWeapons2004.FatLinkGun'
     
}
