//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WeaponPawn_Passenger extends APWeaponPawn;


function KDriverEnter(Pawn P)
{
	Super.KDriverEnter(P);
    Driver.CreateInventory("CSAPVerIV.edo_ChuteInv");
}

defaultproperties
{
     GunClass=Class'CSAPVerIV.Weapon_Passenger'
     CameraBone="PlasmaGunBarrel"
     bDrawDriverInTP=False
     DrivePos=(Z=130.000000)
     ExitPositions(0)=(Y=-200.000000,Z=100.000000)
     ExitPositions(1)=(Y=200.000000,Z=100.000000)
     EntryPosition=(X=40.000000,Y=50.000000,Z=-100.000000)
     EntryRadius=130.000000
     FPCamPos=(Z=84.000000)
     FPCamViewOffset=(X=-64.000000,Z=84.000000)
     TPCamDistance=100.000000
     TPCamLookat=(X=-64.000000,Z=84.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="Passenger"
     VehicleNameString="Passenger"
}
