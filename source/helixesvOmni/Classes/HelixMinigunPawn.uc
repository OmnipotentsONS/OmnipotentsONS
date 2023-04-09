class HelixMinigunPawn extends ONSWeaponPawn;

//========================================================================
// this code enables the hover mode
function KDriverEnter(Pawn P)
{
    local Inventory Inv;
    local CSChuteInv Ch;
    
    super.KDriverEnter( P );
// gunner chutes
   Driver.CreateInventory("CSEjectorSeat.CSChuteInv");
   
   // next displays for server to show other clients
   // using pickup seems to set this
   for ( Inv=Driver.Inventory; Inv!=None; Inv=Inv.Inventory )
    {
        Ch = CSChuteInv(Inv);
        if ( Ch != None )
        {
    			Ch.bOnlyRelevantToOwner = false;    
        }
    }
    
	if (!VehicleBase.bDriving)
		VehicleBase.bDriving = true;
	
	
}

event bool KDriverLeave( bool bForceLeave )
{
	local bool b;
	b  = super.KDriverLeave(bForceLeave);
	if (b && VehicleBase.IsVehicleEmpty() )
		VehicleBase.bDriving = false;

	return b;

}

/*simulated function Tick(float DeltaTime)
{
super.Tick(DeltaTime);

if ( !IsVehicleEmpty() )
Enable('tick');
}*/
//========================================================================

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

defaultproperties
{
     GunClass=Class'helixesvOmni.HelixMinigun'
     bHasAltFire=False
     CameraBone="CameraBone"
     bDrawDriverInTP=False
     ExitPositions(0)=(Y=-200.000000,Z=100.000000)
     ExitPositions(1)=(Y=200.000000,Z=100.000000)
     EntryRadius=130.000000
     FPCamViewOffset=(Z=5.000000)
     TPCamDistance=150.000000
     TPCamLookat=(X=55.000000,Z=5.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a OmniHelix Dual-Minigun turret"
     VehicleNameString="OmniHelix Dual-Minigun turret"
}
