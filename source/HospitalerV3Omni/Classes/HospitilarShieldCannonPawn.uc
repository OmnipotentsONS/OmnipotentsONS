//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HospitilarShieldCannonPawn extends ONSWeaponPawn;

function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	super.AltFire(f);
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
	Gun.WeaponCeaseFire(PC, bWasAltFire);

}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	Gun.CeaseFire(PC);

}

defaultproperties
{
     GunClass=Class'HospitalerV3Omni.HospitilarShieldCannon'
     bDrawDriverInTP=False
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryPosition=(X=40.000000,Y=50.000000,Z=-100.000000)
     EntryRadius=500.000000
     FPCamPos=(Z=20.000000)
     TPCamDistance=0.000000
     TPCamLookat=(X=0.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Hospitaler shield turret"
     VehicleNameString="Hospitaler Shieldman"
}
