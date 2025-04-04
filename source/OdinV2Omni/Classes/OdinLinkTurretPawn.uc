/******************************************************************************
OdinLinkTurretPawn

Creation date: 2012-10-22 14:54
Last change: $Id$
Copyright � 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class OdinLinkTurretPawn extends OVHoverTankWeaponPawn CacheExempt;


var Pawn SwitchRequester;
var int NumSideSwitchConsiderations;


simulated function vector GetCameraLocationStart()
{
	return Location;
}


function ConsiderSwitchingSides(Pawn Bot)
{
	if (Bot != Self)
	{
		NumSideSwitchConsiderations = 0;
		SwitchRequester = None;
		SetTimer(0.0, false);
		return;
	}

	if (NumSideSwitchConsiderations++ > 10)
	{
		SwitchRequester = Driver;
		SetTimer(0.001, false);
	}
	else
	{
		SetTimer(0.25, false);
	}
}


function Timer()
{
	local int i;
	local Pawn OldDriver;

	NumSideSwitchConsiderations = 0;

	if (Driver != None && Driver == SwitchRequester && VehicleBase != None)
	{
		OldDriver = Driver;
		KDriverLeave(true);
		for (i = 0; i < VehicleBase.WeaponPawns.Length; i++)
		{
			if (VehicleBase.WeaponPawns[i] != Self && VehicleBase.WeaponPawns[i].Driver == None)
			{
				if (VehicleBase.WeaponPawns[i].TryToDrive(OldDriver))
					return;
			}
		}
		// failed to occupy another gunner seat, just take this one again
		if (OldDriver != None)
			TryToDrive(OldDriver);

		SwitchRequester = None;
	}
}

// From ACDualGatlingGunPAwn
function KDriverEnter(Pawn P)
{
    super.KDriverEnter(P);
    if (!VehicleBase.bDriving)
        VehicleBase.bDriving = true;
}

event bool KDriverLeave( bool bForceLeave )
{
    local bool b;
    b  = super.KDriverLeave(bForceLeave);
    if (b && VehicleBase.IsVehicleEmpty() )
        VehicleBase.bDriving = false;

    return b;

}

simulated function AttachDriver(Pawn P)
{
    local coords GunnerAttachmentBoneCoords;

    if (Gun == None)
        return;

    //ONSDualAttackCraft(VehicleBase).OutputThrust = 0;
    //ONSDualAttackCraft(VehicleBase).OutputStrafe = 0;
    //ONSDualAttackCraft(VehicleBase).OutputRise = 0;
    P.bHardAttach = True;
    GunnerAttachmentBoneCoords = Gun.GetBoneCoords(Gun.GunnerAttachmentBone);
    P.SetLocation(VehicleBase.Location);
    P.SetBase(VehicleBase);
    P.SetPhysics(PHYS_None);
    P.SetPhysics(PHYS_None);    // Do it twice to handle the bug.
    Gun.AttachToBone(P, Gun.GunnerAttachmentBone);
    P.SetRelativeLocation(DrivePos);
    P.SetRelativeRotation( DriveRot );

}
//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     GunClass=Class'OdinV2Omni.OdinLinkTurret'
     CameraBone="Object85"
     bDrawDriverInTP=False
     ExitPositions(0)=(Y=-250.000000,Z=100.000000)
     ExitPositions(1)=(Y=250.000000,Z=100.000000)
     ExitPositions(2)=(X=150.000000,Y=-250.000000,Z=100.000000)
     ExitPositions(3)=(X=150.000000,Y=250.000000,Z=100.000000)
     ExitPositions(4)=(X=-150.000000,Y=-250.000000,Z=100.000000)
     ExitPositions(5)=(X=-150.000000,Y=250.000000,Z=100.000000)
     EntryRadius=400.000000
     FPCamViewOffset=(Z=20.000000)
     TPCamDistance=100.000000
     TPCamLookat=(X=0.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in an Odin Link Turret"
     VehicleNameString="Odin Link Turret"
}
