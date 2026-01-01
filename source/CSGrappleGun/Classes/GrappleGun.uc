class GrappleGun extends Weapon;

var GrappleGunBeacon GrappleGunBeacon;
//var() float     MaxCamDist;
//var() float AmmoChargeF;
//var int RepAmmo;
//var() float AmmoChargeMax;
//var() float AmmoChargeRate;
var globalconfig bool bPrevWeaponSwitch;
var xBombFlag Bomb;
//var bool bDrained;
var bool bBeaconDeployed; // meaningful for client
var bool bTeamSet;
var byte ViewBeaconVolume;
var float PreDrainAmmo;
var rotator TranslocRot;
var float TranslocScale, OldTime;

replication
{
    reliable if ( bNetOwner && (ROLE==ROLE_Authority) )
        GrappleGunBeacon;
}

function class<DamageType> GetDamageType()
{
	return class'DamTypeTelefrag';
}

function bool BotFire(bool bFinished, optional name FiringMode)
{
	return false;
}

/*
simulated function bool HasAmmo()
{
    return true;
}

function bool ConsumeAmmo(int mode, float load, optional bool bAmountNeededIsMax)
{
	return true;
}

function ReduceAmmo()
{
	enable('Tick');
	bDrained = false;
    AmmoChargeF -= 1;
    RepAmmo -= 1;
}

simulated function GetAmmoCount(out float MaxAmmoPrimary, out float CurAmmoPrimary)
{
	MaxAmmoPrimary = AmmoChargeMax;
	CurAmmoPrimary = FMax(0,AmmoChargeF);
}

function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
    Super.GiveAmmo(m, WP,bJustSpawned);
    AmmoChargeF = Default.AmmoChargeF;
    RepAmmo = int(AmmoChargeF);
}

function DrainCharges()
{
	enable('Tick');
	PreDrainAmmo = AmmoChargeF;
	AmmoChargeF = -1;
	RepAmmo = -1;
	bDrained = true;
}
*/

simulated function bool StartFire(int Mode)
{
	if ( !bPrevWeaponSwitch || (Mode == 1) || (Instigator.Controller.bAltFire == 0) || (PlayerController(Instigator.Controller) == None) )
		return Super.StartFire(Mode);
	if ( (OldWeapon != None) && OldWeapon.HasAmmo() )
	    Instigator.PendingWeapon = OldWeapon;
	ClientStopFire(0);
	Instigator.Controller.StopFiring();
	PutDown();
    return false;
}

/*
simulated function Tick(float dt)
{
    if (Role == ROLE_Authority)
    {
		if ( AmmoChargeF >= AmmoChargeMax )
		{
			if ( RepAmmo != int(AmmoChargeF) ) // condition to avoid unnecessary bNetDirty of ammo
				RepAmmo = int(AmmoChargeF);
			disable('Tick');
			return;
		}
		AmmoChargeF += dt*AmmoChargeRate;
		AmmoChargeF = FMin(AmmoChargeF, AmmoChargeMax);
		if ( AmmoChargeF >= 1.5 )
			bDrained = false;

        if ( RepAmmo != int(AmmoChargeF) ) // condition to avoid unnecessary bNetDirty of ammo
			RepAmmo = int(AmmoChargeF);
    }
    else
    {
        // client simulation of the charge bar
        AmmoChargeF = FMin(RepAmmo + AmmoChargeF - int(AmmoChargeF)+dt*AmmoChargeRate, AmmoChargeMax);
    }
}
*/

simulated function DoAutoSwitch()
{
}

simulated function Destroyed()
{
    if (GrappleGunBeacon != None)
        GrappleGunBeacon.Destroy();
    Super.Destroyed();
}

/*
simulated function float ChargeBar()
{
	return AmmoChargeF - int(AmmoChargeF);
}
*/

defaultproperties
{
    //MaxCamDist=4000.000000
    //AmmoChargeF=6.000000
    //RepAmmo=6
    //AmmoChargeMax=6.000000
    //AmmoChargeRate=0.400000
    bPrevWeaponSwitch=True
    ViewBeaconVolume=40
    TranslocScale=1.000000
    FireModeClass(0)=Class'GrappleGunFire'
    FireModeClass(1)=Class'GrappleGunAltFire'
    PutDownAnim="PutDown"
    IdleAnimRate=0.250000
    SelectSound=Sound'WeaponSounds.Misc.translocator_change'
    SelectForce="Translocator_change"
    AIRating=-1.000000
    CurrentRating=-1.000000
    bShowChargingBar=False
    bCanThrow=True
    EffectOffset=(X=100.000000,Y=30.000000,Z=-19.000000)
    DisplayFOV=60.000000
    HudColor=(B=0,G=255,R=255)
    SmallViewOffset=(X=38.000000,Y=16.000000,Z=-16.000000)
    CenteredOffsetY=0.000000
    CenteredRoll=0
    CustomCrosshair=9
    CustomCrossHairColor=(G=0,R=0)
    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross3"
    Priority=6
    InventoryGroup=2
    GroupOffset=1
    PickupClass=Class'GrappleGunPickup'
    PlayerViewOffset=(X=28.500000,Y=12.000000,Z=-12.000000)
    PlayerViewPivot=(Pitch=1000,Yaw=400)
    BobDamping=1.800000
    AttachmentClass=Class'GrappleGunAttachment'
    IconMaterial=Texture'HUDContent.Generic.HUD'
    IconCoords=(X1=22,Y1=360,X2=95,Y2=395)
    ItemName="Grapple Gun"
    Description="The Grapple gun was originally designed by Liandri Corporation's R&D sector to facilitate the rapid recall of miners during tunnel collapses. However, rapid deresolution and reconstitution can have several unwelcome effects, including increases in aggression and paranoia.||In order to prolong the careers of today's contenders, limits have been placed on Translocator use in the lower-ranked leagues. The latest iteration of the Translocator features a remotely operated camera, exceptionally useful when scouting out areas of contention.|It should be noted that while viewing the camera's surveillance output, the user is effectively blind to their immediate surroundings."
    Mesh=SkeletalMesh'Weapons.BallLauncher_1st'
    DrawScale=0.400000
}