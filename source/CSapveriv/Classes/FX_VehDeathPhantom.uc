class FX_VehDeathPhantom extends Emitter;

#exec OBJ LOAD FILE="..\Textures\ExplosionTex.utx"
#exec OBJ LOAD FILE="..\StaticMeshes\ONSDeadVehicles-SM.usx"

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter17
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=3
         DetailMode=DM_High
         StartLocationOffset=(Z=100.000000)
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.250000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=400.000000,Max=400.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'ExplosionTex.Framed.exp2_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.700000,Max=0.700000)
         InitialDelayRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'CSAPVerIV.FX_VehDeathPhantom.SpriteEmitter17'

     Begin Object Class=MeshEmitter Name=MeshEmitter26
         StaticMesh=StaticMesh'APVerIV_ST.Phantom_ST.PhantNoseDest'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.950000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(Y=-75.000000,Z=150.000000)
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(Z=1.000000)
         SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=2.000000,Max=2.000000)
         InitialDelayRange=(Min=0.550000,Max=0.550000)
         StartVelocityRange=(Y=(Min=-200.000000,Max=-300.000000),Z=(Min=800.000000,Max=1000.000000))
     End Object
     Emitters(1)=MeshEmitter'CSAPVerIV.FX_VehDeathPhantom.MeshEmitter26'

     Begin Object Class=MeshEmitter Name=MeshEmitter27
         StaticMesh=StaticMesh'APVerIV_ST.Phantom_ST.PhantStab'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-800.000000)
         DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.850000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         MaxParticles=1
         StartLocationOffset=(Y=200.000000)
         SpinCCWorCW=(Y=1.000000,Z=1.000000)
         SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=0.200000,Max=0.200000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=1.000000,Max=1.500000)
         InitialDelayRange=(Min=0.700000,Max=0.700000)
         StartVelocityRange=(Y=(Min=600.000000,Max=800.000000),Z=(Min=300.000000,Max=500.000000))
     End Object
     Emitters(2)=MeshEmitter'CSAPVerIV.FX_VehDeathPhantom.MeshEmitter27'

     Begin Object Class=MeshEmitter Name=MeshEmitter28
         StaticMesh=StaticMesh'APVerIV_ST.Phantom_ST.PhantStabR'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-800.000000)
         DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.850000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         MaxParticles=1
         StartLocationOffset=(Y=-200.000000)
         SpinCCWorCW=(Y=1.000000,Z=1.000000)
         SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=0.200000,Max=0.200000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=1.000000,Max=1.500000)
         InitialDelayRange=(Min=0.700000,Max=0.700000)
         StartVelocityRange=(Y=(Min=-600.000000,Max=-800.000000),Z=(Min=300.000000,Max=500.000000))
     End Object
     Emitters(3)=MeshEmitter'CSAPVerIV.FX_VehDeathPhantom.MeshEmitter28'

     Begin Object Class=MeshEmitter Name=MeshEmitter29
         StaticMesh=StaticMesh'APVerIV_ST.Phantom_ST.PhantRear'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-800.000000)
         DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.850000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         MaxParticles=1
         StartLocationOffset=(X=-300.000000)
         UseRotationFrom=PTRS_Offset
         SpinCCWorCW=(Y=1.000000,Z=0.000000)
         SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=0.200000,Max=0.200000))
         StartSizeRange=(X=(Min=-1.000000,Max=-1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=1.000000,Max=1.500000)
         InitialDelayRange=(Min=0.700000,Max=0.700000)
         StartVelocityRange=(X=(Min=-300.000000,Max=-600.000000),Z=(Min=300.000000,Max=500.000000))
     End Object
     Emitters(4)=MeshEmitter'CSAPVerIV.FX_VehDeathPhantom.MeshEmitter29'

     AutoDestroy=True
     bNoDelete=False
}
