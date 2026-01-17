//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FireBladeOmniCannon extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx


var float MinAim;
//var class<Emitter>      mTracerClass;
//var() editinline Emitter mTracer;
//var() float				mTracerInterval;
//var() float				mTracerPullback;
//var() float				mTracerMinDistance;
//var() float				mTracerSpeed;
//var float               mLastTracerTime;
// no tracers it isn't hit scan. pooty 1/2025

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStarRed');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadRed');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadBlue');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    L.AddPrecacheMaterial(Material'EpicParticles.Flares.FlashFlare1');
    L.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaFlare');
    L.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStarRed');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadRed');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadBlue');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    Level.AddPrecacheMaterial(Material'EpicParticles.Flares.FlashFlare1');
    Level.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaFlare');
    Level.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');

    Super.UpdatePrecacheMaterials();
}
/*
simulated function Destroyed()
{
//	if (mTracer != None)
//		mTracer.Destroy();

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
*/

function byte BestMode()
{
	if ( Vehicle(Instigator.Controller.Enemy) != None
	     && (Instigator.Controller.Enemy.bCanFly || Instigator.Controller.Enemy.IsA('ONSHoverCraft')) && FRand() < 0.75 )
		return 1;
	else
		return 0;
}

state ProjectileFireMode
{

	function AltFire(Controller C)
	{
		local FireBladeOmniMissile M;
		//local Vehicle V, Best;
		//local float CurAim, BestAim;

		M = FireBladeOmniMissile(SpawnProjectile(AltFireProjectileClass, True));
//		if (M != None)
//		{
//			if (AIController(Instigator.Controller) != None)
//			{
//				V = Vehicle(Instigator.Controller.Enemy);
//				if (V != None && (V.bCanFly || V.IsA('ONSHoverCraft')) && Instigator.FastTrace(V.Location, Instigator.Location))
//					M.SetHomingTarget(V);
//			}
//			else
//			{
//				BestAim = MinAim;
//				for (V = Level.Game.VehicleList; V != None; V = V.NextVehicle)
//					if ((V.bCanFly || V.IsA('ONSHoverCraft')) && V != Instigator && Instigator.GetTeamNum() != V.GetTeamNum())
//					{
//						CurAim = Normal(V.Location - WeaponFireLocation) dot vector(WeaponFireRotation);
//						if (CurAim > BestAim && Instigator.FastTrace(V.Location, Instigator.Location))
//						{
//							Best = V;
//							BestAim = CurAim;
//						}
//					}
//				if (Best != None)
//					M.SetHomingTarget(Best);
//			}
//		}
	}
}

defaultproperties
{
     MinAim=0.900000
//     mTracerClass=Class'FireBladeOmni.FireBladeOmniTracer'
//     mTracerInterval=0.050000
//     mTracerPullback=150.000000
//     mTracerSpeed=15000.000000
     YawBone="PlasmaGunBarrel"
     PitchBone="PlasmaGunBarrel"
     PitchUpLimit=18000
     PitchDownLimit=49153
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     WeaponFireOffset=85.000000
     DualFireOffset=50.000000
     RotationsPerSecond=1.000000
     bInstantRotation=True
     bDoOffsetTrace=True
//     bAmbientFireSound=True
//     Do not continuously loop the firing sound
     bIsRepeatingFF=True
     Spread=0.005000
     FireInterval=0.4
     AltFireInterval=4.000000
     AmbientEffectEmitterClass=Class'Onslaught.ONSRVChainGunFireEffect'
     FireSoundClass=Sound'FireBladeAudioOmni.CannonFire2'
     AltFireSoundClass=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'
     AmbientSoundScaling=1.300000
     FireForce="minifireb"
     AltFireForce="Laser01"
     DamageType=Class'FireBladeOmni.DamTypeFireBladeOmniCannon'
//     DamageMin=30
//     DamageMax=36
//     TraceRange=17000.000000
//   Its not hitscan those don't matter!
     ProjectileClass=Class'FireBladeOmni.FireBladeOmniRocketProj'
     AltFireProjectileClass=Class'FireBladeOmni.FireBladeOmniBomb'
     AIInfo(0)=(bInstantHit=True,aimerror=750.000000)
     AIInfo(1)=(bLeadTarget=True,aimerror=400.000000,RefireRate=0.500000)
     CullDistance=8000.000000
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
