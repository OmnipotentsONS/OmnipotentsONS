class CSPlasmaFighter extends CSBomber
    placeable;

#exec obj load file="textures\CSRailGun_Tex.utx" package=CSBomber

defaultproperties
{
    VehicleNameString="Arbiter 1.42"
    VehiclePositionString="in an Arbiter"
    RedSkin=Shader'CSBomber.CSPlasmaFighterRedShader'
    BlueSkin=Shader'CSBomber.CSPlasmaFighterBlueShader'
    DriverWeapons(0)=(WeaponClass=class'CSBomber.CSPlasmaFighterWeapon',WeaponBone=FrontGunMount)

    MaxThrustForce=125.000000
    MaxStrafeForce=95.000000
    MaxRiseForce=55.000000
    VehicleMass=5.0
    Health=275
    HealthMax=275

    BoostMaxThrust=550.000000
    BoostTime=1.600000
}