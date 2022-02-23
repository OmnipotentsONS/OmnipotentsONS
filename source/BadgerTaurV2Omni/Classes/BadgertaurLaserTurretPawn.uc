//=============================================================================
// BadgertaurLaserTurretPawn.
//=============================================================================
class BadgertaurLaserTurretPawn extends BadgerTurretPawn;

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
     GunClass=Class'BadgerTaurV2Omni.BadgertaurLaserTurret'
     VehiclePositionString="in a Megabadger Laser Turret"
     VehicleNameString="Megabadger Laser Cannon"
}
