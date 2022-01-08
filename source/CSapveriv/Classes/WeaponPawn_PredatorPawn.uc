//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WeaponPawn_PredatorPawn extends ONSWeaponPawn;




function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
    PC.ToggleZoom();

}
function KDriverEnter(Pawn P)
{
	super.KDriverEnter(P);
	Driver.CreateInventory("CSAPVerIV.edo_ChuteInv");
	if (!VehicleBase.bDriving)
	   {
		VehicleBase.bDriving = true;
		VehicleBase.DrivingStatusChanged();
	   }
}

event bool KDriverLeave( bool bForceLeave )
{
	local bool b;
	b  = super.KDriverLeave(bForceLeave);
 if (b && VehicleBase.IsVehicleEmpty() )
	   {
		VehicleBase.bDriving = false;
		VehicleBase.DrivingStatusChanged();
		if(VehicleBase.IsA('Predator'))
		Predator(VehicleBase).GearStatusChanged();
	  }

	return b;
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

simulated function DrawHUD(Canvas Canvas)
{
	Canvas.Style = 5;
	if ( !Level.IsSoftwareRendering() )
	{
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 255;
		Canvas.DrawColor.A = 50;
		Canvas.DrawTile( Material'DomPLinesGP', Canvas.SizeX, Canvas.SizeY, 0, 0, 256, 256);
	}

    Canvas.Style = 1;
    Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	Canvas.DrawColor.A = 255;

	Canvas.SetPos(0,0);
    Canvas.DrawTile( Material'TurretHud2', Canvas.SizeX, Canvas.SizeY, 0, 0, 1024, 768);
    Canvas.SetPos(0,0);

//  Remove Me : for testing
//	ProjectilePostRender2D(None,Canvas,140,140);

}

defaultproperties
{
     GunClass=Class'CSAPVerIV.Weapon_PredatorVulcanGun'
     CameraBone="GunBaseAttach"
     bDrawDriverInTP=False
     bHasAltFire=false
     DrivePos=(Z=130.000000)
     ExitPositions(0)=(Y=-200.000000,Z=100.000000)
     ExitPositions(1)=(Y=200.000000,Z=100.000000)
     EntryPosition=(X=40.000000,Y=50.000000,Z=-100.000000)
     EntryRadius=130.000000
     FPCamPos=(Z=20.000000)
     FPCamViewOffset=(X=64.000000,Z=-64.000000)
     TPCamDistance=100.000000
     TPCamLookat=(X=64.000000,Z=0.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Predator Turret"
     VehicleNameString="Predator Gun Turret"
}
