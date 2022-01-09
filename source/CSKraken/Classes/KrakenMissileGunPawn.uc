//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KrakenMissileGunPawn extends ONSWeaponPawn;

simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    // no stupid roll
    if(Abs(PC.ShakeRot.Pitch) >= 16384)
    {
        PC.bEnableAmbientShake = false;
        PC.StopViewShaking();
        PC.ShakeOffset = vect(0,0,0);
        PC.ShakeRot = rot(0,0,0);
    }

    super.SpecialCalcBehindView(PC, ViewActor, CameraLocation, CameraRotation);
}

defaultproperties
{
     GunClass=Class'CSKraken.KrakenMissileGun'
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
     DriverDamageMult=0.000000
     VehiclePositionString="in a Tiamat turret"
     VehicleNameString="Tiamat Missile Turret"
     bSelected=True
}
