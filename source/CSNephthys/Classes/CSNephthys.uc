
class CSNephthys extends NephthysTank
    placeable;

#exec obj load file="Textures\CSNephthys_Tex.utx" package=CSNephthys

var float VortexDelay;
var int SpawnKillCount, MaxSpawnKills;

function RecordDamage(actor victim, float dmg)
{
    local xPawn player;
    player = xPawn(victim);
    if(player != None)
    {
        //kill
        if(dmg >= player.Health)
        {
            //spawn kill
            if(Level.TimeSeconds - player.SpawnTime - VortexDelay < DeathMatch(Level.Game).SpawnProtectionTime)
            {
                SpawnKillCount++;
            }
        }
    }
}

simulated function Tick(float DT)
{
    super.Tick(DT);
    if(SpawnKillCount > MaxSpawnKills)
    {
        TakeDamage(5000, Driver, Location, Normal(Velocity), class'CSNephthysDamTypeSpawnKiller');
    }
}

defaultproperties
{
    VehicleNameString="Dark Nephthys 1.1"
    //MaxGroundSpeed=1800
    MaxGroundSpeed=1350
    //MaxAirSpeed=6000
    MaxAirSpeed=4500
    DriverWeapons(0)=(WeaponClass=Class'CSNephthys.CSNephthysTurret',WeaponBone="Weapon02_b")
    RedSkin=Texture'CSNephthys.NephthysRed'
    BlueSkin=Texture'CSNephthys.NephthysBlue'

    //MaxThrustForce=400.000000
    MaxThrustForce=300.000000
    //MaxStrafeForce=300.000000
    MaxStrafeForce=225.000000
    VortexDelay=4.0
    SpawnKillCount=0
    MaxSpawnKills=7
}