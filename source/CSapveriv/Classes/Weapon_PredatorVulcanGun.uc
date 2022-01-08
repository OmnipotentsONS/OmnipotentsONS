//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Weapon_PredatorVulcanGun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var class<Emitter>      mTracerClass;
var() editinline Emitter mTracer;
var() float				mTracerInterval;
var() float				mTracerPullback;
var() float				mTracerMinDistance;
var() float				mTracerSpeed;
var float               mLastTracerTime;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');

    Super.UpdatePrecacheMaterials();
}

function byte BestMode()
{
    return 0;
}


simulated function ClientStopFire(Controller C, bool bWasAltFire)
{
	if (bIsRepeatingFF)
	{
		if (bIsAltFire)
			StopForceFeedback( AltFireForce );
		else
			StopForceFeedback( FireForce );
	}

	if (Role < ROLE_Authority && AmbientEffectEmitter != None)
		AmbientEffectEmitter.SetEmitterStatus(false);

		DualFireOffset = 85;

}

state InstantFireMode
{
    function Fire(Controller C)
    {
        FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        TraceFire(WeaponFireLocation, WeaponFireRotation);
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

    simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
	{
		local Emitter Beam;
        local vector SpawnDir, SpawnVel;
        local float hitDist;

		if (Level.NetMode != NM_DedicatedServer)
		{
			if (Role < ROLE_Authority)
			{
				CalcWeaponFire();
				DualFireOffset *= -1;
			}

			//Beam = Spawn(mTracerClass,,, WeaponFireLocation, rotator(HitLocation - WeaponFireLocation));
			Beam = Spawn(mTracerClass);
            

            if (Level.bDropDetail || Level.DetailMode == DM_Low)
                    mTracerInterval = 2 * Default.mTracerInterval;
            else
                mTracerInterval = Default.mTracerInterval;

            if (Beam != None && Level.TimeSeconds > mLastTracerTime + mTracerInterval)
            {
                Beam.SetLocation(WeaponFireLocation);

                hitDist = VSize(LastHitLocation - WeaponFireLocation) - mTracerPullback;

                if (Instigator != None && Instigator.IsLocallyControlled())
                    SpawnDir = vector(WeaponFireRotation);
                else
                    SpawnDir = Normal(LastHitLocation - WeaponFireLocation);

                if(hitDist > mTracerMinDistance)
                {
                    SpawnVel = SpawnDir * mTracerSpeed;

                    Beam.Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;
                    Beam.Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;
                    Beam.Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;
                    Beam.Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;
                    Beam.Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;
                    Beam.Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;
                    Beam.Emitters[0].LifetimeRange.Min = hitDist / mTracerSpeed;
                    Beam.Emitters[0].LifetimeRange.Max = Beam.Emitters[0].LifetimeRange.Min;
                    Beam.SpawnParticle(1);
                }

                mLastTracerTime = Level.TimeSeconds;
            }


            PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
		}
	}
}

defaultproperties
{
     mTracerClass=Class'XEffects.NewTracer'
     mTracerInterval=0.060000
     mTracerPullback=150.000000
     mTracerSpeed=15000.000000
     YawBone="GunBaseAttach"
     PitchBone="BarrelAttach"
     PitchUpLimit=8000
     PitchDownLimit=49153
     WeaponFireAttachmentBone="Firepoint"
     RotationsPerSecond=1.200000
     bInstantRotation=True
     bInstantFire=True
     bDoOffsetTrace=True
     //WeaponFireOffset=20.0
     //Spread=0.010000
     Spread=0.0
     //FireInterval=0.200000
     FireInterval=0.100000
     AmbientEffectEmitterClass=Class'Onslaught.ONSRVChainGunFireEffect'
     FireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankMachineGun01'
     AmbientSoundScaling=1.300000
     FireForce="minifireb"
     DamageType=Class'Onslaught.DamTypeONSChainGun'
     //DamageMin=25
     //DamageMax=25
     DamageMin=35
     DamageMax=35
     TraceRange=15000.000000
     AIInfo(0)=(bInstantHit=True,aimerror=750.000000)
     CullDistance=+15000.0
     Mesh=SkeletalMesh'APVerIV_Anim.PredatorVulcanMesh'
}
