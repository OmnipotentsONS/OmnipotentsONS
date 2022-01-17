class HelixMinigunside extends ONSWeapon;

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

simulated function Destroyed()
{
	if (mTracer != None)
		mTracer.Destroy();

	Super.Destroyed();
}

simulated function UpdateTracer()
{
	local vector SpawnDir, SpawnVel;
	local float hitDist;

	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (mTracer == None)
	{
		mTracer = Spawn(mTracerClass);
	}

	if (Level.bDropDetail || Level.DetailMode == DM_Low)
		mTracerInterval = 2 * Default.mTracerInterval;
	else
		mTracerInterval = Default.mTracerInterval;

	if (mTracer != None && Level.TimeSeconds > mLastTracerTime + mTracerInterval)
	{
	        mTracer.SetLocation(WeaponFireLocation);

		hitDist = VSize(LastHitLocation - WeaponFireLocation) - mTracerPullback;

		if (Instigator != None && Instigator.IsLocallyControlled())
			SpawnDir = vector(WeaponFireRotation);
		else
			SpawnDir = Normal(LastHitLocation - WeaponFireLocation);

		if(hitDist > mTracerMinDistance)
		{
			SpawnVel = SpawnDir * mTracerSpeed;

			mTracer.Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;
			mTracer.Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;
			mTracer.Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;
			mTracer.Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;
			mTracer.Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;
			mTracer.Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;

			mTracer.Emitters[0].LifetimeRange.Min = hitDist / mTracerSpeed;
			mTracer.Emitters[0].LifetimeRange.Max = mTracer.Emitters[0].LifetimeRange.Min;

			mTracer.SpawnParticle(1);
		}

		mLastTracerTime = Level.TimeSeconds;
	}
}

simulated function FlashMuzzleFlash()
{
	Super.FlashMuzzleFlash();

	if (Role < ROLE_Authority)
		DualFireOffset *= 1;

	UpdateTracer();

	PlayAnim('Fire2', 1.00);
}

defaultproperties
{
     mTracerClass=Class'XEffects.NewTracer'
     mTracerInterval=0.060000
     mTracerPullback=150.000000
     mTracerSpeed=15000.000000
     YawBone="basebone"
     PitchBone="updown"
     PitchUpLimit=75000
     PitchDownLimit=50000
     WeaponFireAttachmentBone="firepointB"
     GunnerAttachmentBone="Gunner"
     DualFireOffset=1.000000
     RotationsPerSecond=5.000000
     bInstantRotation=True
     bInstantFire=True
     bDoOffsetTrace=True
     bAmbientFireSound=True
     bIsRepeatingFF=True
     Spread=0.010000
     RedSkin=Texture'ESV2.Texture.Helix_0'
     BlueSkin=Texture'ESV2.Texture.Helix_1'
     FireInterval=0.150000
     FireSoundClass=Sound'NewWeaponSounds.NewMinigunFire'
     AmbientSoundScaling=1.300000
     FireForce="minifireb"
     DamageType=Class'helixesvOmni.DamTypeHelixside'
     DamageMin=21
     DamageMax=29
     TraceRange=17500.000000
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=50.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=1.000000,Y=1.000000,Z=1.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     AIInfo(0)=(bInstantHit=True,aimerror=750.000000)
     CullDistance=8000.000000
     Mesh=SkeletalMesh'Helix2_final.MinigunSeat'
}
