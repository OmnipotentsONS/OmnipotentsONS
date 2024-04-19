class CSPlasmaFighter extends CSBomber
    placeable;

#exec obj load file="textures\CSRailGun_Tex.utx" package=CSBomber

defaultproperties
{
    VehicleNameString="Arbiter 1.46"
    VehiclePositionString="in an Arbiter"
    RedSkin=Shader'CSBomber.CSPlasmaFighterRedShader'
    BlueSkin=Shader'CSBomber.CSPlasmaFighterBlueShader'
    DriverWeapons(0)=(WeaponClass=class'CSBomber.CSPlasmaFighterWeapon',WeaponBone=FrontGunMount)

    MaxThrustForce=170.000000
    MaxStrafeForce=105.000000
    MaxRiseForce=65.000000
    VehicleMass=4.0
    Health=275
    HealthMax=275

    BoostMaxThrust=750.000000
    BoostTime=2.2000
}