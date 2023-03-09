/**
WVDraco.NapalmRocketFlightEffects

Creation date: 2013-11-12 09:29
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class NapalmRocketFlightEffects extends Emitter;


function Kill()
{
	Emitters[0].Disabled = True;
	Super.Kill();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter8
         StaticMesh=StaticMesh'WVDraco.NapalmRocketM'
         SpinParticles=True
         AutomaticInitialSpawning=False
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(Z=(Min=-0.200000,Max=-0.200000))
         StartSizeRange=(X=(Min=8.000000,Max=8.000000),Y=(Min=5.000000,Max=5.000000),Z=(Min=5.000000,Max=5.000000))
         InitialParticlesPerSecond=100.000000
         LifetimeRange=(Min=100.000000,Max=100.000000)
     End Object
     Emitters(0)=MeshEmitter'WVDraco.NapalmRocketFlightEffects.MeshEmitter8'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter9
         FadeOut=True
         FadeIn=True
         UniformSize=True
         ColorMultiplierRange=(X=(Max=2.000000),Y=(Min=0.500000,Max=0.700000),Z=(Min=0.100000,Max=0.300000))
         FadeOutStartTime=0.100000
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         StartLocationOffset=(X=-22.000000)
         SpinsPerSecondRange=(X=(Min=0.700000,Max=1.200000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=3.000000,Max=5.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'EmitterTextures.Flares.EFlareOY2'
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(1)=SpriteEmitter'WVDraco.NapalmRocketFlightEffects.SpriteEmitter9'

     Begin Object Class=BeamEmitter Name=BeamEmitter8
         BeamEndPoints(0)=(offset=(X=(Min=-20.000000,Max=-30.000000)))
         DetermineEndPointBy=PTEP_Offset
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         FadeOut=True
         FadeIn=True
         ColorMultiplierRange=(Y=(Min=0.300000,Max=0.500000),Z=(Min=0.100000,Max=0.300000))
         FadeOutStartTime=0.100000
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         StartLocationOffset=(X=-20.000000)
         StartSizeRange=(X=(Min=5.000000,Max=8.000000))
         Texture=Texture'AW-2004Particles.Weapons.SoftFade'
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(2)=BeamEmitter'WVDraco.NapalmRocketFlightEffects.BeamEmitter8'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter14
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         AddVelocityFromOwner=True
         Acceleration=(Z=50.000000)
         Opacity=0.400000
         FadeOutStartTime=0.200000
         MaxParticles=200
         StartLocationOffset=(X=-24.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=20.000000,Max=25.000000))
         Texture=Texture'EmitterTextures.MultiFrame.smokelight_a'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=2.000000,Max=2.500000)
         StartVelocityRange=(X=(Min=-200.000000,Max=-200.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         AddVelocityMultiplierRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=0.100000,Max=0.100000),Z=(Min=0.100000,Max=0.100000))
     End Object
     Emitters(3)=SpriteEmitter'WVDraco.NapalmRocketFlightEffects.SpriteEmitter14'

     bNoDelete=False
     AmbientGlow=32
}
