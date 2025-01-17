//=============================================================================
// FX_LaserIonCore
//=============================================================================

class FX_IONLaserIonCoreRed extends Emitter
	placeable;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter82
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.100000,Color=(R=255))
         ColorScale(2)=(RelativeTime=0.500000,Color=(G=26,R=243))
         ColorScale(3)=(RelativeTime=1.000000)
         ColorMultiplierRange=(Y=(Max=2.000000))
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=75.000000,Max=75.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AW-2004Particles.Weapons.GrenExpl'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.500000,Max=1.500000)
     End Object
     Emitters(0)=SpriteEmitter'CSAPVerIV.FX_IONLaserIonCoreRed.SpriteEmitter82'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter83
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.100000,Color=(G=102,R=255))
         ColorScale(2)=(RelativeTime=0.500000,Color=(G=26,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=500.000000,Max=500.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.500000,Max=1.500000)
     End Object
     Emitters(1)=SpriteEmitter'CSAPVerIV.FX_IONLaserIonCoreRed.SpriteEmitter83'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter84
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         Acceleration=(X=-1000.000000)
         ColorScale(1)=(RelativeTime=0.150000,Color=(G=51,R=255))
         ColorScale(2)=(RelativeTime=0.670000,Color=(G=26,R=243))
         ColorScale(3)=(RelativeTime=1.000000)
         ColorMultiplierRange=(Y=(Max=2.000000))
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=64.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=5.000000))
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.250000,Max=1.000000)
         StartVelocityRange=(X=(Min=-500.000000,Max=-500.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=3.000000
     End Object
     Emitters(2)=SpriteEmitter'CSAPVerIV.FX_IONLaserIonCoreRed.SpriteEmitter84'

     bNoDelete=False
     bDirectional=True
}
