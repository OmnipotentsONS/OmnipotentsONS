/******************************************************************************
LightningImpactEmitterGround

Creation date: 2013-09-12 10:26
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class LightningImpactEmitterGround extends Emitter;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=TrailEmitter Name=ImpactSparks
         TrailShadeType=PTTST_PointLife
         MaxPointsPerTrail=10
         DistanceThreshold=5.000000
         UseCrossedSheets=True
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         ColorMultiplierRange=(X=(Min=0.500000,Max=0.700000),Y=(Min=0.700000,Max=0.900000))
         Opacity=0.500000
         StartLocationRange=(X=(Min=-20.000000,Max=-20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         StartLocationShape=PTLS_All
         SphereRadiusRange=(Max=15.000000)
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=15.000000,Max=25.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'AW-2004Particles.Energy.AngryBeam'
         LifetimeRange=(Min=0.500000,Max=2.000000)
         StartVelocityRadialRange=(Min=-500.000000,Max=-700.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(0)=TrailEmitter'StormCasterV3.LightningImpactEmitterGround.ImpactSparks'

     Begin Object Class=SpriteEmitter Name=ImpactRing
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1.000000,Z=0.000000)
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorMultiplierRange=(X=(Min=0.700000,Max=0.500000),Y=(Min=0.800000))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=140.000000,Max=140.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'XEffectMat.Link.grey_ring'
         LifetimeRange=(Min=0.300000,Max=0.400000)
     End Object
     Emitters(1)=SpriteEmitter'StormCasterV3.LightningImpactEmitterGround.ImpactRing'

     Begin Object Class=SpriteEmitter Name=ImpactSmoke
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=100.000000)
         ColorMultiplierRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.300000
         MaxParticles=20
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=3.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         InitialParticlesPerSecond=20.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Weapons.DustSmoke'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.500000,Max=2.500000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         WarmupTicksPerSecond=10.000000
         RelativeWarmupTime=0.100000
     End Object
     Emitters(2)=SpriteEmitter'StormCasterV3.LightningImpactEmitterGround.ImpactSmoke'

     AutoDestroy=True
     bNoDelete=False
     LifeSpan=5.000000
}
