//-----------------------------------------------------------
//
//-----------------------------------------------------------
class NapalmTankFireEffect extends Emitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.TurretFlash'
         UseMeshBlendMode=False
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(G=153,R=255))
         ColorScale(1)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(X=-4.000000)
         UseRotationFrom=PTRS_Offset
         StartSpinRange=(Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=-0.500000,Max=-0.500000))
         InitialParticlesPerSecond=500.000000
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(1)=MeshEmitter'NapalmTankFireEffect.MeshEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000)
         MaxParticles=3
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=30.000000,Max=40.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Explosions.Fire.Fireball3'
         LifetimeRange=(Min=0.100000,Max=0.200000)
         StartVelocityRange=(X=(Min=20.000000,Max=25.000000))
     End Object
     Emitters(4)=SpriteEmitter'NapalmTankFireEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000)
         MaxParticles=3
         StartLocationOffset=(X=40.000000)
         StartLocationRange=(X=(Max=10.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Explosions.Fire.Fireball3'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=60.000000,Max=75.000000))
     End Object
     Emitters(5)=SpriteEmitter'NapalmTankFireEffect.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000)
         MaxParticles=3
         StartLocationOffset=(X=65.000000)
         StartLocationRange=(X=(Max=10.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Explosions.Fire.Fireball3'
         LifetimeRange=(Min=0.100000,Max=0.200000)
         StartVelocityRange=(X=(Min=20.000000,Max=25.000000))
     End Object
     Emitters(6)=SpriteEmitter'NapalmTankFireEffect.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000)
         MaxParticles=3
         StartLocationOffset=(X=80.000000)
         StartLocationRange=(X=(Max=5.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=5.000000,Max=5.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Explosions.Fire.Fireball3'
         LifetimeRange=(Min=0.100000,Max=0.200000)
         StartVelocityRange=(X=(Min=20.000000,Max=25.000000))
     End Object
     Emitters(7)=SpriteEmitter'NapalmTankFireEffect.SpriteEmitter3'

     AutoDestroy=True
     bNoDelete=False
     AmbientGlow=254
}
