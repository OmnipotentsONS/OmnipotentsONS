/******************************************************************************
Visuals for the ion blast part of the effects.

Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class StormCasterBlastEmitter extends Emitter;


//=============================================================================
// Imports
//=============================================================================

#exec obj load file="..\Textures\EpicParticles.utx"
#exec obj load file="..\Textures\EmitterTextures.utx"

#exec texture import file=Textures\BeamGradient.tga
#exec audio import file=Sounds\StormCasterBlast.wav


/**
Play the ion blast sound.
*/
event PreBeginPlay()
{
	Super.PreBeginPlay();
	PlaySound(Sound'StormCasterBlast');
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     Begin Object Class=BeamEmitter Name=IonBeam
         BeamEndPoints(0)=(offset=(Z=(Min=100000.000000,Max=100000.000000)))
         DetermineEndPointBy=PTEP_Offset
         RotatingSheets=1
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=64,G=32,R=32))
         ColorScale(2)=(RelativeTime=0.250000,Color=(B=255,G=170,R=170))
         ColorScale(3)=(RelativeTime=0.400000,Color=(B=64,G=32,R=32))
         ColorScale(4)=(RelativeTime=1.000000)
         MaxParticles=1
         StartLocationOffset=(Z=-10000.000000)
         SizeScale(1)=(RelativeTime=0.150000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.250000,RelativeSize=16.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=20.000000)
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'StormCasterV3.BeamGradient'
         SecondsBeforeInactive=0.000000
     End Object
     Emitters(0)=BeamEmitter'StormCasterV3.StormCasterBlastEmitter.IonBeam'

     Begin Object Class=SpriteEmitter Name=IonBeamBlast
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorMultiplierRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=2.000000,Max=2.000000))
         FadeOutStartTime=1.000000
         MaxParticles=1
         StartLocationOffset=(Z=35000.000000)
         SizeScale(1)=(RelativeTime=0.725000,RelativeSize=1.500000)
         SizeScale(2)=(RelativeTime=0.750000,RelativeSize=5.000000)
         SizeScale(3)=(RelativeTime=0.775000,RelativeSize=1.500000)
         SizeScale(4)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=1700.000000,Max=1700.000000),Y=(Min=1700.000000,Max=1700.000000),Z=(Min=1700.000000,Max=1700.000000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'EpicParticles.Flares.FlashFlare1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.250000,Max=1.250000)
         StartVelocityRange=(Z=(Min=-35000.000000,Max=-35000.000000))
     End Object
     Emitters(1)=SpriteEmitter'StormCasterV3.StormCasterBlastEmitter.IonBeamBlast'

     Begin Object Class=SpriteEmitter Name=IonBeamParticles
         UseColorScale=True
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         LowDetailFactor=0.300000
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=64,G=64,R=64))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=0.500000,Color=(B=64,G=64,R=64))
         ColorScale(4)=(RelativeTime=1.000000)
         MaxParticles=1000
         DetailMode=DM_High
         StartLocationRange=(Z=(Min=5000.000000,Max=50000.000000))
         StartLocationShape=PTLS_All
         SphereRadiusRange=(Max=2000.000000)
         InitialParticlesPerSecond=2000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'EmitterTextures.Flares.EFlareB2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=3.000000)
         InitialDelayRange=(Min=0.250000,Max=0.250000)
         StartVelocityRange=(Z=(Min=-15000.000000,Max=-10000.000000))
         VelocityLossRange=(Z=(Min=2.000000,Max=2.200000))
     End Object
     Emitters(2)=SpriteEmitter'StormCasterV3.StormCasterBlastEmitter.IonBeamParticles'

     Begin Object Class=BeamEmitter Name=BeamLightnings
         BeamEndPoints(0)=(offset=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=-1000.000000,Max=1000.000000)))
         DetermineEndPointBy=PTEP_Offset
         BeamTextureUScale=3.000000
         LowFrequencyNoiseRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-300.000000,Max=300.000000))
         HighFrequencyNoiseRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         NoiseDeterminesEndPoint=True
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         LowDetailFactor=0.300000
         Opacity=0.500000
         MaxParticles=1000
         StartLocationRange=(Z=(Max=50000.000000))
         StartLocationShape=PTLS_All
         SphereRadiusRange=(Max=2000.000000)
         StartSizeRange=(X=(Min=5.000000,Max=20.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'EpicParticles.Beams.HotBolt03aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.100000,Max=0.200000)
         InitialDelayRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(3)=BeamEmitter'StormCasterV3.StormCasterBlastEmitter.BeamLightnings'

     bNoDelete=False
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=5.000000
     SoundOcclusion=OCCLUSION_None
     TransientSoundVolume=1.000000
     TransientSoundRadius=5000.000000
}
