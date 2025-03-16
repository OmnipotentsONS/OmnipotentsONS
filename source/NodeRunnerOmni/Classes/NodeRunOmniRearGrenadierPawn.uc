//-----------------------------------------------------------
//
//-----------------------------------------------------------
class NodeRunOmniRearGrenadierPawn extends ONSWeaponPawn;


simulated function DrawHUD(Canvas Canvas)
{
    local NodeRunOmniRearGrenadeLauncher weap;
    super.DrawHUD(Canvas);
    weap = NodeRunOmniRearGrenadeLauncher(Gun);
    if(weap != none)
    {
        weap.NewDrawWeaponInfo(Canvas, 0.92 * Canvas.ClipY);
    }
}


defaultproperties
{
     GunClass=Class'NodeRunnerOmni.NodeRunOmniRearGrenadeLauncher'
     bHasAltFire=True
     CameraBone="Dummy02"
     DrivePos=(X=-1.750000,Z=8.000000)
     ExitPositions(0)=(X=-235.000000)
     ExitPositions(1)=(Y=165.000000)
     ExitPositions(2)=(Y=-165.000000)
     ExitPositions(3)=(Z=100.000000)
     EntryPosition=(X=-50.000000)
     EntryRadius=180.000000
     FPCamViewOffset=(Z=40.000000)
     TPCamDistance=250.000000
     TPCamLookat=(X=0.000000)
     TPCamWorldOffset=(Z=50.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a NodeRunner's Grenade Launcher"
     VehicleNameString="NodeRunner Omni Grenade Launcher"
}
