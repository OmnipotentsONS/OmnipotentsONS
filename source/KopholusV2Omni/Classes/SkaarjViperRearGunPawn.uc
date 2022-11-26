//-----------------------------------------------------------
//	Skaarj Viper Speedboat
//	Colt Wohlers (aka CMan)
//	Beta 4.0 (July 2/2004)
//-----------------------------------------------------------

class SkaarjViperRearGunPawn extends ONSWeaponPawn;

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
     GunClass=Class'KopholusV2Omni.SkaarjViperRearGun'

     bHasAltFire=False
     CameraBone="VTFire"
     bDrawDriverInTP=False
     DrivePos=(X=-37.000000,Y=-17.000000,Z=69.000000)
     ExitPositions(0)=(Z=100.000000)
     EntryPosition=(X=-50.000000)
     EntryRadius=170.000000
     TPCamDistance=400.000000
     TPCamLookat=(X=0.000000,Z=45.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Viper's Rear turret"
     VehicleNameString="Viper Rear Turret"
}
