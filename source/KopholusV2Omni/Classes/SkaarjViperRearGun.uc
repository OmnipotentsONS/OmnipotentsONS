//-----------------------------------------------------------
//	Skaarj Viper Speedboat
//	Colt Wohlers (aka CMan)
//	Beta 4.0 (July 2/2004)
//-----------------------------------------------------------
class SkaarjViperRearGun extends ONSWeapon;

var float MaxLockRange, LockAim;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    L.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
    L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    Level.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
    Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

    Super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');
	Super.UpdatePrecacheStaticMeshes();
}


state ProjectileFireMode
{
	function Fire(Controller C)
	{
		local SkaarjViperProjectile Proj;
		local float BestAim, CurAim;
		local Vehicle V, Best;

		Proj = SkaarjViperProjectile(SpawnProjectile(ProjectileClass, False));
		//The following code locks on to targets if not desired please comment out | mr-slate
		if (Proj != None)
		{
			if (AIController(Instigator.Controller) != None)
			{
				V = Vehicle(Instigator.Controller.Enemy);
				if (V != None && (V.bCanFly || V.IsA('ONSHoverCraft')) && Instigator.FastTrace(V.Location, Instigator.Location))
					Proj.SetHomingTarget(V);
			}
			else
			{
				BestAim = LockAim;
				for (V = Level.Game.VehicleList; V != None; V = V.NextVehicle)
					if ((V.bCanFly || V.IsA('ONSHoverCraft')) && V != Instigator && Instigator.GetTeamNum() != V.GetTeamNum())
					{
						CurAim = Normal(V.Location - WeaponFireLocation) dot vector(WeaponFireRotation);
						if (CurAim > BestAim && Instigator.FastTrace(V.Location, Instigator.Location)
                                                && VSize(V.Location - Instigator.Location) <= MaxLockRange) //enables the maxRange
						{
							Best = V;
							BestAim = CurAim;
						}
					}
				if (Best != None)
					Proj.SetHomingTarget(Best);
			}
		}
	}
}

defaultproperties
{
     MaxLockRange=30000.000000
     LockAim=0.975000
     YawBone="VTBase"
     PitchBone="VTGun"
     PitchUpLimit=18000
     PitchDownLimit=0
     WeaponFireAttachmentBone="VTFire"
     GunnerAttachmentBone="VHull"
     DualFireOffset=3.000000
     bDualIndependantTargeting=True
     FireInterval=0.500000
     FireSoundClass=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'
     FireForce="RocketLauncherFire"
     //ProjectileClass=Class'KopholusV2Omni.SkaarjViperProjectile'
     ProjectileClass=Class'KopholusV2Omni.KBMercuryMissile'
     AIInfo(0)=(bLeadTarget=True)
     Mesh=SkeletalMesh'KASPvehicles.SVTurret'
}
