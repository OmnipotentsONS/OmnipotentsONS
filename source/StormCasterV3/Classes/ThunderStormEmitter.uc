/******************************************************************************
ThunderStormEmitter

Creation date: 2013-09-08 17:06
Last change: $Id$
Copyright � 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class ThunderStormEmitter extends Emitter;


//=============================================================================
// Imports
//=============================================================================

#exec audio import file=Sounds\StormAmbient1.wav
#exec audio import file=Sounds\StormAmbient2.wav
#exec audio import file=Sounds\StormAmbient3.wav
#exec audio import file=Sounds\StormThunder1.wav
#exec audio import file=Sounds\StormThunder2.wav
#exec audio import file=Sounds\StormThunder3.wav
#exec audio import file=Sounds\StormThunder4.wav


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=Clouds
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=100,G=100,R=100,A=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=120,G=120,R=120,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=200,G=200,R=200,A=255))
         FadeOutStartTime=16.000000
         FadeInEndTime=2.000000
         MaxParticles=45
         StartLocationRange=(X=(Min=-1500.000000,Max=1500.000000),Y=(Min=-150.000000,Max=1500.000000))
         StartLocationShape=PTLS_All
         SphereRadiusRange=(Min=200.000000,Max=500.000000)
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=1000.000000,Max=2000.000000))
         SpinsPerSecondRange=(X=(Min=0.010000,Max=0.030000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=1000.000000,Max=2500.000000))
         InitialParticlesPerSecond=6.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EmitterTextures.MultiFrame.smoke_a2'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=17.000000,Max=19.000000)
     End Object
     Emitters(0)=SpriteEmitter'StormCasterV3.ThunderStormEmitter.Clouds'

     Begin Object Class=BeamEmitter Name=NoisyCloudLightnings
         BeamEndPoints(0)=(offset=(X=(Min=-1000.000000,Max=1000.000000),Y=(Min=-1000.000000,Max=1000.000000),Z=(Min=-500.000000,Max=500.000000)))
         DetermineEndPointBy=PTEP_Offset
         BeamTextureUScale=3.000000
         LowFrequencyNoiseRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
         HighFrequencyNoiseRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         NoiseDeterminesEndPoint=True
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         Opacity=0.750000
         MaxParticles=90
         StartLocationRange=(X=(Min=-1500.000000,Max=1500.000000),Y=(Min=-1500.000000,Max=1500.000000),Z=(Min=-500.000000,Max=500.000000))
         StartSizeRange=(X=(Min=10.000000,Max=40.000000))
         Sounds(0)=(Sound=Sound'StormCasterV3.StormAmbient1',Radius=(Min=1500.000000,Max=3000.000000),Pitch=(Min=0.900000,Max=1.100000),Weight=20,Volume=(Min=0.600000,Max=1.000000),Probability=(Min=1.000000,Max=1.000000))
         Sounds(1)=(Sound=Sound'StormCasterV3.StormAmbient2',Radius=(Min=1500.000000,Max=3000.000000),Pitch=(Min=0.900000,Max=1.100000),Weight=20,Volume=(Min=0.600000,Max=1.000000),Probability=(Min=1.000000,Max=1.000000))
         Sounds(2)=(Sound=Sound'StormCasterV3.StormAmbient3',Radius=(Min=1500.000000,Max=3000.000000),Pitch=(Min=0.900000,Max=1.100000),Weight=20,Volume=(Min=0.600000,Max=1.000000),Probability=(Min=1.000000,Max=1.000000))
         Sounds(3)=(Sound=Sound'StormCasterV3.StormThunder1',Radius=(Min=2000.000000,Max=3000.000000),Pitch=(Min=0.800000,Max=1.200000),Weight=1,Volume=(Min=0.100000,Max=0.800000),Probability=(Min=1.000000,Max=1.000000))
         Sounds(4)=(Sound=Sound'StormCasterV3.StormThunder2',Radius=(Min=1000.000000,Max=1700.000000),Pitch=(Min=0.800000,Max=1.200000),Weight=1,Volume=(Min=0.100000,Max=0.600000),Probability=(Min=1.000000,Max=1.000000))
         Sounds(5)=(Sound=Sound'StormCasterV3.StormThunder3',Radius=(Min=1000.000000,Max=1700.000000),Pitch=(Min=0.800000,Max=1.200000),Weight=1,Volume=(Min=0.100000,Max=0.600000),Probability=(Min=1.000000,Max=1.000000))
         Sounds(6)=(Sound=Sound'StormCasterV3.StormThunder4',Radius=(Min=1500.000000,Max=2500.000000),Pitch=(Min=0.800000,Max=1.200000),Weight=1,Volume=(Min=0.100000,Max=0.800000),Probability=(Min=1.000000,Max=1.000000))
         SpawningSound=PTSC_Random
         SpawningSoundIndex=(Max=6.000000)
         SpawningSoundProbability=(Min=1.000000,Max=1.000000)
         InitialParticlesPerSecond=5.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'EpicParticles.Beams.HotBolt03aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.100000,Max=0.200000)
         InitialDelayRange=(Min=3.000000,Max=3.000000)
     End Object
     Emitters(1)=BeamEmitter'StormCasterV3.ThunderStormEmitter.NoisyCloudLightnings'

     Begin Object Class=BeamEmitter Name=SilentCloudLightnings
         BeamEndPoints(0)=(offset=(X=(Min=-1000.000000,Max=1000.000000),Y=(Min=-1000.000000,Max=1000.000000),Z=(Min=-500.000000,Max=500.000000)))
         DetermineEndPointBy=PTEP_Offset
         BeamTextureUScale=3.000000
         LowFrequencyNoiseRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
         HighFrequencyNoiseRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         NoiseDeterminesEndPoint=True
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         Opacity=0.500000
         MaxParticles=170
         StartLocationRange=(X=(Min=-1500.000000,Max=1500.000000),Y=(Min=-1500.000000,Max=1500.000000),Z=(Min=-500.000000,Max=500.000000))
         StartSizeRange=(X=(Min=5.000000,Max=20.000000))
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'EpicParticles.Beams.HotBolt03aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.100000,Max=0.200000)
         InitialDelayRange=(Min=3.000000,Max=3.100000)
     End Object
     Emitters(2)=BeamEmitter'StormCasterV3.ThunderStormEmitter.SilentCloudLightnings'

     AutoDestroy=True
     bNoDelete=False
     LifeSpan=35.000000
}
