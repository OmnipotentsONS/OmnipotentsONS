// ============================================================================
// Link Tank gunner turret pawn.
// ============================================================================
class VampireTank3SecondaryTurretPawn extends ONSWeaponPawn;


// ============================================================================
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

defaultproperties
{
     GunClass=Class'LinkVehiclesOmni.VampireTank3SecondaryTurret'
     bHasAltFire=True
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
     VehiclePositionString="in a Vampire Tank turret"
     VehicleNameString="Vampire Tank Plasma Turret"
}