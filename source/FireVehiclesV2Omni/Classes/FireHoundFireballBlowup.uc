class FireHoundFireballBlowup extends Emitter;

#exec OBJ LOAD FILE=EpicParticles.utx
#exec OBJ LOAD FILE=ParticleMeshes.usx

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
         SphereRadiusRange=(Min=36.000000,Max=36.000000)
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.400000)
         SizeScale(1)=(RelativeTime=2.000000,RelativeSize=4.000000)
         StartSizeRange=(X=(Min=40.000000,Max=500.000000),Y=(Min=40.000000,Max=260.000000),Z=(Min=40.000000,Max=260.000000))
         Texture=Texture'EpicParticles.Smoke.Smokepuff2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.300000,Max=0.300000)
     End Object
     Emitters(0)=SpriteEmitter'FireVehiclesV2Omni.FireHoundFireballBlowup.SpriteEmitter1'

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
         SphereRadiusRange=(Min=36.000000,Max=36.000000)
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=20.000000,Max=500.000000),Y=(Min=20.000000,Max=500.000000),Z=(Max=790.000000))
         InitialParticlesPerSecond=80.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EpicParticles.Smoke.Smokepuff'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.700000,Max=0.700000)
     End Object
     Emitters(1)=SpriteEmitter'FireVehiclesV2Omni.FireHoundFireballBlowup.SpriteEmitter2'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'ParticleMeshes.Complex.ExplosionSphere'
         UseParticleColor=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.500000
         MaxParticles=1
         SizeScale(0)=(RelativeSize=0.250000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=0.250000,Max=0.250000),Y=(Min=0.250000,Max=0.250000),Z=(Max=0.250000))
         InitialParticlesPerSecond=1.000000
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.250000)
     End Object
     Emitters(2)=MeshEmitter'FireVehiclesV2Omni.FireHoundFireballBlowup.MeshEmitter1'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     Style=STY_Masked
     bDirectional=True
}
