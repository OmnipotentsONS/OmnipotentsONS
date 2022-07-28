class AuroraComboEffect extends Emitter;

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
         ColorScale(0)=(Color=(B=128,G=255,R=32))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=100,G=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         DetailMode=DM_High
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(1)=(RelativeTime=2.000000,RelativeSize=5.500000)
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(0)=MeshEmitter'AuroraOmni.AuroraComboEffect.MeshEmitter3'

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
         ColorScale(0)=(Color=(B=175,G=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=150,G=200))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         DetailMode=DM_High
         StartSpinRange=(Y=(Min=0.250000,Max=0.250000),Z=(Min=0.250000,Max=0.250000))
         SizeScale(1)=(RelativeTime=3.000000,RelativeSize=5.500000)
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(1)=MeshEmitter'AuroraOmni.AuroraComboEffect.MeshEmitter4'

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
         ColorScale(0)=(Color=(B=40,G=175))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=150,G=200))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         DetailMode=DM_High
         StartSpinRange=(Y=(Min=0.250000,Max=0.250000))
         SizeScale(1)=(RelativeTime=3.000000,RelativeSize=5.500000)
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(2)=MeshEmitter'AuroraOmni.AuroraComboEffect.MeshEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter7
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=171,G=253,R=114))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=84,G=203,R=158))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=3
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=180.000000,Max=300.000000))
         InitialParticlesPerSecond=10.000000
         Texture=Texture'AW-2004Particles.Fire.BlastMark'
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(3)=SpriteEmitter'AuroraOmni.AuroraComboEffect.SpriteEmitter7'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=178,G=230,R=117))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=100,G=150,R=81))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=3
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.600000)
         SizeScale(1)=(RelativeTime=2.000000,RelativeSize=6.000000)
         StartSizeRange=(X=(Min=280.000000,Max=400.000000))
         InitialParticlesPerSecond=10.000000
         Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
         LifetimeRange=(Min=0.400000,Max=0.400000)
     End Object
     Emitters(4)=SpriteEmitter'AuroraOmni.AuroraComboEffect.SpriteEmitter6'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         RespawnDeadParticles=False
         UniformSize=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=128,G=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=128,G=255,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=100
         DetailMode=DM_High
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=16.000000,Max=16.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         ScaleSizeByVelocityMultiplier=(X=0.030000)
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRadialRange=(Min=-100.000000,Max=-200.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=0.250000,RelativeVelocity=(X=1.500000,Y=1.500000,Z=1.500000))
         VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=2.000000,Y=2.000000,Z=2.000000))
     End Object
     Emitters(5)=SpriteEmitter'AuroraOmni.AuroraComboEffect.SpriteEmitter8'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     AmbientGlow=127
}
