// AVRiL alternate fire. Slight zoom and auto-tracking of target
class ONSAVRiLMKIIAltFire extends WeaponFire;

var ONSAVRiLMKII Gun;
var float ZoomLevel;
var bool bWaitingForRelease;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Gun = ONSAVRiLMKII(Weapon);
}

simulated function bool AllowFire()
{
	//return (Gun != None && Gun.bLockedOn && PlayerController(Instigator.Controller) != None);
	if (bWaitingForRelease || Gun == None || !Gun.bLockedOn || PlayerController(Instigator.Controller) == None)
	{
		bWaitingForRelease = true;
		return false;
	}
	else
		return true;

}

function StopFiring()
{
	if (PlayerController(Instigator.Controller) != None)
	{
		ZoomLevel = 0.0;
		PlayerController(Instigator.Controller).DesiredFOV = PlayerController(Instigator.Controller).DefaultFOV;

	}
}

function PlayFiring() {}

function ModeTick(float deltaTime)
{
	//Hack - force player to actually press button to start fire (so can't hold down button and sweep crosshair in the vicinity of targets)
	if (bWaitingForRelease && PlayerController(Instigator.Controller).bAltFire == 0)
		bWaitingForRelease = false;

	if (!bIsFiring)
		return;



	//Custom zooming because we don't want quite as much as normal sniper zoom does
	ZoomLevel += deltaTime;
	if (ZoomLevel > 0.60)
		ZoomLevel = 0.60;
	PlayerController(Instigator.Controller).DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);


}

defaultproperties
{
     bModeExclusive=False
     FireRate=0.100000
}
