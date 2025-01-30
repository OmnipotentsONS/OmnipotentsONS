class FireHoundRearGunPawn extends ONSWeaponPawn;

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
    PC.EndZoom();
}

function ShouldTargetMissile(Projectile P)
{
	if ( Bot(Controller) != None && Bot(Controller).Skill >= 5.0 )
	{
		if ( (Controller.Enemy != None) && Bot(Controller).EnemyVisible() && (Bot(Controller).Skill < 5) )
			return;
		ShootMissile(P);
	}
}

defaultproperties
{
     GunClass=Class'FireVehiclesV2Omni.FireHoundRearGun'
     //CameraBone="Object02"
     CameraBone="REARgunTURRET"
     bHasAltFire=False
     bDrawDriverInTP=False
     //DrivePos=(Z=130.000000)
     DrivePos=(X=-20.000000,Z=90.000000)
     ExitPositions(0)=(Y=-200.000000,Z=100.000000)
     ExitPositions(1)=(Y=200.000000,Z=100.000000)
     EntryRadius=130.000000
     //FPCamViewOffset=(X=10.000000,Z=30.000000)
     //TPCamDistance=300.000000
     //TPCamLookat=(X=-25.000000,Z=0.000000)
     //TPCamWorldOffset=(Z=120.000000)
     DriverDamageMult=0.000000
     FPCamViewOffset=(Z=50.000000)
     TPCamDistance=650.000000
     TPCamLookat=(X=0.000000)
     TPCamWorldOffset=(Z=50.000000)
     
     VehiclePositionString="in a FireHound rear turret"
     VehicleNameString="FireHound Rear Turret"
     
     
     
     
}
