//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Weapon_ReaperCannon extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var class<ONSTurretBeamEffect> BeamEffectClass[2];

// do any general vehicle set-up when it gets spawned.
simulated function PostNetBeginPlay()
{
    PlayAnim('CannonClose');
    Super.PostNetBeginPlay();
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
		local ONSTurretBeamEffect Beam;

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
}

simulated function SetInvisable()
{
   bHidden=true;
}

simulated function SetVisable()
{
   bHidden=False;
}
function byte BestMode()
{
		return 0;
}

simulated function Destroyed()
{
	Super.Destroyed();
}

defaultproperties
{
     BeamEffectClass(0)=Class'OnslaughtBP.ONSBellyTurretFire'
     BeamEffectClass(1)=Class'OnslaughtBP.ONSBellyTurretFire'
     YawBone="GunBaseAttach"
     PitchBone="BarrelAttach"
     PitchUpLimit=8000
     PitchDownLimit=49153
     WeaponFireAttachmentBone="Firepoint"
     RotationsPerSecond=1.200000
     bInstantRotation=True
     bInstantFire=True
     bDoOffsetTrace=True
     Spread=0.010000
     //FireInterval=0.200000
     FireInterval=0.25
     AmbientSoundScaling=2.300000
     FireForce="minifireb"
     DamageType=Class'Onslaught.DamTypeONSChainGun'
     DamageMin=55
     DamageMax=55
     TraceRange=15000.000000
     AIInfo(0)=(bInstantHit=True,aimerror=750.000000)
     CullDistance=8000.000000
     Mesh=SkeletalMesh'APVerIV_Anim.ReaperCannonMesh'
}
