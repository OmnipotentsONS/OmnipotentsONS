/**
PersesHomingMissileFlightEffects

Creation date: 2013-12-12 13:41
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniHomingMissileFlightEffects extends PersesOmniRocketFlightEffects;



//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MMissileMesh
         //StaticMesh=StaticMesh'HomingM'
         StaticMesh=StaticMesh'VMWeaponsSM.AVRiLGroup.AVRiLprojectileSM'
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(Z=(Min=-0.100000,Max=-0.100000))
         StartSpinRange=(Z=(Max=1.000000))
         StartSizeRange=(X=(Min=0.2000,Max=0.2000),Y=(Min=0.2000,Max=0.2000),Z=(Min=0.2000,Max=0.2000))
         InitialParticlesPerSecond=100.000000
         LifetimeRange=(Min=100.000000,Max=100.000000)
     End Object
     Emitters(0)=MeshEmitter'PersesOmni.PersesOmniHomingMissileFlightEffects.MMissileMesh'

     Begin Object Class=SpriteEmitter Name=ThrusterFlare
         FadeOut=True
         FadeIn=True
         UniformSize=True
         ColorMultiplierRange=(X=(Max=2.000000),Y=(Min=0.500000,Max=0.700000),Z=(Min=0.100000,Max=0.300000))
         FadeOutStartTime=0.100000
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         StartLocationOffset=(X=-14.500000)
         SpinsPerSecondRange=(X=(Min=0.700000,Max=1.200000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=5.000000,Max=6.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'EmitterTextures.Flares.EFlareOY2'
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(1)=SpriteEmitter'PersesOmni.PersesOmniHomingMissileFlightEffects.ThrusterFlare'

     Begin Object Class=BeamEmitter Name=ThrusterFlame
         BeamEndPoints(0)=(offset=(X=(Min=-20.000000,Max=-25.000000)))
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
         MaxParticles=4
         StartLocationOffset=(X=-13.000000)
         StartSizeRange=(X=(Min=3.000000,Max=4.000000))
         Texture=Texture'AW-2004Particles.Weapons.SoftFade'
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(2)=BeamEmitter'PersesOmni.PersesOmniHomingMissileFlightEffects.ThrusterFlame'

     Begin Object Class=SpriteEmitter Name=SmokeTrail
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         AddVelocityFromOwner=True
         Acceleration=(Z=50.000000)
         Opacity=0.300000
         MaxParticles=200
         StartLocationOffset=(X=-20.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=20.000000,Max=25.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Fire.MuchSmoke1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=2.000000,Max=2.500000)
         StartVelocityRange=(X=(Min=-200.000000,Max=-200.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         AddVelocityMultiplierRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=0.100000,Max=0.100000),Z=(Min=0.100000,Max=0.100000))
     End Object
     Emitters(3)=SpriteEmitter'PersesOmni.PersesOmniHomingMissileFlightEffects.SmokeTrail'

}
