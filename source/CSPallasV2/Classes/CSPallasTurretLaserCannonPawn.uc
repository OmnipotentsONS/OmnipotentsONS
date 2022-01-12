class CSPallasTurretLaserCannonPawn extends ONSWeaponPawn;

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

/*
simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector CamLookAt, HitLocation, HitNormal, OffsetVector;
	local Actor HitActor;
    local vector x, y, z;
    local rotator fixedRotation;

	if (DesiredTPCamDistance < TPCamDistance)
		TPCamDistance = FMax(DesiredTPCamDistance, TPCamDistance - CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));
	else if (DesiredTPCamDistance > TPCamDistance)
		TPCamDistance = FMin(DesiredTPCamDistance, TPCamDistance + CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));

    GetAxes(PC.Rotation, x, y, z);
	ViewActor = self;
	CamLookAt = GetCameraLocationStart() + (TPCamLookat >> Rotation) + TPCamWorldOffset;

	OffsetVector = vect(0, 0, 0);
	OffsetVector.X = -1.0 * TPCamDistance;

	CameraLocation = CamLookAt + (OffsetVector >> PC.Rotation);

	HitActor = Trace(HitLocation, HitNormal, CameraLocation, CamLookAt, true, vect(40, 40, 40));
	if ( HitActor != None
	     && (HitActor.bWorldGeometry || HitActor == GetVehicleBase() || Trace(HitLocation, HitNormal, CameraLocation, CamLookAt, false, vect(40, 40, 40)) != None) )
			CameraLocation = HitLocation;

    // no stupid roll
    fixedRotation = PC.ShakeRot;
    fixedRotation.Pitch = 0;
    //CameraRotation = Normalize(PC.Rotation + PC.ShakeRot);
    CameraRotation = Normalize(PC.Rotation + fixedRotation);
    CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}
*/

defaultproperties
{
     GunClass=Class'CSPallasV2.CSPallasTurretLaserCannon'
     bHasAltFire=False
     CameraBone="Object02"
     bDrawDriverInTP=False
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryPosition=(Z=-150.000000)
     EntryRadius=130.000000
     FPCamViewOffset=(X=5.000000,Z=35.000000)
     TPCamDistance=100.000000
     TPCamLookat=(X=0.000000,Z=110.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Pallas laser turret"
     VehicleNameString="Pallas laser Turret"
}
