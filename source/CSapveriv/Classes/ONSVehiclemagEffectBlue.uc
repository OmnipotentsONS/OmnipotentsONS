class ONSVehiclemagEffectBlue extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255))
         FadeOutStartTime=0.250000
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=5
         StartLocationOffset=(Z=-50.000000)
         StartLocationRange=(X=(Min=50.000000,Max=50.000000))
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Max=150.000000),Y=(Max=150.000000))
         ScaleSizeByVelocityMultiplier=(X=0.100000,Y=0.005000)
         ScaleSizeByVelocityMax=5000.000000
         InitialParticlesPerSecond=15.000000
         Texture=Texture'VMParticleTextures.buildEffects.PC_buildBorderNew'
         LifetimeRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(Z=(Min=-800.000000,Max=-800.000000))
     End Object
     Emitters(0)=SpriteEmitter'CSAPVerIV.ONSVehiclemagEffectBlue.SpriteEmitter4'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
}
