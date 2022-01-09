
class CSLeviathan extends ONSMobileAssaultStation
    placeable;

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
    VehicleNameString="Leviathan"
    DriverWeapons(0)=(WeaponClass=class'OnslaughtFull.ONSMASRocketPack',WeaponBone=RocketPackAttach);
    DriverWeapons(1)=(WeaponClass=class'OnslaughtFull.ONSMASCannon',WeaponBone=MainGunPostBase);
	PassengerWeapons(0)=(WeaponPawnClass=class'CSLeviathan.CSONSMASSideGunPawn',WeaponBone=RightFrontGunAttach);
	PassengerWeapons(1)=(WeaponPawnClass=class'CSLeviathan.CSONSMASSideGunPawn',WeaponBone=LeftFrontGunAttach);
	PassengerWeapons(2)=(WeaponPawnClass=class'CSLeviathan.CSONSMASSideGunPawn',WeaponBone=RightRearGunAttach);
	PassengerWeapons(3)=(WeaponPawnClass=class'CSLeviathan.CSONSMASSideGunPawn',WeaponBone=LeftRearGunAttach);
}
