class FX_ExplosionLg extends Emitter;

#exec OBJ LOAD FILE=EpicParticles.utx

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         Acceleration=(Z=15.000000)
         ColorScale(0)=(Color=(B=51,G=152,R=200))
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=48,G=91,R=222))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=40
         StartLocationRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000),Z=(Min=-32.000000,Max=32.000000))
         StartLocationShape=PTLS_All
         SphereRadiusRange=(Min=48.000000,Max=48.000000)
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleBomb'
         MeshScaleRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=20.000000,Max=320.000000),Y=(Min=20.000000,Max=160.000000),Z=(Min=20.000000,Max=160.000000))
         Texture=Texture'EpicParticles.Smoke.Smokepuff2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.300000,Max=0.300000)
     End Object
     Emitters(0)=SpriteEmitter'CSAdvancedArmor.FX_ExplosionLg.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=150.000000)
         ColorScale(0)=(Color=(G=255,R=255,A=128))
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=47,G=80,R=179,A=255))
         ColorScale(2)=(RelativeTime=0.600000,Color=(A=80))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=20
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=48.000000,Max=48.000000)
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=20.000000,Max=320.000000),Y=(Min=20.000000,Max=320.000000),Z=(Max=600.000000))
         InitialParticlesPerSecond=80.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EpicParticles.Smoke.Smokepuff'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.700000,Max=0.700000)
     End Object
     Emitters(1)=SpriteEmitter'CSAdvancedArmor.FX_ExplosionLg.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         Acceleration=(Z=15.000000)
         ColorScale(0)=(Color=(B=51,G=152,R=200))
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=48,G=91,R=222))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=40
         StartLocationRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000),Z=(Min=-32.000000,Max=32.000000))
         StartLocationShape=PTLS_All
         SphereRadiusRange=(Min=48.000000,Max=48.000000)
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleBomb'
         MeshScaleRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=4.000000)
         SizeScale(1)=(RelativeTime=1.500000,RelativeSize=8.000000)
         StartSizeRange=(X=(Min=80.000000,Max=16.000000),Y=(Min=80.000000,Max=160.000000),Z=(Min=80.000000,Max=160.000000))
         Texture=Texture'EpicParticles.Smoke.Smokepuff2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.600000,Max=0.600000)
     End Object
     Emitters(2)=SpriteEmitter'CSAdvancedArmor.FX_ExplosionLg.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=150.000000)
         ColorScale(0)=(Color=(G=255,R=255,A=128))
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=47,G=80,R=179,A=255))
         ColorScale(2)=(RelativeTime=0.600000,Color=(A=80))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=20
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=48.000000,Max=48.000000)
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=4.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=8.000000)
         StartSizeRange=(X=(Min=80.000000,Max=160.000000),Y=(Min=80.000000,Max=160.000000))
         InitialParticlesPerSecond=80.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EpicParticles.Smoke.Smokepuff'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.800000,Max=0.800000)
     End Object
     Emitters(3)=SpriteEmitter'CSAdvancedArmor.FX_ExplosionLg.SpriteEmitter4'

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
         FadeOutStartTime=1.000000
         FadeInEndTime=0.100000
         MaxParticles=1
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=9.000000)
         StartSizeRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.800000,Max=0.800000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EpicParticles.Smoke.FlameGradient'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(4)=MeshEmitter'CSAdvancedArmor.FX_ExplosionLg.MeshEmitter1'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     Style=STY_Masked
     bDirectional=True
}
