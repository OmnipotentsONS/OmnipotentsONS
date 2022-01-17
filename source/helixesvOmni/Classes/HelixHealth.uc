//MobileHealth
//Build 8 Beta 2 Release
//By: Jonathan Zepp
//Used by Hyperforce

class HelixHealth extends HealthPack ;

#exec OBJ LOAD FILE=PickupSounds.uax
#exec OBJ LOAD FILE=E_Pickups.usx

defaultproperties
{
     bPredictRespawns=True
     RespawnTime=5.000000
     RespawnEffectTime=0.200000
     DrawScale=0.270000
     bHardAttach=True
     CollisionRadius=36.000000
     RotationRate=(Yaw=20000)
}
