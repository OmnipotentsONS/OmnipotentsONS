class MinotaurCannon extends ONSWeapon;

var vector OldDir;
var rotator OldRot;
var() int ProjPerFire;
var() int AltFireProjPerFire;
var() int ProjSpread;
var() int AltFireProjSpread;
var() enum ESpreadStyle
{
    SS_None,
    SS_Random,
    SS_Line,
    SS_Ring
} SpreadStyle;

var() enum EAltFireSpreadStyle
{
    SS_None,
    SS_Random,
    SS_Line,
    SS_Ring
} AltFireSpreadStyle;

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
    	DoFireEffect(ProjectileClass, False);
    }

    function AltFire(Controller C)
    {
        if (AltFireProjectileClass == None)
            Fire(C);
        else
            DoFireEffect(AltFireProjectileClass, True);
    }
}
                                    
function DoFireEffect(class<Projectile> ProjClass, bool bAltFire)
{
	local Rotator R, AdjustedAim;
	local int p;
	local int SpawnCount;
	local float theta;
	local ONSWeaponPawn WeaponPawn;
	local vector StartLocation, HitLocation, HitNormal, Extent, X;

	AdjustedAim = WeaponFireRotation;

	if (!bAltFire && bProjOffset)
		AdjustedAim = WeaponFireRotation + ProjSpawnOffset;
	if (bAltFire && bAltFireProjOffset)
		AdjustedAim = WeaponFireRotation + AltFireProjSpawnOffset;

	if (bDoOffsetTrace)
	{
		Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
		Extent.Z = ProjClass.default.CollisionHeight;
		WeaponPawn = ONSWeaponPawn(Owner);
		if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
    		{
			if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(AdjustedAim) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5), Extent))
				StartLocation = HitLocation;
			else
				StartLocation = WeaponFireLocation + vector(AdjustedAim) * (ProjClass.default.CollisionRadius * 1.1);
		}
		else
		{
			if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(AdjustedAim) * (Owner.CollisionRadius * 1.5), Extent))
				StartLocation = HitLocation;
			else
				StartLocation = WeaponFireLocation + vector(AdjustedAim) * (ProjClass.default.CollisionRadius * 1.1);
		}
	}
	else
		StartLocation = WeaponFireLocation;

	if (!bAltFire)
	{
		SpawnCount = Max(1, ProjPerFire);

		switch (SpreadStyle)
		{
			case SS_Random:
				X = Vector(AdjustedAim);
				for (p = 0; p < SpawnCount; p++)
				{
					R.Yaw = ProjSpread * (FRand()-0.5);
					R.Pitch = ProjSpread * (FRand()-0.5);
					R.Roll = ProjSpread * (FRand()-0.5);
					SpawnAdvancedProjectile(ProjClass,bAltFire,StartLocation, Rotator(X >> R));
				}
				break;
			case SS_Line:
				for (p = 0; p < SpawnCount; p++)
				{
					theta = ProjSpread*PI/32768*(p - float(SpawnCount-1)/2.0);
					X.X = Cos(theta);
					X.Y = Sin(theta);
					X.Z = 0.0;
					SpawnAdvancedProjectile(ProjClass,bAltFire,StartLocation, Rotator(X >> AdjustedAim));
				}
				break;
			default:
				SpawnAdvancedProjectile(ProjClass,bAltFire,StartLocation,AdjustedAim);
		}
		if (bAmbientFireSound)
			AmbientSound = FireSoundClass;
		else
			PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
	}
	else
	{
		SpawnCount = Max(1, AltFireProjPerFire);

		switch (AltFireSpreadStyle)
		{
			case SS_Random:
				X = Vector(AdjustedAim);
				for (p = 0; p < SpawnCount; p++)
				{
					R.Yaw = AltFireProjSpread * (FRand()-0.5);
					R.Pitch = AltFireProjSpread * (FRand()-0.5);
					R.Roll = AltFireProjSpread * (FRand()-0.5);
					SpawnAdvancedProjectile(ProjClass,bAltFire,StartLocation, Rotator(X >> R));
				}
				break;
			case SS_Line:
				for (p = 0; p < SpawnCount; p++)
				{
					theta = AltFireProjSpread*PI/32768*(p - float(SpawnCount-1)/2.0);
					X.X = Cos(theta);
					X.Y = Sin(theta);
					X.Z = 0.0;
					SpawnAdvancedProjectile(ProjClass,bAltFire,StartLocation, Rotator(X >> AdjustedAim));
				}
				break;
			default:
				SpawnAdvancedProjectile(ProjClass,bAltFire,StartLocation,AdjustedAim);
		}
		if (bAmbientAltFireSound)
			AmbientSound = AltFireSoundClass;
		else
			PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
	}
}

function Projectile SpawnAdvancedProjectile(class<Projectile> ProjClass, bool bAltFire, vector Loc, rotator Rot)
{
    local Projectile P;

    P = spawn(ProjClass, self, , Loc, Rot);

    if (P != None)
    {
        if (bInheritVelocity)
            P.Velocity = Instigator.Velocity;

        FlashMuzzleFlash();

    }
    return P;
}

defaultproperties
{
     ProjPerFire=3
     SpreadStyle=SS_Random
     YawBone="TankTurret"
     PitchBone="TankBarrel"
     PitchUpLimit=9000
     PitchDownLimit=61500
     WeaponFireAttachmentBone="TankBarrel"
     WeaponFireOffset=200.000000
     RotationsPerSecond=0.070000
     Spread=0.005000
     RedSkin=Texture'Omnitaur_Tex.OmnitaurRed'
     BlueSkin=Texture'Omnitaur_Tex.OmnitaurBlue'
     FireInterval=3.000000
     EffectEmitterClass=Class'CSMinotaur.MinotaurFireEffect'
     FireSoundClass=Sound'CuddlyArmor_Sound.Minotaur.Minotaurcannon'
     FireSoundVolume=1100.000000
     RotateSound=Sound'CuddlyArmor_Sound.Minotaur.Minotaurturret'
     FireForce="Explosion05"
     ProjectileClass=Class'CSMinotaur.MinotaurRocketProjectile'
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=10.000000
     ShakeOffsetMag=(Z=11.000000)
     ShakeOffsetRate=(Z=300.000000)
     ShakeOffsetTime=15.000000
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.750000,RefireRate=0.800000)
     Mesh=SkeletalMesh'ONSWeapons-A.HoverTankCannon'
}
