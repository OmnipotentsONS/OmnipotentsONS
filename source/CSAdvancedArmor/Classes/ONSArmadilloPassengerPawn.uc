//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSArmadilloPassengerPawn extends ONSWeaponPawn;


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
     GunClass=Class'CSAdvancedArmor.Weapon_ONSArmadilloPassenger'
     CameraBone="PlasmaGunBarrel"
     bDrawDriverInTP=False
     ExitPositions(0)=(Y=-300.000000,Z=100.000000)
     ExitPositions(1)=(Y=300.000000,Z=100.000000)
     EntryPosition=(X=40.000000,Y=50.000000,Z=-100.000000)
     EntryRadius=130.000000
     FPCamPos=(Z=20.000000)
     FPCamViewOffset=(Z=40.000000)
     TPCamDistance=350.000000
     TPCamLookat=(X=0.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="Armadillo Passenger"
     VehicleNameString="Armadillo Passenger"
}
