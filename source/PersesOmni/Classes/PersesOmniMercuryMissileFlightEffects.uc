/**
PersesMercuryMissileFlightEffects

Creation date: 2013-12-12 13:41
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniMercuryMissileFlightEffects extends PersesOmniTrailFLightEffects;


#exec audio import file=Sounds\MercuryMissileFlight.wav
//exec obj load file=WVMercuryMissileResources.usx 
#exec obj load file=WVMercuryMissiles_Tex.utx

//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MMissileMesh
         //StaticMesh=StaticMesh'MercuryM'  
         StaticMesh=StaticMesh'WeaponStaticMesh.RocketProj'
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(Z=(Min=-0.500000,Max=-0.500000))
         StartSpinRange=(Z=(Max=1.000000))
         StartSizeRange=(X=(Min=2.000000,Max=2.000000))
         InitialParticlesPerSecond=100.000000
         LifetimeRange=(Min=100.000000,Max=100.000000)
         Texture=Texture'WVMercuryMissiles_Tex.Stuff.MercuryMissileTexBase'
     End Object
     Emitters(0)=MeshEmitter'PersesOmni.PersesOmniMercuryMissileFlightEffects.MMissileMesh'


     Begin Object Class=TrailEmitter Name=MissileTrail
         TrailShadeType=PTTST_PointLife
         TrailLocation=PTTL_FollowEmitter
         MaxPointsPerTrail=400
         DistanceThreshold=10.000000
         PointLifeTime=0.600000
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorMultiplierRange=(Y=(Min=0.300000,Max=0.300000),Z=(Min=0.300000,Max=0.300000))
         MaxParticles=1
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=2000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'WVMercuryMissiles_Tex.Particles.MercurySmokeLine'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=10.000000,Max=10.000000)
     End Object
     Emitters(1)=TrailEmitter'PersesOmni.PersesOmniMercuryMissileFlightEffects.MissileTrail'

     Begin Object Class=SpriteEmitter Name=ThrusterFlare
         FadeOut=True
         FadeIn=True
         UniformSize=True
         ColorMultiplierRange=(X=(Max=2.000000),Y=(Min=0.500000,Max=0.700000),Z=(Min=0.100000,Max=0.300000))
         FadeOutStartTime=0.100000
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         StartLocationOffset=(X=-19.000000)
         SpinsPerSecondRange=(X=(Min=0.700000,Max=1.200000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=6.000000,Max=7.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'EmitterTextures.Flares.EFlareOY2'
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(2)=SpriteEmitter'PersesOmni.PersesOmniMercuryMissileFlightEffects.ThrusterFlare'

     Begin Object Class=BeamEmitter Name=ThrusterFlame
         BeamEndPoints(0)=(offset=(X=(Min=-60.000000,Max=-75.000000)))
         DetermineEndPointBy=PTEP_Offset
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         FadeOut=True
         FadeIn=True
         ColorMultiplierRange=(Y=(Min=0.300000,Max=0.500000),Z=(Min=0.100000,Max=0.300000))
         FadeOutStartTime=0.100000
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=6
         StartLocationOffset=(X=-17.000000)
         StartSizeRange=(X=(Min=6.000000,Max=8.000000))
         Texture=Texture'AW-2004Particles.Weapons.SoftFade'
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(3)=BeamEmitter'PersesOmni.PersesOmniMercuryMissileFlightEffects.ThrusterFlame'

     AmbientSound=Sound'PersesOmni.MercuryMissileFlight'
     SoundVolume=160
     SoundRadius=100.000000
}
