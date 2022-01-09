class CSSpankBomber extends CSBomber
    placeable;

defaultproperties
{
    VehicleNameString="Prodigy 1.1"
    VehiclePositionString="in a Prodigy"
    RedSkin=Shader'CSBomber.CSSpankBomberRedShader'
    BlueSkin=Shader'CSBomber.CSSpankBomberBlueShader'
    VehicleMass=5.0

    DriverWeapons(0)=(WeaponClass=class'CSBomber.CSSpankBomberWeapon',WeaponBone=FrontGunMount)

}