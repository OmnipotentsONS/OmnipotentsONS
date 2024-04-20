//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HospitalerRearGunPawn extends ONSWeaponPawn;

function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoom();
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if (!bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	PC.StopZoom();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}

defaultproperties
{
     GunClass=Class'HospitalerV3Omni.HospitalerRearGun'
     bHasAltFire=False
     CameraBone="REARgunTURRET"
     bDrawDriverInTP=False
     DriverDamageMult=0.000000
     DrivePos=(X=-20.000000,Z=90.000000)
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryPosition=(X=-50.000000)
     EntryRadius=500.000000
     FPCamViewOffset=(Z=40.000000)
     TPCamDistance=600.899780
     TPCamLookat=(X=0.000000)
     TPCamWorldOffset=(Z=50.000000)

     VehiclePositionString="in a Hospitaler's anti-air turret"
     VehicleNameString="Hospitaler AA Turret"
     bSelected=True
}
