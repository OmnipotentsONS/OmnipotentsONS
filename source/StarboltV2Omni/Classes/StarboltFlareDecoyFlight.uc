class StarboltFlareDecoyFlight extends ONSDecoyFlight;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter11324
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=147,G=217,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=147,G=217,R=255))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=50.000000,Max=55.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(0)=SpriteEmitter'StarboltV2Omni.StarboltFlareDecoyFlight.SpriteEmitter11324'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter11325
         UseColorScale=True
         UseRevolution=True
         UseRevolutionScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseVelocityScale=True
         ColorScale(0)=(Color=(B=147,G=217,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=40,G=180,R=255))
         MaxParticles=30
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=2.000000,Max=5.000000)
         RevolutionsPerSecondRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
         RevolutionScale(0)=(RelativeRevolution=(X=1.000000,Y=1.000000,Z=1.000000))
         RevolutionScale(1)=(RelativeTime=0.500000,RelativeRevolution=(X=1.000000,Y=1.000000,Z=1.000000))
         RevolutionScale(2)=(RelativeTime=1.000000)
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=10.000000,Max=30.000000))
         Texture=Texture'AW-2004Particles.Weapons.HardSpot'
         LifetimeRange=(Min=0.200000,Max=0.500000)
         StartVelocityRadialRange=(Min=150.000000,Max=300.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=1.000000)
     End Object
     Emitters(1)=SpriteEmitter'StarboltV2Omni.StarboltFlareDecoyFlight.SpriteEmitter11325'

     LifeSpan=15.000000
}
