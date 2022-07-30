/******************************************************************************
DracoRocketPackPawn

Creation date: 2013-04-28 09:20
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DracoRocketPackPawn extends ONSWeaponPawn CacheExempt;


var bool bTurnedOff;
var Pawn SwitchRequester;


simulated function String GetDebugName()
{
	return Name$" (build "$class'Draco'.default.Build$")";
}

function ChooseFireAt(Actor A)
{
	local Bot B;
	
	B = Bot(Controller);
	if (B != None && B.Skill + B.Tactics > 3 && VehicleBase != None && VehicleBase.Driver == None)
	{
		if (Projectile(A) != None || Pawn(A) != None && (Pawn(A).bCanFly || Vehicle(A) == None || !Vehicle(A).IsArtillery()))
		{
			SwitchRequester = Driver;
			SetTimer(0.1, False);
		}
	}
	Super.ChooseFireAt(A);
}

function ConsiderSwitchingSides()
{
	if (FRand() < 0.5)
	{
		SwitchRequester = Driver;
		SetTimer(0.25, false);
	}
}

function Timer()
{
	local int i;
	local Pawn OldDriver;

	if (Driver != None && Driver == SwitchRequester && VehicleBase != None)
	{
		OldDriver = Driver;
		KDriverLeave(true);
		
		// consider going back to an empty pilot seat
		if (VehicleBase.Driver == None && !Bot(Controller).EnemyVisible() && VehicleBase.TryToDrive(OldDriver))
			return;
		
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

simulated function TurnOff()
{
	bTurnedOff = True;
	if (DracoRocketPack(Gun) != None)
		DracoRocketPack(Gun).bTurnedOff = True;

	Super.TurnOff();
}

function KDriverEnter(Pawn P)
{
	Super.KDriverEnter(P);

	if (bTurnedOff)
		return;

	if (!VehicleBase.bDriving)
	{
		VehicleBase.bDriving = true;
		VehicleBase.DrivingStatusChanged();
	}
}

event bool KDriverLeave(bool bForceLeave)
{
	local bool result;

	result  = Super.KDriverLeave(bForceLeave);

	if (!bTurnedOff && result && VehicleBase.IsVehicleEmpty())
	{
		VehicleBase.bDriving = false;
		VehicleBase.DrivingStatusChanged();
	}

	return result;
}

simulated function AttachDriver(Pawn P)
{
	local coords GunnerAttachmentBoneCoords;

	if (Gun == None)
		return;

	ONSDualAttackCraft(VehicleBase).OutputThrust = 0;
	ONSDualAttackCraft(VehicleBase).OutputStrafe = 0;
	ONSDualAttackCraft(VehicleBase).OutputRise = 0;
	P.bHardAttach = True;
	GunnerAttachmentBoneCoords = Gun.GetBoneCoords(Gun.GunnerAttachmentBone);
	P.SetLocation(VehicleBase.Location);
	P.SetBase(VehicleBase);
	P.SetPhysics(PHYS_None);
	P.SetPhysics(PHYS_None);	// Do it twice to handle the bug. - what bug? o_O
	Gun.AttachToBone(P, Gun.GunnerAttachmentBone);
	P.SetRelativeLocation(DrivePos);
	P.SetRelativeRotation(DriveRot);

}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     GunClass=Class'FireVehiclesV2Omni.DracoRocketPack'
     CameraBone="GatlingGunAttach"
     bDrawDriverInTP=False
     bCanCarryFlag=False
     DrivePos=(Z=-5.000000)
     ExitPositions(0)=(X=-235.000000)
     ExitPositions(1)=(Y=165.000000)
     ExitPositions(2)=(Y=-165.000000)
     ExitPositions(3)=(Z=100.000000)
     EntryPosition=(X=-50.000000)
     EntryRadius=160.000000
     FPCamViewOffset=(X=10.000000,Z=30.000000)
     TPCamDistance=300.000000
     TPCamLookat=(X=-25.000000,Z=0.000000)
     TPCamWorldOffset=(Z=120.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Draco turret"
     VehicleNameString="Draco Napalm Rocket Turret"
}
