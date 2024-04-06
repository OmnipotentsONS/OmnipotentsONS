class BallistaCannon extends ONSWeapon;

var vector OldDir;
var rotator OldRot;
var float MinAim;
var float MaxLockRange, LockAim;

var bool bProjOffset;
var bool bAltFireProjOffset;
var rotator ProjSpawnOffset;
var rotator AltFireProjSpawnOffset;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx
#exec OBJ LOAD FILE=..\Textures\BenTex01.utx

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'WeaponSkins.RocketShellTex');
    L.AddPrecacheMaterial(Material'XEffects.RocketFlare');
    L.AddPrecacheMaterial(Material'XEffects.SmokeAlphab_t');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TankTrail');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    L.AddPrecacheMaterial(Material'ONSInterface-TX.tankBarrelAligned');
    L.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.TankDustKick1');
    L.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
    L.AddPrecacheMaterial(Material'EpicParticles.Smoke.SparkCloud_01aw');
    L.AddPrecacheMaterial(Material'BenTex01.Textures.SmokePuff01');
    L.AddPrecacheMaterial(Material'AW-2004Explosions.Fire.Part_explode2');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.HardSpot');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'WeaponSkins.RocketShellTex');
    Level.AddPrecacheMaterial(Material'XEffects.RocketFlare');
    Level.AddPrecacheMaterial(Material'XEffects.SmokeAlphab_t');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TankTrail');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    Level.AddPrecacheMaterial(Material'ONSInterface-TX.tankBarrelAligned');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.TankDustKick1');
    Level.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
    Level.AddPrecacheMaterial(Material'EpicParticles.Smoke.SparkCloud_01aw');
    Level.AddPrecacheMaterial(Material'BenTex01.Textures.SmokePuff01');
    Level.AddPrecacheMaterial(Material'AW-2004Explosions.Fire.Part_explode2');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.HardSpot');

    Super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');
	Super.UpdatePrecacheStaticMeshes();
}

function byte BestMode()
{
	return 0;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	OldDir = Vector(CurrentAim);
}



simulated function float ChargeBar()
{
	return FClamp(0.999 - (FireCountDown / FireInterval), 0.0, 0.999);
}


function Tick(float Delta)
{
	local int i;
	local xPawn P;
	local vector NewDir, PawnDir;
    local coords WeaponBoneCoords;


    Super.Tick(Delta);

	if ( (Role == ROLE_Authority) && (Base != None) )
	{
	    WeaponBoneCoords = GetBoneCoords(YawBone);
		NewDir = WeaponBoneCoords.XAxis;
		if ( (Vehicle(Base).Controller != None) && (NewDir.Z < 0.9) )
		{
			for ( i=0; i<Base.Attached.Length; i++ )
			{
				P = XPawn(Base.Attached[i]);
				if ( (P != None) && (P.Physics != PHYS_None) && (P != Vehicle(Base).Driver) )
				{
					PawnDir = P.Location - WeaponBoneCoords.Origin;
					PawnDir.Z = 0;
					PawnDir = Normal(PawnDir);
					if ( ((PawnDir.X <= NewDir.X) && (PawnDir.X > OldDir.X))
						|| ((PawnDir.X >= NewDir.X) && (PawnDir.X < OldDir.X)) )
					{
						if ( ((PawnDir.Y <= NewDir.Y) && (PawnDir.Y > OldDir.Y))
							|| ((PawnDir.Y >= NewDir.Y) && (PawnDir.X < OldDir.Y)) )
						{
							P.SetPhysics(PHYS_Falling);
							P.Velocity = WeaponBoneCoords.YAxis;
							if ( ((NewDir - OldDir) Dot WeaponBoneCoords.YAxis) < 0 )
								P.Velocity *= -1;
							P.Velocity = 500 * (P.Velocity + 0.3*NewDir);
							P.Velocity.Z = 200;
						}
					}
				}
			}
		}
		OldDir = NewDir;
	}
}

state ProjectileFireMode
{
function Fire(Controller C)
	{
		local BallistaProjectile R;
		local float BestAim, BestDist;

		R = BallistaProjectile (SpawnProjectile(ProjectileClass, False));
		if (R != None)
		{
			if (AIController(C) != None)
			    {
			     R.HomingTarget = C.Enemy;
				 R.SetHomingTarget();
		        }
			else
			   {
				BestAim = LockAim;
				R.HomingTarget = C.PickTarget(BestAim, BestDist, vector(WeaponFireRotation), WeaponFireLocation, MaxLockRange);
  		        R.SetHomingTarget();
               }
        }
	}
}

defaultproperties
{
     MinAim=0.700000
     MaxLockRange=60000.000000
     YawBone="TankTurret"
     PitchBone="TankBarrel"
     PitchUpLimit=10000
     PitchDownLimit=61500
     WeaponFireAttachmentBone="TankBarrel"
     WeaponFireOffset=200.000000
     //RotationsPerSecond=0.070000
     RotationsPerSecond=0.140000
     Spread=0.000001
     //RedSkin=Texture'DevilsArsenal_Tex.SniperTanks.SniperTankRed'
     //BlueSkin=Texture'DevilsArsenal_Tex.SniperTanks.SniperTankBlue'
     RedSkin=Texture'SieEng_TexExtra.Sniper.Ballista_RED'
     BlueSkin=Texture'SieEng_TexExtra.Sniper.Ballista_BLUE'
     FireInterval=5.00000
     bShowChargingBar=True
     EffectEmitterClass=Class'Onslaught.ONSTankFireEffect'
     FireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankFire01'
     FireSoundVolume=400.000000
     FireForce="Explosion05"
     ProjectileClass=Class'CSBallista.BallistaProjectile'
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.750000,RefireRate=0.800000)
     Mesh=SkeletalMesh'ONSWeapons-A.HoverTankCannon'
}
