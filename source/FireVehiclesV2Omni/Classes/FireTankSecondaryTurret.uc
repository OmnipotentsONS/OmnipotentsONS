class FireTankSecondaryTurret extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx
#exec OBJ LOAD FILE=..\Textures\TurretParticles.utx

var class<HeatRayEffect> BeamEffectClass[2];

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
		local HeatRayEffect Beam;

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
	/* This made alt fire a flame thrower which would have worked well with W zoom
	function AltFire(Controller C)
	{
 		WeaponFireOffset=85.000000;
     		DualFireOffset=0.000000;
     		bDoOffsetTrace=False;
		gotostate('projectilefiremode');
	}
	*/
}

/*
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
*/

defaultproperties
{
     BeamEffectClass(0)=Class'FireVehiclesV2Omni.HeatRayEffect'
     BeamEffectClass(1)=Class'FireVehiclesV2Omni.HeatRayEffect'
     YawBone="Object01"
     PitchBone="Object02"
     PitchUpLimit=14500
     PitchDownLimit=59500
     WeaponFireAttachmentBone="Object02"
     WeaponFireOffset=60.000000
     DualFireOffset=5.000000
     bInstantRotation=True
     bInstantFire=True
     bDoOffsetTrace=True
     RedSkin=Texture'FireTank_Tex.FireTank.FireTankRed'
     BlueSkin=Texture'FireTank_Tex.FireTank.FireTankBlue'
     FireInterval=0.20000
     AltFireInterval=0.100000
     FireSoundClass=Sound'CuddlyArmor_Sound.FireTank.FireTankBeam'
     FireSoundVolume=300.000000
     AltFireSoundClass=Sound'GeneralAmbience.firefx11'
     AltFireSoundVolume=200.000000
     FireForce="Laser01"
     DamageType=Class'FireVehiclesV2Omni.HeatRay'
     DamageMin=20
     DamageMax=25
     TraceRange=40000.000000
     Momentum=0.000000
     AltFireProjectileClass=Class'FireVehiclesV2Omni.FireProjectile'
     AIInfo(0)=(bInstantHit=True,aimerror=750.000000)
     Mesh=SkeletalMesh'AS_VehiclesFull_M.IONTankMachineGun'
     bSelected=True
}
