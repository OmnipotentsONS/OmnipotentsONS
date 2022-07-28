class AuroraSkyMineEffect extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter25
         UseDirectionAs=PTDU_Scale
         UseColorScale=True
         UseRegularSizeScale=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=128,G=255,R=128,A=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=128,G=255,R=128,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=128))
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartSizeRange=(X=(Min=30.000000,Max=50.000000),Y=(Min=30.000000,Max=30.000000))
         Texture=Texture'EpicParticles.Flares.OutSpark03aw'
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(0)=SpriteEmitter'AuroraOmni.AuroraSkyMineEffect.SpriteEmitter25'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=64,G=128))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=64,G=128))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=6
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000))
         Texture=Texture'AW-2004Particles.Energy.BurnFlare'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(1)=SpriteEmitter'AuroraOmni.AuroraSkyMineEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=64,G=128,R=64))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=64,G=128,R=64))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.500000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=50.000000,Max=50.000000))
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
         LifetimeRange=(Min=0.020000,Max=0.020000)
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(2)=SpriteEmitter'AuroraOmni.AuroraSkyMineEffect.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.400000,Color=(B=40,G=80,R=40))
         ColorScale(2)=(RelativeTime=0.600000,Color=(B=40,G=80,R=40))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         SpinsPerSecondRange=(X=(Max=0.020000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.200000)
         StartSizeRange=(X=(Min=40.000000,Max=40.000000))
         Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(3)=SpriteEmitter'AuroraOmni.AuroraSkyMineEffect.SpriteEmitter4'

     bNoDelete=False
     DrawScale=0.010000
     Style=STY_Masked
}
