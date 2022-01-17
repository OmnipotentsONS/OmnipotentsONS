//MobileShield
//Build 10 Beta 2 Release
//By: Jonathan Zepp
//Used By Hyperforce

class HelixShield extends ShieldPack ;

#exec OBJ LOAD FILE=PickupSounds.uax
#exec OBJ LOAD FILE=E_Pickups.usx

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheStaticMesh(StaticMesh'E_Pickups.RegShield');
}

defaultproperties
{
     RespawnTime=15.000000
     CullDistance=1500.000000
     DrawScale=0.500000
     ScaleGlow=0.650000
     CollisionRadius=36.000000
     RotationRate=(Yaw=20000)
}
