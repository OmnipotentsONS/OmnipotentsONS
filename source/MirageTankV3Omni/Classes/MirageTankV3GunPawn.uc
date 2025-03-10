//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MirageTankV3GunPawn extends ONSWeaponPawn;

defaultproperties
{
     GunClass=Class'MirageTankV3Omni.MirageTankV3Gun'
     CameraBone="Object83"
     bDrawDriverInTP=False
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryPosition=(Z=-150.000000)
     EntryRadius=130.000000
     FPCamViewOffset=(X=5.000000,Z=35.000000)
     TPCamDistance=100.000000
     TPCamLookat=(X=0.000000,Z=110.000000)
     DriverDamageMult=0.100000
     VehiclePositionString="in a Mirage Panzer Gun Turret"
     VehicleNameString="Mirage Panzer Gun Turret"
     AmbientGlow=12
     bShadowCast=True
     bStaticLighting=True
}
