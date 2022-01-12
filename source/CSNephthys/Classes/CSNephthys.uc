
class CSNephthys extends NephthysTank
    placeable;

#exec obj load file="Textures\CSNephthys_Tex.utx" package=CSNephthys

defaultproperties
{
    VehicleNameString="Dark Nephthys"
    MaxGroundSpeed=1800
    MaxAirSpeed=6000
    DriverWeapons(0)=(WeaponClass=Class'CSNephthys.CSNephthysTurret',WeaponBone="Weapon02_b")
    RedSkin=Texture'CSNephthys.NephthysRed'
    BlueSkin=Texture'CSNephthys.NephthysBlue'

    MaxThrustForce=400.000000
    MaxStrafeForce=300.000000
}