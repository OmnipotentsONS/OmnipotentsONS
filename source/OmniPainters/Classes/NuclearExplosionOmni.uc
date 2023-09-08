class NuclearExplosionOmni extends Emitter;

#exec OBJ LOAD FILE=EpicParticles.utx

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         FadeIn=True
         RespawnDeadParticles=False
         UniformMeshScale=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         ColorScale(1)=(RelativeTime=0.330000,Color=(G=255,R=255))
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=15,G=51,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeInEndTime=0.100000
         MaxParticles=300
         StartLocationOffset=(Z=-64.000000)
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere3'
         MeshSpawning=PTMS_Linear
         MeshScaleRange=(Z=(Min=2.000000,Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=90.000000)
         SizeScale(2)=(RelativeTime=0.800000,RelativeSize=150.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=70.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=4000.000000
         Texture=Texture'EpicParticles.Smoke.Smokepuff2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=9.000000,Max=10.000000)
         StartVelocityRange=(Z=(Min=-1.000000,Max=1.000000))
         StartVelocityRadialRange=(Min=-1.000000,Max=-1.000000)
         VelocityLossRange=(X=(Max=0.100000),Y=(Max=0.100000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(1)=(RelativeTime=0.600000,RelativeVelocity=(X=1200.000000,Y=1200.000000,Z=2500.000000))
         VelocityScale(2)=(RelativeTime=1.000000)
     End Object
     Emitters(0)=SpriteEmitter'OmniPainters.NuclearExplosionOmni.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeIn=True
         RespawnDeadParticles=False
         UniformMeshScale=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         ColorScale(1)=(RelativeTime=0.330000,Color=(G=255,R=255))
         ColorScale(2)=(RelativeTime=0.500000,Color=(B=20,G=100,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeInEndTime=0.100000
         MaxParticles=300
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=64.000000,Max=128.000000)
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere3'
         MeshScaleRange=(Z=(Min=2.000000,Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=90.000000)
         SizeScale(2)=(RelativeTime=0.800000,RelativeSize=150.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=70.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=4000.000000
         Texture=Texture'EpicParticles.Smoke.Smokepuff2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=7.000000,Max=9.000000)
         InitialDelayRange=(Min=0.050000,Max=0.050000)
         StartVelocityRange=(Z=(Min=-1.000000,Max=1.000000))
         StartVelocityRadialRange=(Min=1.000000,Max=1.000000)
         VelocityLossRange=(X=(Max=0.100000),Y=(Max=0.100000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(1)=(RelativeTime=0.600000,RelativeVelocity=(X=1200.000000,Y=1200.000000,Z=2500.000000))
         VelocityScale(2)=(RelativeTime=1.000000)
     End Object
     Emitters(1)=SpriteEmitter'OmniPainters.NuclearExplosionOmni.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseColorScale=True
         FadeIn=True
         RespawnDeadParticles=False
         UniformMeshScale=False
         UseRevolutionScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         ColorScale(1)=(RelativeTime=0.300000)
         ColorScale(2)=(RelativeTime=0.350000,Color=(B=70,G=70,R=70,A=100))
         ColorScale(3)=(RelativeTime=0.400000,Color=(B=50,G=50,R=50,A=255))
         ColorScale(4)=(RelativeTime=1.000000)
         FadeInEndTime=2.000000
         MaxParticles=750
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=128.000000,Max=128.000000)
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere3'
         MeshScaleRange=(Z=(Min=2.000000,Max=2.000000))
         RevolutionScale(0)=(RelativeRevolution=(Z=10.000000))
         RevolutionScale(1)=(RelativeTime=1.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.250000,RelativeSize=100.000000)
         SizeScale(2)=(RelativeTime=0.500000,RelativeSize=200.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=250.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=4000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EpicParticles.Smoke.Smokepuff'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=25.000000,Max=25.000000)
         InitialDelayRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(Z=(Min=-1.000000,Max=1.000000))
         StartVelocityRadialRange=(Min=-0.800000,Max=-1.000000)
         VelocityLossRange=(X=(Max=0.100000),Y=(Max=0.100000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(1)=(RelativeTime=0.330000,RelativeVelocity=(X=1000.000000,Y=1000.000000,Z=2000.000000))
         VelocityScale(2)=(RelativeTime=0.700000,RelativeVelocity=(X=100.000000,Y=100.000000,Z=-100.000000))
         VelocityScale(3)=(RelativeTime=0.700000,RelativeVelocity=(X=100.000000,Y=100.000000,Z=-200.000000))
     End Object
     Emitters(2)=SpriteEmitter'OmniPainters.NuclearExplosionOmni.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseDirectionAs=PTDU_Forward
         UseColorScale=True
         FadeIn=True
         RespawnDeadParticles=False
         UniformMeshScale=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         ColorScale(1)=(RelativeTime=0.330000)
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=15,G=51,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeInEndTime=0.100000
         MaxParticles=300
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=64.000000,Max=128.000000)
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere3'
         MeshScaleRange=(X=(Min=1.500000,Max=1.500000),Y=(Min=1.500000,Max=1.500000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=30.000000)
         SizeScale(2)=(RelativeTime=0.800000,RelativeSize=100.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=50.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=4000.000000
         Texture=Texture'EpicParticles.Smoke.Smokepuff2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=6.000000,Max=8.000000)
         InitialDelayRange=(Min=0.050000,Max=0.050000)
         StartVelocityRange=(Z=(Min=-1.000000,Max=1.000000))
         StartVelocityRadialRange=(Min=-1.000000,Max=-1.000000)
         VelocityLossRange=(X=(Max=0.100000),Y=(Max=0.100000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(1)=(RelativeTime=0.500000,RelativeVelocity=(X=1400.000000,Y=1400.000000,Z=300.000000))
         VelocityScale(2)=(RelativeTime=1.000000)
     End Object
     Emitters(3)=SpriteEmitter'OmniPainters.NuclearExplosionOmni.SpriteEmitter3'

     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'ParticleMeshes.Complex.ExplosionRing'
         UseParticleColor=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=56,G=137,R=197))
         ColorScale(2)=(RelativeTime=0.500000,Color=(B=7,G=177,R=186))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeOutStartTime=6.000000
         FadeInEndTime=0.100000
         MaxParticles=2
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=75.000000)
         StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'EpicParticles.Smoke.FlameGradient'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=6.000000,Max=6.000000)
         InitialDelayRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(4)=MeshEmitter'OmniPainters.NuclearExplosionOmni.MeshEmitter0'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'ParticleMeshes.Complex.ExplosionSphere'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.600000,Color=(B=255,G=255,R=255,A=128))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeOutStartTime=2.500000
         FadeInEndTime=0.100000
         MaxParticles=1
         SpinsPerSecondRange=(X=(Max=3.000000),Y=(Max=3.000000),Z=(Max=3.000000))
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=40.000000)
         StartSizeRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.800000,Max=0.800000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EpicParticles.Smoke.FlameGradient'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=3.000000)
         InitialDelayRange=(Min=1.500000,Max=1.500000)
     End Object
     Emitters(5)=MeshEmitter'OmniPainters.NuclearExplosionOmni.MeshEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.250000,Color=(B=20,G=70,R=255))
         ColorScale(2)=(RelativeTime=0.350000,Color=(R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=2
         SizeScale(0)=(RelativeSize=100.000000)
         SizeScale(1)=(RelativeTime=0.700000,RelativeSize=80.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'EpicParticles.Flares.SoftFlare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=8.000000,Max=8.000000)
         InitialDelayRange=(Min=0.800000,Max=0.800000)
     End Object
     Emitters(6)=SpriteEmitter'OmniPainters.NuclearExplosionOmni.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=50,G=100,R=200))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=55,G=100,R=234))
         FadeOutStartTime=1.000000
         FadeInEndTime=0.100000
         MaxParticles=2
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=25.000000)
         SizeScale(2)=(RelativeTime=0.800000,RelativeSize=1.000000)
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'EpicParticles.Flares.BurnFlare1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(7)=SpriteEmitter'OmniPainters.NuclearExplosionOmni.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=32,R=253))
         FadeOutStartTime=0.600000
         FadeInEndTime=0.200000
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=256.000000,Max=256.000000)
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=80.000000,Max=80.000000),Y=(Min=40.000000,Max=40.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRadialRange=(Min=200.000000,Max=200.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(8)=SpriteEmitter'OmniPainters.NuclearExplosionOmni.SpriteEmitter6'

     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh=StaticMesh'ParticleMeshes.Complex.ExplosionSphere'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.600000,Color=(B=255,G=255,R=255,A=128))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeOutStartTime=2.000000
         MaxParticles=1
         SpinsPerSecondRange=(X=(Max=-3.000000),Y=(Max=-3.000000),Z=(Max=-3.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=50.000000)
         StartSizeRange=(Z=(Min=0.800000,Max=0.800000))
         InitialParticlesPerSecond=50000.000000
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=3.000000)
         InitialDelayRange=(Min=1.200000,Max=1.200000)
     End Object
     Emitters(9)=MeshEmitter'OmniPainters.NuclearExplosionOmni.MeshEmitter2'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     Style=STY_Masked
     bDirectional=True
}
