class FX_MissileHitGlow extends Emitter;

#exec OBJ LOAD FILE="..\Textures\VMParticleTextures.utx"

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=100,G=176,R=217,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=47,G=168,R=208,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=74,G=232,R=236,A=255))
         Opacity=0.800000
         FadeOutStartTime=0.107470
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=5.000000)
         SizeScale(1)=(RelativeTime=0.170000,RelativeSize=20.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=200.000000
         Texture=Texture'ONSBPTextures.fX.Flair1'
         LifetimeRange=(Min=0.772000,Max=0.772000)
         InitialDelayRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(0)=SpriteEmitter'CSAPVerIV.FX_MissileHitGlow.SpriteEmitter0'

     AutoDestroy=True
     bNoDelete=False
}
