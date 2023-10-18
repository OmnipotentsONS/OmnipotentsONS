class FireHoundComboEffect extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter3
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.HellB_Ring'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         Disabled=True
         Backup_Disabled=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=140,R=140))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=170,R=170))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         DetailMode=DM_High
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.500000)
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(0)=MeshEmitter'FireVehiclesV2Omni.FireHoundComboEffect.MeshEmitter3'

     Begin Object Class=MeshEmitter Name=MeshEmitter4
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.HellB_Ring'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         Disabled=True
         Backup_Disabled=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=175,R=140))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=150,R=150))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         DetailMode=DM_High
         StartSpinRange=(Y=(Min=0.250000,Max=0.250000),Z=(Min=0.250000,Max=0.250000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.500000)
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(1)=MeshEmitter'FireVehiclesV2Omni.FireHoundComboEffect.MeshEmitter4'

     Begin Object Class=MeshEmitter Name=MeshEmitter5
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.HellB_Ring'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         Disabled=True
         Backup_Disabled=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=175,R=175))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=150,R=150))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         DetailMode=DM_High
         StartSpinRange=(Y=(Min=0.250000,Max=0.250000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.500000)
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(2)=MeshEmitter'FireVehiclesV2Omni.FireHoundComboEffect.MeshEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter7
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.100000,Color=(G=171,R=171))
         ColorScale(2)=(RelativeTime=0.800000,Color=(G=158,R=203))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=3
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=80.000000,Max=120.000000))
         InitialParticlesPerSecond=10.000000
         Texture=Texture'AW-2004Explosions.Fire.Fireball3'
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(3)=SpriteEmitter'FireVehiclesV2Omni.FireHoundComboEffect.SpriteEmitter7'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.100000,Color=(R=202))
         ColorScale(2)=(RelativeTime=0.800000,Color=(R=206))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=3
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=120.000000,Max=180.000000))
         InitialParticlesPerSecond=10.000000
         Texture=Texture'AW-2004Explosions.Fire.Fireball3'
         LifetimeRange=(Min=0.400000,Max=0.400000)
     End Object
     Emitters(4)=SpriteEmitter'FireVehiclesV2Omni.FireHoundComboEffect.SpriteEmitter6'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         RespawnDeadParticles=False
         UniformSize=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         ColorScale(1)=(RelativeTime=0.100000,Color=(G=128,R=200))
         ColorScale(2)=(RelativeTime=0.800000,Color=(G=190,R=200))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=100
         DetailMode=DM_High
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=8.000000,Max=8.000000)
         StartSizeRange=(X=(Min=5.000000,Max=5.000000))
         ScaleSizeByVelocityMultiplier=(X=0.030000)
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'AW-2004Explosions.Fire.Fireball3'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRadialRange=(Min=-100.000000,Max=-200.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=0.250000,RelativeVelocity=(X=1.500000,Y=1.500000,Z=1.500000))
         VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=2.000000,Y=2.000000,Z=2.000000))
     End Object
     Emitters(5)=SpriteEmitter'FireVehiclesV2Omni.FireHoundComboEffect.SpriteEmitter8'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     AmbientGlow=127
}
