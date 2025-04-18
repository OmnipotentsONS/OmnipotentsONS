//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HospitalerShieldCannonPawn extends ONSWeaponPawn;

var bool bShieldUp;

replication 
{
	
	unreliable if( bNetDirty && Role==ROLE_Authority )
	bShieldUp;
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



function AltFire(optional float F)
{
	bShieldUp = true;  
	super.AltFire(f);
}

// this needs to go in here somehow

function VehicleCeaseFire(bool bWasAltFire)
{
    Super.VehicleCeaseFire(bWasAltFire);

    if (bWasAltFire && Gun != None)    Gun.WeaponCeaseFire(Controller, bWasAltFire);

}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
//	local PlayerController PC;

	if (!bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

//	PC = PlayerController(Controller);
//	if (PC == None)	return;

	if (bWasAltFire) bShieldUp = false;
	Gun.WeaponCeaseFire(Controller, bWasAltFire);
	Super.ClientVehicleCeaseFire(bWasAltFire);
  VehicleCeaseFire(bWasAltFire);
  
}


simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);
  Gun.CeaseFire(PC);
	bShieldUp = false;
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
     GunClass=Class'HospitalerV3Omni.HospitalerShieldCannon'
     bDrawDriverInTP=False
     DriverDamageMult=0.000000
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryPosition=(X=40.000000,Y=50.000000,Z=-100.000000)
     EntryRadius=500.000000
     FPCamPos=(Z=40.000000)
     TPCamDistance=100.000000
     //TPCamLookat=(X=0.000000)
     TPCamLookat=(X=50.000000,Z=160.000000)
     VehiclePositionString="in a Hospitaler shield turret"
     VehicleNameString="Hospitaler Shieldman"
     bShieldUp=False
}
