//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FireBladeOmniTopTurretPawn extends ONSWeaponPawn;

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


function KDriverEnter(Pawn P)
{
	super.KDriverEnter(P);
  // following allows flyers to hover even if there's no driver!
	// pooty 02/2024
	if (!VehicleBase.bDriving)
		VehicleBase.bDriving = true;
}



defaultproperties
{
     GunClass=Class'FireBladeOmni.FireBladeOmniTopTurret'
     bHasAltFire=False
     CameraBone="GunFire"
     bDrawDriverInTP=False
     bDesiredBehindView=False
     DrivePos=(X=-1.750000,Z=8.000000)
     ExitPositions(0)=(X=-235.000000)
     ExitPositions(1)=(Y=165.000000)
     ExitPositions(2)=(Y=-165.000000)
     ExitPositions(3)=(Z=100.000000)
     EntryPosition=(X=-50.000000)
     EntryRadius=180.000000
     FPCamViewOffset=(Z=40.000000)
     TPCamDistance=1500.000000
     TPCamLookat=(X=50.000000)
     TPCamWorldOffset=(Z=100.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a FireBlade Beam Turret"
     VehicleNameString="FireBlade Beam Turret"
}
