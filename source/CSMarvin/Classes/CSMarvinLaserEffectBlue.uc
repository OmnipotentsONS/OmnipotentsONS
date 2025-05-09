class CSMarvinLaserEffectBlue extends Emitter;

simulated function PostNetBeginPlay()
{
	local PlayerController PC;
	
	Super.PostNetBeginPlay();
		
	PC = Level.GetLocalPlayerController();
	if ( (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 5000) )
		Emitters[2].Disabled = true;
}	

DefaultProperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter9
        UseDirectionAs=PTDU_Scale
        UseColorScale=True
        ColorScale(0)=(Color=(B=255,G=128))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=128))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=128))
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        StartLocationOffset=(X=150.000000)
        SpinParticles=True
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=75.000000))
        UniformSize=True
        InitialParticlesPerSecond=8000.000000
        Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
        LifetimeRange=(Min=0.200000,Max=0.200000)
        Name="SpriteEmitter9"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter9'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter10
        UseDirectionAs=PTDU_Right
        ColorScale(0)=(Color=(B=15,G=9,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=7,G=1,R=250))
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartLocationOffset=(X=50.000000)
        StartSizeRange=(X=(Min=-150.000000,Max=-150.000000),Y=(Min=50.000000,Max=50.000000))
        InitialParticlesPerSecond=500.000000
        AutomaticInitialSpawning=False
        Texture=Texture'AW-2004Particles.Weapons.PlasmaHeadBlue'
        LifetimeRange=(Min=0.200000,Max=0.200000)
        StartVelocityRange=(X=(Max=10.000000))
        VelocityLossRange=(X=(Min=1.000000,Max=1.000000))
        Name="SpriteEmitter10"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter10'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter11
        UseColorScale=True
        ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=128))
        ColorScale(2)=(RelativeTime=0.500000,Color=(B=255,G=128))
        ColorScale(3)=(RelativeTime=1.000000)
        CoordinateSystem=PTCS_Relative
        MaxParticles=20
        StartLocationOffset=(X=150.000000)
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=25.000000,Max=35.000000))
        UniformSize=True
        Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        DetailMode=DM_High
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=-1000.000000,Max=-1000.000000))
        WarmupTicksPerSecond=1.000000
        RelativeWarmupTime=2.000000
        Name="SpriteEmitter11"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter11'
    Begin Object Class=TrailEmitter Name=TrailEmitter0
         TrailShadeType=PTTST_PointLife
         TrailLocation=PTTL_FollowEmitter
         MaxPointsPerTrail=150
         DistanceThreshold=20.000000
         UseCrossedSheets=True
         PointLifeTime=0.800000
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=128))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=251,G=128))
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
     Emitters(3)=TrailEmitter'CSMarvin.CSMarvinLaserEffectBlue.TrailEmitter0'         
    bNoDelete=False
}
