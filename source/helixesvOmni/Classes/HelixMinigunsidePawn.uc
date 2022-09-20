class HelixMinigunsidePawn extends ONSWeaponPawn;


//========================================================================
// this code enables the hover mode
function KDriverEnter(Pawn P)
{
	super.KDriverEnter(P);
	 Driver.CreateInventory("APVerIV.edo_ChuteInv");
	// Give the Gunner a chute!
	
	if (!VehicleBase.bDriving)
		VehicleBase.bDriving = true;
	
	
}

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
     GunClass=Class'helixesvOmni.HelixMinigunside'
     bHasAltFire=False
     CameraBone="CameraB"
     bDesiredBehindView=False
     ExitPositions(0)=(Y=-200.000000,Z=100.000000)
     ExitPositions(1)=(Y=200.000000,Z=100.000000)
     EntryRadius=130.000000
     FPCamViewOffset=(Z=7.000000)
     TPCamDistance=0.000000
     TPCamLookat=(X=2.500000,Z=3.000000)
     TPCamWorldOffset=(Z=80.000000)
     DriverDamageMult=0.100000
     VehiclePositionString="in a Helix Minigun turret"
     VehicleNameString="Helix Minigun turret"
}
