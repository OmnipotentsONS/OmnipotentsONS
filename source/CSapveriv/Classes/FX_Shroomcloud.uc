class FX_Shroomcloud extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=128))
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=51,G=152,R=200))
         ColorScale(2)=(RelativeTime=0.300000,Color=(B=48,G=91,R=222))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=60
         StartLocationRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000),Z=(Min=-32.000000,Max=32.000000))
         StartLocationShape=PTLS_All
         SphereRadiusRange=(Min=185.000000,Max=185.000000)
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleBomb'
         MeshScaleRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=4.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=11.500000)
         StartSizeRange=(X=(Min=20.000000,Max=40.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
         Texture=Texture'EpicParticles.Smoke.Smokepuff2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Max=5.000000)
     End Object
     Emitters(0)=SpriteEmitter'CSAPVerIV.FX_Shroomcloud.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseColorScale=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(G=255,R=255,A=32))
         ColorScale(1)=(RelativeTime=0.400000,Color=(B=47,G=80,R=179,A=255))
         ColorScale(2)=(RelativeTime=0.900000,Color=(A=80))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeInEndTime=0.200000
         CoordinateSystem=PTCS_Relative
         MaxParticles=25
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=222.000000,Max=222.000000)
         SizeScale(0)=(RelativeSize=5.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=20.000000,Max=40.000000),Y=(Min=20.000000,Max=40.000000))
         InitialParticlesPerSecond=80.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EpicParticles.Smoke.Smokepuff'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=9.000000,Max=12.000000)
     End Object
     Emitters(1)=SpriteEmitter'CSAPVerIV.FX_Shroomcloud.SpriteEmitter2'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     bNetInitialRotation=True
     Physics=PHYS_Projectile
     RemoteRole=ROLE_SimulatedProxy
     bFixedRotationDir=True
     RotationRate=(Pitch=-11000)
}
