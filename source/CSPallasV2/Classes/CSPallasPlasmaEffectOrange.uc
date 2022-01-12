//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CSPallasPlasmaEffectOrange extends Emitter;

/*
simulated function PostNetBeginPlay()
{
	local PlayerController PC;
	
	Super.PostNetBeginPlay();
		
	PC = Level.GetLocalPlayerController();
	if ( (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 5000) )
		Emitters[1].Disabled = true;
}	
*/

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
         UseDirectionAs=PTDU_Scale
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         ColorScale(0)=(Color=(G=172,R=172))
         ColorScale(1)=(RelativeTime=0.800000,Color=(G=172,R=172))
         ColorScale(2)=(RelativeTime=1.000000,Color=(G=172,R=172))
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(X=150.000000)
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=75.000000))
         InitialParticlesPerSecond=8000.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(0)=SpriteEmitter'CSPallasV2.CSPallasPlasmaEffectOrange.SpriteEmitter8'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter12
         UseDirectionAs=PTDU_Right
         AutomaticInitialSpawning=False
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         UseColorScale=True
         ColorScale(0)=(Color=(G=172,R=172))
         StartLocationOffset=(X=50.000000)
         StartSizeRange=(X=(Min=-150.000000,Max=-150.000000),Y=(Min=50.000000,Max=55.000000))
         InitialParticlesPerSecond=500.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaHeadDesat'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Max=10.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(1)=SpriteEmitter'CSPallasV2.CSPallasPlasmaEffectOrange.SpriteEmitter12'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter13
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=128,G=225,R=225))
         ColorScale(2)=(RelativeTime=0.500000,Color=(G=221,R=221))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         DetailMode=DM_High
         StartLocationOffset=(X=150.000000)
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=25.000000,Max=35.000000))
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=-1000.000000,Max=-1000.000000))
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=2.000000
     End Object
     Emitters(2)=SpriteEmitter'CSPallasV2.CSPallasPlasmaEffectOrange.SpriteEmitter13'

    Begin Object Class=TrailEmitter Name=TrailEmitter0
         TrailShadeType=PTTST_PointLife
         TrailLocation=PTTL_FollowEmitter
         MaxPointsPerTrail=150
         DistanceThreshold=50.000000
         UseCrossedSheets=True
         PointLifeTime=0.800000
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(G=172,R=172))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=172,B=0,R=172))
         Opacity=0.800000
         MaxParticles=1
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=0.800000,Max=0.800000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AW-2004Particles.Weapons.TrailBlur'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=500.000000,Max=500.000000)
     End Object
     Emitters(3)=TrailEmitter'CSPallasV2.CSPallasPlasmaEffectOrange.TrailEmitter0'     

     bNoDelete=False
}
