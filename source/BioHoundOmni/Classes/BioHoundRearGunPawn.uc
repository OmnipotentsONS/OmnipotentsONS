class BioHoundRearGunPawn extends ONSWeaponPawn;

var        bool         bZooming;
var() float MinZoom, MaxZoom, ZoomSpeed;
var float ZoomLevel;
 
Function RawInput(float DeltaTime,
                            float aBaseX, float aBaseY, float aBaseZ, float aMouseX, float aMouseY,
                            float aForward, float aTurn, float aStrafe, float aUp, float aLookUp)
{
    local playerController    PC;
    local float   NewFOV;
 
    if ( PlayerController(Controller) != None )
    {
        PC = PlayerController(Controller);
        if ( aForward!=0 )
        {
            bZooming = true;
 
            if ( aForward>0 )
                ZoomLevel = ZoomLevel + ZoomSpeed * DeltaTime;
            else
                ZoomLevel = ZoomLevel - ZoomSpeed * DeltaTime;
        }
        else
            bZooming = false;
 
        if (ZoomLevel > MaxZoom)
            ZoomLevel = MaxZoom;
        else if (ZoomLevel < MinZoom)
            ZoomLevel = MinZoom;
 
        PC.bZooming = bZooming;
        if (PC.DesiredZoomLevel == ZoomLevel)
            bZooming = false;
 
        if ( bZooming )
            PC.DesiredZoomLevel = ZoomLevel;
        
        if ( PC.ZoomLevel != ZoomLevel && bZooming )
            PlaySound(Sound'WeaponSounds.LightningGun.LightningZoomIn', SLOT_Misc,,,,,false);    
    }
 
    super.RawInput(DeltaTime, aBaseX, aBaseY, aBaseZ, aMouseX, aMouseY, aForward, aTurn, aStrafe, aUp, aLookUp);
}
 
simulated function ClientKDriverLeave(PlayerController PC)
{
    Super.ClientKDriverLeave(PC);
    ZoomLevel = 0;
    PC.EndZoom();
}

function KDriverEnter(Pawn p)
{
	p.ReceiveLocalizedMessage(class'BioHoundRearGunnerEnterMessage', 0);
	Super.KDriverEnter(p);
	
}

defaultproperties
{
     MaxZoom=0.900000
     ZoomSpeed=0.900000
     GunClass=Class'BioHoundOmni.BioHoundRearGun'
     CameraBone="REARgunTURRET"
     DrivePos=(X=-20.000000,Z=90.000000)
     ExitPositions(0)=(X=-235.000000)
     ExitPositions(1)=(Y=165.000000)
     ExitPositions(2)=(Y=-165.000000)
     ExitPositions(3)=(Z=100.000000)
     EntryPosition=(X=-50.000000)
     EntryRadius=160.000000
     FPCamViewOffset=(Z=40.000000)
     TPCamDistance=450.000000
     TPCamLookat=(X=0.000000)
     TPCamWorldOffset=(Z=50.000000)
     DriverDamageMult=0.600000
     VehiclePositionString="in a BioHound's rear turret"
     VehicleNameString="BioHound Rear Turret"
}
