// ============================================================================
// Link Tank gunner turret.
// ============================================================================
class LinkTank3MiniSecondaryTurret extends ONSWeapon;

var() sound LinkedFireSound;

// ============================================================================
// Spawn projectile. Adjust link properties if needed.
// ============================================================================
function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	local Projectile SpawnedProjectile;
	local int NumLinks;

	if (LinkTank3Mini(ONSWeaponPawn(Owner).VehicleBase) != None)
		NumLinks = LinkTank3Mini(ONSWeaponPawn(Owner).VehicleBase).GetLinks();
	else
		NumLinks = 0;
  
  //log("LinkTank3SecondaryTurret NumLinks="$NumLinks);
	// Swap out fire sound
	if (NumLinks > 0)
		FireSoundClass = LinkedFireSound;
	else
		FireSoundClass = default.FireSoundClass;

	SpawnedProjectile = Super.SpawnProjectile(ProjClass, bAltFire);
	if (LinkProjectile(SpawnedProjectile) != None)
	{

		LinkProjectile(SpawnedProjectile).Links = NumLinks;
		LinkProjectile(SpawnedProjectile).LinkAdjust();
	}

	return SpawnedProjectile;
}

static function StaticPrecache(LevelInfo L)
{
//    L.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
//    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');
}

simulated function UpdatePrecacheMaterials()
{
//    Level.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
//    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');

    Super.UpdatePrecacheMaterials();
}

function byte BestMode()
{
	return 0;
}

// ============================================================================

defaultproperties
{
     LinkedFireSound=Sound'WeaponSounds.LinkGun.BLinkedFire'
     YawBone="rvGUNTurret"
     PitchBone="rvGUNbody"
     PitchUpLimit=8000
     PitchDownLimit=58000
     WeaponFireAttachmentBone="RVfirePoint"
     WeaponFireOffset=100.000000
     RotationsPerSecond=2.000000
     bInstantRotation=True
     FireInterval=0.200000
     FireSoundClass=SoundGroup'WeaponSounds.PulseRifle.PulseRifleFire'
     AmbientSoundScaling=1.300000
     ProjectileClass=Class'LinkVehiclesOmni.LinkTank3ProjectileSmall'
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.990000,RefireRate=0.990000)
     Mesh=SkeletalMesh'ONSWeapons-A.RVnewGun'
     RedSkin=Texture'LinkScorpion3Tex.LinkScorpGun'
     BlueSkin=Texture'LinkScorpion3Tex.LinkScorpGun'
     DrawScale=0.90000
     
}
