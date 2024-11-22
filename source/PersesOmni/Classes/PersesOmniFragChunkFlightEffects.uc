/**
PersesFragChunkFlightEffects

Creation date: 2013-12-14 08:50
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniFragChunkFlightEffects extends PersesOmniTrailFLightEffects;



//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=MeshEmitter Name=ChunkMesh
         StaticMesh=StaticMesh'WeaponStaticMesh.FlakChunk'
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         SpinsPerSecondRange=(X=(Max=-1.000000),Y=(Max=-1.000000),Z=(Max=-1.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=100.000000
         LifetimeRange=(Min=100.000000,Max=100.000000)
     End Object
     Emitters(0)=MeshEmitter'PersesOmni.PersesOmniFragChunkFlightEffects.ChunkMesh'

     Begin Object Class=TrailEmitter Name=ChunkTrail
         TrailShadeType=PTTST_PointLife
         TrailLocation=PTTL_FollowEmitter
         MaxPointsPerTrail=400
         DistanceThreshold=10.000000
         PointLifeTime=0.200000
         AutomaticInitialSpawning=False
         MaxParticles=1
         StartSizeRange=(X=(Min=5.000000,Max=5.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'VMParticleTextures.VEHICLEtrailsGROUP.trailsEmitterORANGEtex'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=10.000000,Max=10.000000)
     End Object
     Emitters(1)=TrailEmitter'PersesOmni.PersesOmniFragChunkFlightEffects.ChunkTrail'

     Begin Object Class=SpriteEmitter Name=ChunkGlow
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UniformSize=True
         ColorMultiplierRange=(Z=(Min=0.000000,Max=0.000000))
         Opacity=0.500000
         FadeOutStartTime=0.150000
         FadeInEndTime=0.150000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         Texture=Texture'AW-2004Particles.Weapons.HardSpot'
         LifetimeRange=(Min=0.300000,Max=0.300000)
         WarmupTicksPerSecond=10.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(2)=SpriteEmitter'PersesOmni.PersesOmniFragChunkFlightEffects.ChunkGlow'

     Skins(0)=Texture'AW-2004Particles.Energy.PowerSwirl'
}
