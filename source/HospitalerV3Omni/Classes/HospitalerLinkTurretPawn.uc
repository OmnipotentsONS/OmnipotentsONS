class HospitalerLinkTurretPawn extends ONSWeaponPawn;
// ============================================================================
// Link  turret pawn.
// ============================================================================

simulated function vector GetCameraLocationStart()
{
	// Try to lock the TP view to the gun
	return Gun.Location;
}


// Don't allow primary fire if beaming
/*function Fire(optional float F)
{
	//if (!Gun.bBeaming)
		Super.Fire(F);
}
*/
// ============================================================================
// C/P'd Ion Tank stuff
// ============================================================================
/*function AltFire(optional float F)
{
	super(ONSWeaponPawn).AltFire( F );
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	//log(self@"ClientVehicleCeaseFire, alt="@bWasAltFire,'VampireTank');
	super(ONSWeaponPawn).ClientVehicleCeaseFire( bWasAltFire );
}
*/

/* WHY DO WE NEEDTHIS, Wraith doesn't have it, but here it won't stop firing without it */
function VehicleCeaseFire(bool bWasAltFire)
{
	  //log(self@"VehicleCeaseFire, alt="@bWasAltFire,'VampireTank');
    Super.VehicleCeaseFire(bWasAltFire);
    if (Gun != None)
    {
    	//  log(self@"Callling Gun.CeaseFire, alt="@bWasAltFire,'VampireTank');
        Gun.CeaseFire(Controller);
        Gun.WeaponCeaseFire(Controller, bWasAltFire);  // this doesn't seem to get called by default? WTF.
    }
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

	//log("HospitalerV3OmnSecondTurret:DrawHUD");
	//log("HospitalerV3OmnSecondTurret:DrawHUD VehicleBase="$VehicleBase);
    Super.DrawHUD(C);
	PC = PlayerController(Controller);
	//log("HospitalerV3OmnSecondTurret:DrawHUD PC="$PC);
	if (VehicleBase.Health < 1 || PC == None || PC.myHUD == None || PC.MyHUD.bShowScoreboard)
		return;
		
	PlayerHud=HudCTeamDeathMatch(PC.MyHud);
	
	//log("HospitalerV3OmnSecondTurret:DrawHUD PlayerHud="$PlayerHud);
	
	
	//log("HospitalerV3OmnSecondTurret:DrawHUD Links="$HospitalerV3Omni(VehicleBase).Links);
	if ( HospitalerV3Omni(VehicleBase).Links > 0 )
	{
		PlayerHud.totalLinks.value = HospitalerV3Omni(VehicleBase).Links;
		PlayerHud.DrawSpriteWidget (C, PlayerHud.LinkIcon);
		PlayerHud.DrawNumericWidget (C, PlayerHud.totalLinks, PlayerHud.DigitsBigPulse);
		PlayerHud.totalLinks.value = HospitalerV3Omni(VehicleBase).Links;
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
  if (VehicleBase.Owner == None && Role == ROLE_Authority)  HospitalerV3Omni(VehicleBase).ResetLinks(); 
}


defaultproperties
{
     //linkweaponcheck=Class'HospitalerV3Omni.LinkTWeapon'
     //DefaultWeaponClassName="HospitalerV3Omni.HospitilarLinkTW"
     GunClass=Class'HospitalerV3Omni.HospitalerLinkTurret'
     bHasAltFire=True
     CameraBone="("
     bDrawDriverInTP=False
     DriverDamageMult=0.000000
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryPosition=(X=40.000000,Y=50.000000,Z=-100.000000)
     EntryRadius=500.000000
     //FPCamPos=(Z=20.000000)
     //TPCamDistance=500.000000
     //TPCamLookat=(X=0.000000)
     FPCamPos=(X=25.000000,Z=140.000000)
     TPCamDistance=600.000000
     TPCamLookat=(X=0.000000,Z=140.000000)
     
     VehiclePositionString="in a Hospitaler 3 Link turret"
     VehicleNameString="Hospitaler Link Turret"
}
