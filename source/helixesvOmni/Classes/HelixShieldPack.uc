//=============================================================================
// ShieldPack
//=============================================================================
class HelixShieldPack extends ShieldPickup;

#exec OBJ LOAD FILE=PickupSounds.uax
#exec OBJ LOAD FILE=E_Pickups.usx

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheStaticMesh(StaticMesh'E_Pickups.RegShield');
}

defaultproperties
{
     ShieldAmount=50
     bPredictRespawns=True
     PickupSound=Sound'PickupSounds.ShieldPack'
     PickupForce="ShieldPack"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'E_Pickups.General.RegShield'
     Physics=PHYS_Rotating
     DrawScale=0.600000
     ScaleGlow=0.600000
     Style=STY_AlphaZ
     bHardAttach=True
     CollisionRadius=32.000000
     RotationRate=(Yaw=24000)
}
