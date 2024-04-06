class BioHoundRearGun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx
#exec OBJ LOAD FILE=..\Textures\TurretParticles.utx


var class<BioHoundBeamEffect> BeamEffectClass[2];

var float AltFireCountdown;  // countdown only for alt-fire separate from fire.
var bool bAltFired;

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
		local BioHoundBeamEffect Beam;

		if (Level.NetMode != NM_DedicatedServer)
		{
			if (Role < ROLE_Authority)
			{
				CalcWeaponFire();
			}

            if (!Level.bDropDetail && Level.DetailMode != DM_Low)
            {
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
		  if (FireCountdown <= 0) bAltFired=False;
    	gotostate('ProjectileFireMode');
	}
}

state ProjectileFireMode
{
    function Fire(Controller C)
    {
    	gotostate('InstantFireMode');
    }

    function AltFire(Controller C)
    {
        if (AltFireProjectileClass == None)
       	     Fire(C);
     	   else
             SpawnProjectile(AltFireProjectileClass, True);
        bAltFired = True;
     }         
}

// Added 03/2023 pooty to make primary fire available all the time
// base code from ONSWeapon

event bool AttemptFire(Controller C, bool bAltFire)
{
    if(Role != ROLE_Authority || bForceCenterAim)
        return False;

    if (FireCountdown <= 0 && !bAltFire)
    {
        CalcWeaponFire();
        if (bCorrectAim)
            WeaponFireRotation = AdjustAim(bAltFire);
        if (Spread > 0)
            WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        DualFireOffset *= -1;

        Instigator.MakeNoise(1.0);
        FireCountdown = FireInterval;
        Fire(C);
        AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        return True;
    }
    if (!bAltFired) AltFireCountdown = 0;
    
    if (AltFireCountdown <= 0 && bAltFire)
    {
        CalcWeaponFire();
        if (bCorrectAim)
            WeaponFireRotation = AdjustAim(bAltFire);
        if (Spread > 0)
            WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        DualFireOffset *= -1;

        Instigator.MakeNoise(1.0);
        AltFireCountdown = AltFireInterval;
        AltFire(C);
        AimLockReleaseTime = Level.TimeSeconds + AltFireCountdown * FireIntervalAimLock;

        return True;
    }

    return False;
}

simulated function tick(float dt)
{

		Super.Tick(dt);
		if(AltFireCountdown > 0)  AltFireCountdown -= dt;
}

simulated function float ChargeBar()
{
	return FClamp(0.999 - (AltFireCountDown / AltFireInterval), 0.0, 0.999);
	// Charge bar is just for AltFire
}


defaultproperties
{
     BeamEffectClass(0)=Class'BioHoundOmni.BioHoundBeamEffect'
     BeamEffectClass(1)=Class'BioHoundOmni.BioHoundBeamEffect'
     YawBone="REARgunBASE"
     PitchBone="REARgunTURRET"
     PitchUpLimit=15000
     PitchDownLimit=57500
     WeaponFireAttachmentBone="Dummy02"
     GunnerAttachmentBone="REARgunBASE"
     DualFireOffset=-15.000000
     bInstantRotation=True
     bInstantFire=True
     bDoOffsetTrace=True
     RedSkin=Texture'BioHound_Tex.BioHound.BioHoundRed'
     BlueSkin=Texture'BioHound_Tex.BioHound.BioHoundBlue'
     FireInterval=0.380000
     AltFireInterval=3.0000
     bShowChargingBar=True
     FlashEmitterClass=Class'BioHoundOmni.BioHoundMuzzleFlash'
     EffectEmitterClass=Class'BioHoundOmni.BioHoundFireEffect'
     FireSoundClass=ProceduralSound'WeaponSounds.ShieldGun.ShieldReflection'
     AltFireSoundClass=SoundGroup'WeaponSounds.FlakCannon.FlakCannonAltFire'
     FireForce="Laser01"
     DamageType=Class'BioHoundOmni.BioHoundBioBeam'
     DamageMin=33
     DamageMax=33
     TraceRange=20000.000000
     Momentum=10000.000000
     AltFireProjectileClass=Class'BioHoundOmni.BioHoundMissile'
     AIInfo(0)=(bInstantHit=True,aimerror=400.000000)
     Mesh=SkeletalMesh'ONSWeapons-A.PRVrearGUN'
     DrawScale=0.800000
     CollisionRadius=50.000000
     CollisionHeight=70.000000
     bSelected=True
}
