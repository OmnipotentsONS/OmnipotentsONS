//=============================================================================
// Factory_IonCannon
// Specific factory for Ion Cannon
//=============================================================================

class Factory_IonCannon extends Factory_TurretFactory;

#exec OBJ LOAD File=AnnouncerAssault.uax


function VehicleSpawned()
{
	local ASTurret T;

	Super.VehicleSpawned();

	T = ASTurret(Child);
	if ( T == None )
		return;


}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     RespawnDelay=300.000000
     Announcement_Destroyed=Sound'AnnouncerAssault.Generic.Ion_Cannon_destroyed'
     VehicleClass=Class'CSAPVerIV.Turret_APIonCannon'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Weapons_SM.Turret.IonCannonStatic'
     DrawScale=0.660000
     AmbientGlow=96
     CollisionRadius=200.000000
     CollisionHeight=300.000000
     bEdShouldSnap=True
}
