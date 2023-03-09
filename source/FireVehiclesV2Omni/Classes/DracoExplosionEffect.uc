/******************************************************************************
DracoExplosionEffect

Creation date: 2012-10-12 15:46
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DracoExplosionEffect extends FX_SpaceFighter_Explosion;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=600.000000)
         MaxParticles=200
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=50.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.800000,Max=1.200000)
         StartVelocityRadialRange=(Min=-1000.000000,Max=-300.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(8)=SpriteEmitter'WVDraco.DracoExplosionEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=500.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=102,G=102,R=102,A=255))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.500000
         MaxParticles=100
         AddLocationFromOtherEmitter=0
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=50.000000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.700000,RelativeSize=2.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Max=200.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EmitterTextures.MultiFrame.smoke_a2'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.500000)
         InitialDelayRange=(Min=0.500000,Max=0.700000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         AddVelocityFromOtherEmitter=0
     End Object
     Emitters(9)=SpriteEmitter'WVDraco.DracoExplosionEffect.SpriteEmitter1'

}
