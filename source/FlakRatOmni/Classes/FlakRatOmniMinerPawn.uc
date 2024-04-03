class FlakRatOmniMinerPawn extends ONSWeaponPawn;



simulated function DrawHUD(Canvas Canvas)
{
    local FlakRatOmniMineLauncher weap;
    super.DrawHUD(Canvas);
    weap = FlakRatOmniMineLauncher(Gun);
    if(weap != none)
    {
        weap.NewDrawWeaponInfo(Canvas, 0.92 * Canvas.ClipY);
    }
}
/*
function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
//	PC.ToggleZoom();
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
//	PC.StopZoom();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
//	PC.EndZoom();
}
*/

defaultproperties
{
     GunClass=Class'FlakRatOmni.FlakRatOmniMineLauncher'
     CameraBone="MortarGunner"
     DrivePos=(X=0.500000,Z=1.000000)
     ExitPositions(3)=(Z=100.000000)
     EntryPosition=(X=-50.000000)
     EntryRadius=400.000000
     FPCamViewOffset=(Z=40.000000)
     TPCamDistance=400.000000
     TPCamLookat=(X=0.000000)
     TPCamWorldOffset=(Z=200.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="manning a Omni Flak Rat Spider Mine Launcher"
     VehicleNameString="Omni Flak Rat Spider Miner Gunner"
}
