//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WeaponPawn_PredatorPassenger extends ONSWeaponPawn;


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
     bCanCarryFlag=False
     DrivePos=(Z=-5.000000)
     ExitPositions(0)=(X=-235.000000)
     ExitPositions(1)=(Y=165.000000)
     ExitPositions(2)=(Y=-165.000000)
     ExitPositions(3)=(Z=100.000000)
     EntryPosition=(X=-50.000000)
     EntryRadius=160.000000
     FPCamPos=(X=35.000000,Z=15.000000)
     TPCamDistance=0.000000
     TPCamLookat=(X=5.000000,Z=-50.000000)
     TPCamDistRange=(Min=0.000000,Max=0.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="Predator Passenger"
     VehicleNameString="Predator Passenger"
}
