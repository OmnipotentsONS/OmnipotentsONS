class MirageTankV3Minigun extends ONSWeapon;

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
		DualFireOffset *= -1;

	UpdateTracer();

}

defaultproperties
{
     mTracerClass=Class'XEffects.NewTracer'
     mTracerInterval=0.060000
     mTracerPullback=150.000000
     mTracerSpeed=15000.000000
     YawBone="PassengerGunBase"
    // YawStartConstraint=57344.000000
    // YawEndConstraint=8192.000000
     PitchBone="PassengerGunBarrel"
     PitchUpLimit=18000
     PitchDownLimit=59500
     WeaponFireAttachmentBone="SideGunFirePointf"
     GunnerAttachmentBone="SideGunAttach"
     WeaponFireOffset=5.000000
     RotationsPerSecond=0.800000
     bInstantFire=True
     RedSkin=Texture'MirageTankII.TankRed'
     BlueSkin=Texture'MirageTankII.TankBlue'
     FireInterval=0.100000
     AltFireInterval=0.500000
     AmbientEffectEmitterClass=Class'Onslaught.ONSRVChainGunFireEffect'
     FireSoundClass=Sound'WeaponSounds.BaseFiringSounds.BMiniGunAltFire'
     FireForce="minifireb"
     DamageType=Class'MirageTankV3Omni.DamTypeMirageChainGun'
     DamageMin=18
     DamageMax=18
     AIInfo(0)=(bLeadTarget=True)
     AIInfo(1)=(bLeadTarget=True)
     bUseDynamicLights=True
     Mesh=SkeletalMesh'ONSBPAnimations.ArtillerySideGunMesh'
     AmbientGlow=12
     bShadowCast=True
     bStaticLighting=True
     TraceRange=15000
     bIsRepeatingFF=True
}
