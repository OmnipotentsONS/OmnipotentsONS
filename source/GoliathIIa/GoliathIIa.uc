//-----------------------------------------------------------
//GoliathIIa
//-----------------------------------------------------------
class GoliathIIa extends ONSHoverTank
	placeable;

function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoomWithMax(0.75);
}

defaultproperties
{
     DriverWeapons(0)=(WeaponClass=Class'GoliathIIa.GoliathIIaCannon')
     PassengerWeapons(0)=(WeaponPawnClass=Class'GoliathIIa.GoliathIIaSecondaryTurretPawn')
     RedSkin=Texture'GoliathIITex.GoliathIIRed'
     BlueSkin=Texture'GoliathIITex.GoliathIIBlue'
     ExitPositions(2)=(X=-400.000000,Z=100.000000)
     ExitPositions(3)=(X=400.000000,Z=100.000000)
     FPCamPos=(Y=-1.100000)
     TPCamLookat=(X=-70.000000)
     VehiclePositionString="in a Goliath II"
     VehicleNameString="Goliath II"
}
