class HeavyTankSecondaryPawn extends ONSWeaponPawn;



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

defaultproperties
{
     GunClass=Class'HeavyTankV2Omni.HeavyTankSecondary'
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
     VehiclePositionString="in a Heavy Goliath Missle turret"
     VehicleNameString="Heavy Goliath Missle Turret"
}
