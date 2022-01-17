class NapalmTankFireNew extends Emitter;

var float time;

simulated function PostBeginPlay()
{
          super.postbeginplay();
          time = level.TimeSeconds;
          Emitters[0].Disabled=false;
          Emitters[1].Disabled=false;
          Emitters[2].Disabled=false;
          SetTimer(8.0,False);

}

simulated function timer()
{
          Emitters[0].Disabled=true;
          Emitters[1].Disabled=true;
          Emitters[2].Disabled=true;
          destroy();
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=200.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         ParticlesPerSecond=10.000000
         InitialParticlesPerSecond=10.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.200000)
     End Object
     Emitters(0)=SpriteEmitter'NapalmTankFireNew.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeOut=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=200.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         DetailMode=DM_High
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         ParticlesPerSecond=10.000000
         InitialParticlesPerSecond=10.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.200000)
     End Object
     Emitters(1)=SpriteEmitter'NapalmTankFireNew.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         FadeOut=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=200.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         DetailMode=DM_SuperHigh
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         ParticlesPerSecond=10.000000
         InitialParticlesPerSecond=10.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.200000)
     End Object
     Emitters(2)=SpriteEmitter'NapalmTankFireNew.SpriteEmitter3'

     bNoDelete=False
     bHardAttach=True
}
