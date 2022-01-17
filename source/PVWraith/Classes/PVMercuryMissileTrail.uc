//=============================================================================
// MercuryMissileTrail
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Smoke trail for mercury missiles.
//=============================================================================


class PVMercuryMissileTrail extends Emitter notplaceable;


/**
Make sure the trail emitter really reaches the explosion location and fade out
the thruster flame, then kill the emitter.
*/
function Kill()
{
	TrailEmitter(Emitters[1]).DistanceThreshold = 1;
	Emitters[2].FadeOut = True;
	GotoState('Killed');
}

/**
Make sure the trailer no longer moves while it dies. Wait a tick first, so
TrailEmitter can reach the explosion location.
*/
state Killed
{
Begin:
	Sleep(0.0);
	SetPhysics(PHYS_None);
	SetBase(None);
	SetOwner(None);
	Sleep(0.0);
	Super.Kill();
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=ThrusterSmoke
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         LowDetailFactor=0.500000
         Acceleration=(X=-2000.000000)
         ColorScale(0)=(Color=(G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(R=192,A=160))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.800000
         CoordinateSystem=PTCS_Relative
         MaxParticles=50
         StartSpinRange=(Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.500000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=8.000000,Max=8.000000),Y=(Min=8.000000,Max=8.000000),Z=(Min=8.000000,Max=8.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'PVWraith.Particles.MercuryExplosionSprites'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(X=(Min=-500.000000,Max=-500.000000))
         WarmupTicksPerSecond=20.000000
         RelativeWarmupTime=0.500000
     End Object
     Emitters(0)=SpriteEmitter'PVWraith.PVMercuryMissileTrail.ThrusterSmoke'

     Begin Object Class=TrailEmitter Name=MissileTrail
         TrailShadeType=PTTST_PointLife
         TrailLocation=PTTL_FollowEmitter
         MaxPointsPerTrail=400
         DistanceThreshold=10.000000
         PointLifeTime=0.600000
         RespawnDeadParticles=False
         Disabled=True
         Backup_Disabled=True
         AutomaticInitialSpawning=False
         ColorMultiplierRange=(Y=(Min=0.600000,Max=0.600000),Z=(Min=0.300000,Max=0.300000))
         MaxParticles=1
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=2000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'PVWraith.Particles.MercurySmokeLine'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=10.000000,Max=10.000000)
     End Object
     Emitters(1)=TrailEmitter'PVWraith.PVMercuryMissileTrail.MissileTrail'

     Begin Object Class=MeshEmitter Name=ThrusterFlame
         StaticMesh=StaticMesh'PVWraith.SMeshes.MercuryThrusterMesh'
         UseParticleColor=True
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         ColorScale(0)=(Color=(B=96,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=96,G=128,R=255,A=160))
         ColorScale(2)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(X=11.000000)
         StartSpinRange=(X=(Min=0.500000,Max=0.500000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.200000,RelativeSize=1.200000)
         StartSizeRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.150000,Max=0.150000)
         WarmupTicksPerSecond=20.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(2)=MeshEmitter'PVWraith.PVMercuryMissileTrail.ThrusterFlame'

     AutoDestroy=True
     bNoDelete=False
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     AmbientGlow=128
}
