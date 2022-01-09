//=============================================================================
// FireBadgerTurretPawn.
//=============================================================================
class FireBadgerTurretPawn extends BadgerTurretPawn;

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
     GunClass=Class'CSBadgerFix.FlameBadgerCannon'
     bHasAltFire=True
     VehiclePositionString="in a Fire Badger Turret"
     VehicleNameString="Fire Badger Turret"
}
