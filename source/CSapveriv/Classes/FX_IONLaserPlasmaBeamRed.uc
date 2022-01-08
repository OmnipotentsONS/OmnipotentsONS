//=============================================================================
// FX_LaserPlasmaBeam
//=============================================================================

class FX_IONLaserPlasmaBeamRed extends Emitter
	placeable;

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter1
         DetermineEndPointBy=PTEP_DynamicDistance
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(G=26,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSizeRange=(X=(Min=150.000000,Max=150.000000),Y=(Min=1.000000,Max=1.000000))
         InitialParticlesPerSecond=500.000000
         Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=0.001000,Max=0.001000))
     End Object
     Emitters(0)=BeamEmitter'CSAPVerIV.FX_IONLaserPlasmaBeamRed.BeamEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter79
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.100000,Color=(G=102,R=255))
         ColorScale(2)=(RelativeTime=0.500000,Color=(R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         ColorMultiplierRange=(Y=(Max=2.000000),Z=(Min=0.670000))
         Opacity=0.670000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationRange=(X=(Max=16.000000))
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.050000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=3.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=7.000000)
         StartSizeRange=(X=(Min=33.000000,Max=67.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.600000,Max=0.600000)
     End Object
     Emitters(1)=SpriteEmitter'CSAPVerIV.FX_IONLaserPlasmaBeamRed.SpriteEmitter79'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter80
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(X=500.000000)
         ColorScale(0)=(Color=(G=100,R=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         ColorMultiplierRange=(Y=(Max=1.500000),Z=(Min=0.670000))
         Opacity=0.670000
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         StartLocationRange=(X=(Max=32.000000))
         StartLocationShape=PTLS_All
         SphereRadiusRange=(Max=32.000000)
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
         StartSizeRange=(X=(Min=10.000000,Max=150.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'EpicParticles.Flares.HotSpot'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.600000,Max=0.600000)
         StartVelocityRange=(X=(Max=750.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=-400.000000,Max=400.000000))
     End Object
     Emitters(2)=SpriteEmitter'CSAPVerIV.FX_IONLaserPlasmaBeamRed.SpriteEmitter80'

     AutoDestroy=True
     bNoDelete=False
}
