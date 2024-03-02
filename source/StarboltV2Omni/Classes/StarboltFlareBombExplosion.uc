class StarboltFlareBombExplosion extends NewExplosionA
	placeable;

defaultproperties
{
     ExplosionTextures(0)=Texture'ONSBPTextures.fX.ExploTrans'
     ExplosionTextures(1)=Texture'ONSBPTextures.fX.ExploTrans'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter5171
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.700000
         FadeOutStartTime=0.119000
         MaxParticles=3
         StartLocationRange=(Z=(Min=0.500000,Max=0.500000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeSize=1.010000)
         SizeScale(1)=(RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=0.250000,RelativeSize=3.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=150.000000,Max=150.000000),Y=(Min=120.000000,Max=120.000000),Z=(Min=120.000000,Max=120.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'ONSBPTextures.fX.ExploTrans'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter5171'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5172
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=-250.000000,Max=250.000000)
         StartSpinRange=(X=(Min=1.055000,Max=2.355000))
         SizeScale(0)=(RelativeTime=3.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=175.000000,Max=175.000000))
         InitialParticlesPerSecond=1500.000000
         Texture=Texture'AW-2004Explosions.Fire.Part_explode2'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter5172'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5173
         UseColorScale=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         UseVelocityScale=True
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=192,G=192,R=192))
         FadeInEndTime=0.500000
         MaxParticles=45
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=225.000000,Max=375.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.050000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.750000)
         StartSizeRange=(X=(Min=165.000000,Max=185.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=150.000000,Max=150.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.500000,Max=2.000000)
         InitialDelayRange=(Min=0.150000,Max=0.150000)
         StartVelocityRadialRange=(Min=-300.000000,Max=-300.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=0.125000,RelativeVelocity=(X=0.200000,Y=0.200000,Z=0.200000))
         VelocityScale(2)=(RelativeTime=1.000000)
     End Object
     Emitters(2)=SpriteEmitter'SpriteEmitter5173'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5174
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000)
         Opacity=0.700000
         MaxParticles=13
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=20.000000,Max=40.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.750000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.750000)
         StartSizeRange=(X=(Min=280.000000,Max=580.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Fire.GrenadeTest'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.350000,Max=0.450000)
     End Object
     Emitters(3)=SpriteEmitter'SpriteEmitter5174'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5175
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UniformSize=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-400.000000)
         ColorScale(0)=(Color=(B=179,G=236,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=20,G=97,R=167))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.100000
         MaxParticles=40
         DetailMode=DM_SuperHigh
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=4.000000,Max=10.000000))
         ScaleSizeByVelocityMultiplier=(X=0.006000)
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'AW-2004Particles.Weapons.HardSpot'
         LifetimeRange=(Min=0.750000,Max=1.250000)
         StartVelocityRange=(X=(Min=-1200.000000,Max=1200.000000),Y=(Min=-1200.000000,Max=1200.000000),Z=(Min=400.000000,Max=1400.000000))
     End Object
     Emitters(4)=SpriteEmitter'SpriteEmitter5175'

}
