//-----------------------------------------------------------
//  For Karma Class DropShip
//-----------------------------------------------------------
class WeaponPawn_DropShipPassenger extends ONSWeaponPawn;


function KDriverEnter(Pawn P)
{
	Super.KDriverEnter(P);
    Driver.CreateInventory("CSAPVerIV.edo_ChuteInv");
}

simulated function bool PointOfView()
{
    return false;
}

function int LimitPitch(int pitch)
{
    return pitch;
}

/*
function bool PlaceExitingDriver()
{
    return true;
}
*/

defaultproperties
{
     GunClass=Class'CSAPVerIV.Weapon_DropShipPassenger'
     CameraBone="PlasmaGunBarrel"
     DrivePos=(Z=16.000000)
     ExitPositions(0)=(X=-856.000000,Y=-64.000000)
     ExitPositions(1)=(X=-856.000000,Y=64.000000)
     ExitPositions(2)=(X=-956.000000,Y=-64.000000)
     ExitPositions(3)=(X=-956.000000,Y=64.000000)
     EntryPosition=(X=-256.000000)
     EntryRadius=130.000000
     //FPCamPos=(Z=64.000000)
     FPCamPos=(Z=0.000000)
     //FPCamViewOffset=(X=-64.000000,Z=84.000000)
     FPCamViewOffset=(X=0.000000,Z=0.000000)
     //TPCamDistance=100.000000
     //TPCamLookat=(X=-64.000000,Z=84.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="Passenger"
     VehicleNameString="Passenger"
     bAllowViewChange=false
}
