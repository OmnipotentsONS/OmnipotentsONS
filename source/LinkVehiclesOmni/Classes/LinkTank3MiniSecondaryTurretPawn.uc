// ============================================================================
// Link Tank gunner turret pawn.
// ============================================================================
class LinkTank3MiniSecondaryTurretPawn extends ONSWeaponPawn;

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

simulated function DrawHUD(Canvas C)
{
	local PlayerController PC;
	local HudCTeamDeathMatch PlayerHud;

	//Hax. :P
    Super.DrawHUD(C);
	PC = PlayerController(Controller);
	if (VehicleBase.Health < 1 || PC == None || PC.myHUD == None || PC.MyHUD.bShowScoreboard)
		return;
		
	PlayerHud=HudCTeamDeathMatch(PC.MyHud);
	// moved to tick If (VehicleBase.Owner == None) LinkTank3(VehicleBase).ResetLinks();  // this doesn't get called unless Tank has owner (its in tick), only need this in turrets
	if ( LinkTank3Mini(VehicleBase).Links > 0 )
	{
		PlayerHud.totalLinks.value = LinkTank3(VehicleBase).Links;
		PlayerHud.DrawSpriteWidget (C, PlayerHud.LinkIcon);
		PlayerHud.DrawNumericWidget (C, PlayerHud.totalLinks, PlayerHud.DigitsBigPulse);
		PlayerHud.totalLinks.value = LinkTank3(VehicleBase).Links;
	}
}


// ============================================================================
// Tick
// Remove linkers from the linker list after they stop linking
// ============================================================================
simulated event Tick(float DT)
{
	Super.Tick( DT );
	 // this doesn't get called unless Tank has owner (its in tick), only need this in turrets so if no driver link count updates.
 	if (Role == ROLE_Authority && VehicleBase != None && VehicleBase.Owner == None)  LinkTank3Mini(VehicleBase).ResetLinks();
}

defaultproperties
{
     GunClass=Class'LinkVehiclesOmni.LinkTank3MiniSecondaryTurret'
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
     VehiclePositionString="in a Link Tank Mini Plasma turret"
     VehicleNameString="Link Tank Mini Plasma Turret"
}
