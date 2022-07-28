class CSDarkLeviFlakTurretPawn extends ONSWeaponPawn;

simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    // no stupid roll
    if(Abs(PC.ShakeRot.Pitch) >= 16384)
    {
        PC.bEnableAmbientShake = false;
        PC.StopViewShaking();
        PC.ShakeOffset = vect(0,0,0);
        PC.ShakeRot = rot(0,0,0);
    }

    super.SpecialCalcBehindView(PC, ViewActor, CameraLocation, CameraRotation);
}

DefaultProperties
{
	VehiclePositionString="in a Dark Leviathan flak turret"
	VehicleNameString="Dark Leviathan Flak Turret"
	EntryPosition=(X=0,Y=0,Z=-150)
	EntryRadius=130.0
	ExitPositions(0)=(X=0,Y=-365,Z=200)
	ExitPositions(1)=(X=0,Y=365,Z=200)
	ExitPositions(2)=(X=0,Y=-365,Z=-100)
	ExitPositions(3)=(X=0,Y=365,Z=-100)
	GunClass=class'CSDarkLeviFlakTurret'
	CameraBone=Object83
	FPCamPos=(X=0,Y=0,Z=0)
	FPCamViewOffset=(X=5,Y=0,Z=35)
	bFPNoZFromCameraPitch=False
	TPCamLookAt=(X=0,Y=0,Z=110)
	TPCamDistance=100
	DriverDamageMult=0.0
	bDrawDriverInTP=False
}
