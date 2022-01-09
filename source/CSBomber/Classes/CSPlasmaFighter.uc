class CSPlasmaFighter extends CSBomber
    placeable;

defaultproperties
{
    VehicleNameString="Arbiter 1.1"
    VehiclePositionString="in an Arbiter"
    RedSkin=Shader'CSBomber.CSPlasmaFighterRedShader'
    BlueSkin=Shader'CSBomber.CSPlasmaFighterBlueShader'
    DriverWeapons(0)=(WeaponClass=class'CSBomber.CSPlasmaFighterWeapon',WeaponBone=FrontGunMount)

    MaxThrustForce=100.000000
    MaxStrafeForce=60.000000
    MaxRiseForce=40.000000
	VehicleMass=6.0

    BoostForce=10000.000000
    BoostTime=1.500000
}