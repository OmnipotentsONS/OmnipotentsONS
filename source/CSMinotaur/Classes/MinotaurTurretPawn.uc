class MinotaurTurretPawn extends ONSWeaponPawn;

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

function ShouldTargetMissile(Projectile P)
{
	if ( Bot(Controller) != None && Bot(Controller).Skill >= 5.0 )
	{
		if ( (Controller.Enemy != None) && Bot(Controller).EnemyVisible() && (Bot(Controller).Skill < 5) )
			return;
		ShootMissile(P);
	}
}

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

defaultproperties
{
     GunClass=Class'CSMinotaur.Minotaurturret'
     bHasAltFire=False
     CameraBone="Object02"
     bDrawDriverInTP=False
     DrivePos=(Z=130.000000)
     ExitPositions(0)=(Y=-200.000000,Z=100.000000)
     ExitPositions(1)=(Y=200.000000,Z=100.000000)
     EntryRadius=130.000000
     FPCamViewOffset=(X=10.000000,Z=30.000000)
     TPCamDistance=300.000000
     TPCamLookat=(X=-25.000000,Z=0.000000)
     TPCamWorldOffset=(Z=120.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Min)o(taur turret"
     VehicleNameString="Min)o(taur Minigun Turret"
}
