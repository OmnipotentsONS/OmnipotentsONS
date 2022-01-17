//=============================================================================
// Wasp (nerfed) By Danno'68
//=============================================================================
class Wasp_SeriesII extends ONSAttackCraft
	placeable;

#exec OBJ LOAD FILE=..\textures\GorzBirds_Tex.utx

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorWing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorTailWing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorGun');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'Gorzbirds_Tex.Wasp.WaspRed');
    L.AddPrecacheMaterial(Material'Gorzbirds_Tex.Wasp.WaspBlue');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlura');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.AttackCraftGroup.raptorCOLORtest');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
}


simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorWing');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorTailWing');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorGun');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

	Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'Gorzbirds_Tex.Wasp.WaspRed');
    Level.AddPrecacheMaterial(Material'Gorzbirds_Tex.Wasp.WaspBlue');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlura');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.AttackCraftGroup.raptorCOLORtest');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     MaxPitchSpeed=2200.000000
     MaxThrustForce=170.000000
     MaxStrafeForce=110.000000
     MaxRiseForce=150.000000
     MaxYawRate=2.200000
     DriverWeapons(0)=(WeaponClass=Class'Wasp_SeriesII.WaspFlakGun')
     RedSkin=Texture'GorzBirds_Tex.Wasp.WaspRed'
     BlueSkin=Texture'GorzBirds_Tex.Wasp.WaspBlue'
     TPCamDistance=250.000000
     VehiclePositionString="in a Wasp (Series II)"
     VehicleNameString="Wasp (Series II)"
     Mesh=SkeletalMesh'Gorz_BB_Mesh.Birds.Wasp'
}
