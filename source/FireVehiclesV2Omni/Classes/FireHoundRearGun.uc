class FireHoundRearGun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx
#exec OBJ LOAD FILE=..\Textures\TurretParticles.utx

var class<FireHoundHeatRayEffect> BeamEffectClass[2];

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'TurretParticles.Beams.TurretBeam5');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaMuzzleBlue');
    L.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_flare_a');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_b');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_mark_heat');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_core');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'TurretParticles.Beams.TurretBeam5');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaMuzzleBlue');
    Level.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_flare_a');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_b');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_mark_heat');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_core');

    Super.UpdatePrecacheMaterials();
}

function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
    local int Damage;

    X = Vector(Dir);
    End = Start + TraceRange * X;

    //skip past vehicle driver
    if (ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
    {
      	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
       	Other = Trace(HitLocation, HitNormal, End, Start, True);
       	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
    }
    else
       	Other = Trace(HitLocation, HitNormal, End, Start, True);

    if (Other != None)
    {
	if (!Other.bWorldGeometry)
        {
            Damage = (DamageMin + Rand(DamageMax - DamageMin));
            Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
            HitNormal = vect(0,0,0);
        }
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

    HitCount++;
    LastHitLocation = HitLocation;
    SpawnHitEffects(Other, HitLocation, HitNormal);
}

state InstantFireMode
{
	simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
	{
		local FireHoundHeatRayEffect Beam;

		if (Level.NetMode != NM_DedicatedServer)
		{
			if (Role < ROLE_Authority)
			{
				CalcWeaponFire();
				DualFireOffset *= -1;
			}

			Beam = Spawn(BeamEffectClass[Team],,, WeaponFireLocation, rotator(HitLocation - WeaponFireLocation));
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			Beam.SpawnEffects(HitLocation, HitNormal);
		}
	}
	function AltFire(Controller C)
	{
 		WeaponFireOffset=85.000000;
     		DualFireOffset=0.000000;
     		bDoOffsetTrace=False;
		gotostate('projectilefiremode');
	}
}

state ProjectileFireMode
{


    function Fire(Controller C)
    {
	WeaponFireOffset=60.000000;
  	bDoOffsetTrace=True;
 	DualFireOffset=5.000000;
    	gotostate('InstantFireMode');
    }

    function AltFire(Controller C)
    {
        if (AltFireProjectileClass == None)
       	     Fire(C);
     	   else
            	SpawnProjectile(AltFireProjectileClass, True);
    }
}


defaultproperties
{
     BeamEffectClass(0)=Class'FireVehiclesV2Omni.FireHoundHeatRayEffect'
     BeamEffectClass(1)=Class'FireVehiclesV2Omni.FireHoundHeatRayEffect'
     YawBone="REARgunBASE"
     PitchBone="REARgunTURRET"
     PitchUpLimit=15000
     PitchDownLimit=57500
     WeaponFireAttachmentBone="Dummy02"
     GunnerAttachmentBone="REARgunBASE"
     DualFireOffset=15.000000
     bInstantRotation=True
     bInstantFire=True
     bDoOffsetTrace=True
     RedSkin=Texture'FireHound_Tex.FireHound.FireHoundRed'
     BlueSkin=Texture'FireHound_Tex.FireHound.FireHoundBlue'
     FireInterval=0.200000
     AltFireInterval = 0.10000
     EffectEmitterClass=Class'FireVehiclesV2Omni.FireHoundFireEffect'
     FireSoundClass=Sound'CuddlyArmor_Sound.FireTank.FireTankBeam'
     FireSoundVolume=500.000000
     
     FireForce="Laser01"
     DamageType=Class'FireVehiclesV2Omni.HeatRay'
     DamageMin=20
     DamageMax=23
     TraceRange=40000.000000
     Momentum=0.000000
          
     AIInfo(0)=(bInstantHit=True,aimerror=400.000000)
     Mesh=SkeletalMesh'ONSWeapons-A.PRVrearGUN'
     DrawScale=0.800000
     CollisionRadius=50.000000
     CollisionHeight=70.000000
     bSelected=True
}