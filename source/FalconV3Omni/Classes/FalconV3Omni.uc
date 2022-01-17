//=============================================================================
// Falcon (Nerfed) by Danno'68
// Unerfed, almost back to original by pOOty
//=============================================================================
class FalconV3Omni extends ONSAttackCraft
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
    L.AddPrecacheMaterial(Material'Gorzbirds_Tex.Falcon.FalconRed');
    L.AddPrecacheMaterial(Material'Gorzbirds_Tex.Falcon.FalconBlue');
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
    Level.AddPrecacheMaterial(Material'Gorzbirds_Tex.Falcon.FalconRed');
    Level.AddPrecacheMaterial(Material'Gorzbirds_Tex.Falcon.FalconBlue');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlura');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.AttackCraftGroup.raptorCOLORtest');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     MaxPitchSpeed=3000.000000
     MaxThrustForce=200.000000
     MaxStrafeForce=150.000000
     MaxRiseForce=175.000000
     MaxYawRate=1.800000
     DriverWeapons(0)=(WeaponClass=Class'FalconV3Omni.FalconGun')
     RedSkin=Texture'GorzBirds_Tex.Falcon.FalconRed'
     BlueSkin=Texture'GorzBirds_Tex.Falcon.FalconBlue'
     TPCamDistance=400.000000
     VehiclePositionString="in a Falcon 3.0"
     VehicleNameString="Falcon 3.0"
     WaterDamage=0.000000
     Mesh=SkeletalMesh'Gorz_BB_Mesh.Birds.Falcon'
}
