//-----------------------------------------------------------
//	Skaarj Viper Speedboat
//	Colt Wohlers (aka CMan)
//	Beta 4.0 (July 2/2004)
//-----------------------------------------------------------
class SkaarjViperFrontGunPawn extends ONSWeaponPawn;

simulated function AttachDriver(Pawn P)
{
    local coords GunnerAttachmentBoneCoords;

    if (Gun == None)
    	return;

    P.bHardAttach = True;

    GunnerAttachmentBoneCoords = VehicleBase.GetBoneCoords(Gun.GunnerAttachmentBone);
    P.SetLocation(GunnerAttachmentBoneCoords.Origin);

    P.SetPhysics(PHYS_None);

    VehicleBase.AttachToBone(P, Gun.GunnerAttachmentBone);
    P.SetRelativeLocation(DrivePos);
	P.SetRelativeRotation( DriveRot );
}

simulated function DetachDriver(Pawn P)
{
    if (Gun != None && P.AttachmentBone != '')
        Gun.DetachFromBone(P);
}

defaultproperties
{
     GunClass=Class'KopholusV2Omni.SkaarjViperFrontGun'
     bDesiredBehindView=False
     DrivePos=(X=45.000000,Y=-17.000000,Z=110.000000)
     ExitPositions(0)=(Y=165.000000,Z=100.000000)
     ExitPositions(1)=(Y=-165.000000,Z=100.000000)
     ExitPositions(2)=(Y=165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=-165.000000,Z=-100.000000)
     EntryPosition=(X=100.000000)
     EntryRadius=170.000000
     FPCamPos=(Z=20.000000)
     TPCamDistance=50.000000
     TPCamLookat=(X=0.000000,Z=50.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Viper's Front turret"
     VehicleNameString="Viper Front Turret"
}
