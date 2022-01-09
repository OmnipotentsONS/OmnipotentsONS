//=============================================================================
// BioBadgerTurretPawn.
//=============================================================================
class BioBadgerTurretPawn extends BadgerTurretPawn;

function AltFire(optional float F)
{
	Super(ONSWeaponPawn).AltFire(F);
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	Super(ONSWeaponPawn).ClientVehicleCeaseFire(bWasAltFire);
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super(ONSWeaponPawn).ClientKDriverLeave(PC);
}

defaultproperties
{
     GunClass=Class'CSBadgerFix.BioBadgerTurret'
     bHasAltFire=True
     VehiclePositionString="in a BioBadger Turret"
     VehicleNameString="BioBadger Turret"
}
