/******************************************************************************
PersesTankTurretPawn

Creation date: 2011-08-18 22:15
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class PersesOmniTankTurretPawn extends ONSWeaponPawn CacheExempt;


simulated function String GetDebugName()
{
	return Name$" (build "$class'PersesOmniMAS'.default.Build$")";
}

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

function bool RecommendLongRangedAttack()
{
	return true;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     FireImpulse=(X=-30000.000000)
     GunClass=Class'PersesOmni.PersesOmniTankTurret'
     bHasFireImpulse=True
     bHasAltFire=False
     bDrawDriverInTP=False
     bFPNoZFromCameraPitch=True
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryPosition=(Z=-150.000000)
     EntryRadius=130.000000
     FPCamPos=(X=-70.000000,Z=50.000000)
     FPCamViewOffset=(X=90.000000)
     TPCamLookat=(X=-50.000000,Z=0.000000)
     TPCamWorldOffset=(Z=150.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Perses tank turret"
     VehicleNameString="Perses Tank Turret"
     bStasis=False
}
