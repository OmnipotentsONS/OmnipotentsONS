#exec OBJ LOAD FILE=EpicParticles.utx

class FighterSpawnRiflePickup extends UTWeaponPickup;



function PrebeginPlay()
{
	Super.PreBeginPlay();

}

function SetWeaponStay()
{
	bWeaponStay = false;
}

function float GetRespawnTime()
{
	return ReSpawnTime;
}

static function StaticPrecache(LevelInfo L)
{
	local int i;

	for ( i=0; i<4; i++ )
	L.AddPrecacheMaterial(Material'WeaponSkins.RDMR_Missile');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RedeemerPickup');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RedeemerMissile');
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Material'WeaponSkins.RDMR_Missile');

	super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RedeemerMissile');
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RedeemerPickup');

	Super.UpdatePrecacheStaticMeshes();
}

defaultproperties
{
     bWeaponStay=False
     MaxDesireability=1.000000
     InventoryType=Class'CSAPVerIV.FighterSpawnRifle'
     RespawnTime=120.000000
     PickupMessage="You got the FighterSpawnRifle."
     PickupSound=Sound'PickupSounds.FlakCannonPickup'
     PickupForce="FlakCannonPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RedeemerPickup'
     DrawScale=0.900000
}
