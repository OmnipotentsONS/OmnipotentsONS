//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FalconPlasmaFireEffect extends Emitter;

simulated function PostNetBeginPlay()
{
	local PlayerController PC;
	
	Super.PostNetBeginPlay();
		
	PC = Level.GetLocalPlayerController();
	if ( (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 5000) )
		Emitters[2].Disabled = true;
}	

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter14
         UseDirectionAs=PTDU_Scale
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         ColorScale(0)=(Color=(B=128,G=255,R=55,A=128))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=128,G=255,R=10))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=255,R=10,A=128))
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(X=145.000000)
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=85.000000))
         InitialParticlesPerSecond=8000.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStarRed'
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(0)=SpriteEmitter'FalconV3Omni.FalconPlasmaFireEffect.SpriteEmitter14'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter15
         UseDirectionAs=PTDU_Right
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=128,G=255,R=15))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=7,G=250,R=7))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=50.000000)
         StartSizeRange=(X=(Min=-150.000000,Max=-150.000000),Y=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=500.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaHeadRed'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Max=10.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(1)=SpriteEmitter'FalconV3Omni.FalconPlasmaFireEffect.SpriteEmitter15'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter16
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=128,G=255))
         ColorScale(2)=(RelativeTime=0.500000,Color=(B=128,G=251))
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
     Emitters(2)=SpriteEmitter'FalconV3Omni.FalconPlasmaFireEffect.SpriteEmitter16'

     bNoDelete=False
}