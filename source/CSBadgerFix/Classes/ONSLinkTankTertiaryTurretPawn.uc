// ============================================================================
// Link Tank laser turret pawn.
// ============================================================================
class ONSLinkTankTertiaryTurretPawn extends ONSWeaponPawn;

// ============================================================================
// ============================================================================
simulated function vector GetCameraLocationStart()
{
	// Try to lock the TP view to the gun
	return Gun.Location;
}

// ============================================================================
// ============================================================================
function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoom();
}

// ============================================================================
// ============================================================================
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

// ============================================================================
// ============================================================================
simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}


// ============================================================================
// ============================================================================
function ShouldTargetMissile(Projectile P)
{
	if ( Bot(Controller) != None && Bot(Controller).Skill >= 5.0 )
	{
		if ( (Controller.Enemy != None) && Bot(Controller).EnemyVisible() && (Bot(Controller).Skill < 5) )
			return;
		ShootMissile(P);
	}
}

// ============================================================================

defaultproperties
{
     GunClass=Class'CSBadgerFix.ONSLinkTankTertiaryTurret'
     bHasAltFire=False
     CameraBone="rvGUNbody"
     bDrawDriverInTP=False
     DrivePos=(Z=130.000000)
     ExitPositions(0)=(Y=-200.000000,Z=100.000000)
     ExitPositions(1)=(Y=200.000000,Z=100.000000)
     EntryRadius=130.000000
     FPCamPos=(Z=60.000000)
     TPCamDistance=200.000000
     TPCamLookat=(X=0.000000)
     TPCamDistRange=(Max=600.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Link Tank laser turret"
     VehicleNameString="Link Tank 2.0 Laser Turret"
}
