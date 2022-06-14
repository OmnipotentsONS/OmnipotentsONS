class CSPlasmaFighter extends CSBomber
    placeable;

#exec obj load file="textures\CSRailGun_Tex.utx" package=CSBomber

defaultproperties
{
    VehicleNameString="Arbiter 1.2"
    VehiclePositionString="in an Arbiter"
    RedSkin=Shader'CSBomber.CSPlasmaFighterRedShader'
    BlueSkin=Shader'CSBomber.CSPlasmaFighterBlueShader'
    DriverWeapons(0)=(WeaponClass=class'CSBomber.CSPlasmaFighterWeapon',WeaponBone=FrontGunMount)

    MaxThrustForce=110.000000
    MaxStrafeForce=75.000000
    MaxRiseForce=55.000000
	VehicleMass=7.0

    BoostForce=16000.000000
    BoostTime=2.000000
}