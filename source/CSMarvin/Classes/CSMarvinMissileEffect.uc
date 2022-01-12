//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CSMarvinMissileEffect extends Emitter;

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
    //////
    /// dots
    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
	UseColorScale=True
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=10,G=170,R=5))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=10,G=217,R=5))
        //FadeOutStartTime=1.300000
        //FadeOut=True
        FadeInEndTime=0.250000
        FadeIn=True
        //MaxParticles=15
        MaxParticles=300
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=16.000000,Max=16.000000)
        //SphereRadiusRange=(Min=8.000000,Max=8.000000)
        RevolutionsPerSecondRange=(Z=(Min=0.200000,Max=0.500000))
        RevolutionScale(0)=(RelativeRevolution=(Z=2.000000))
        RevolutionScale(1)=(RelativeTime=0.600000)
        RevolutionScale(2)=(RelativeTime=1.000000,RelativeRevolution=(Z=2.000000))
        SpinsPerSecondRange=(X=(Max=4.000000))
        //StartSizeRange=(X=(Min=4.000000,Max=4.000000),Y=(Min=4.000000,Max=4.000000),Z=(Min=8.000000,Max=8.000000))
        StartSizeRange=(X=(Min=4.000000,Max=8.000000),Y=(Min=4.000000,Max=8.000000),Z=(Min=8.000000,Max=16.000000))
        //UniformSize=True
        Texture=Texture'EpicParticles.Flares.HotSpot'
        //Texture=Texture'AW-2004Particles.Energy.EclipseCircle'

        //LifetimeRange=(Min=1.600000,Max=1.600000)
        LifetimeRange=(Min=1.600000,Max=2.600000)
        //StartVelocityRadialRange=(Min=-20.000000,Max=-20.000000)
        StartVelocityRadialRange=(Min=-30.000000,Max=-30.000000)
        VelocityLossRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=1.000000,Max=1.000000))
        GetVelocityDirectionFrom=PTVD_AddRadial
        UseVelocityScale=True
        VelocityScale(0)=(RelativeVelocity=(X=2.000000,Y=2.000000,Z=2.000000))
        VelocityScale(1)=(RelativeTime=0.600000)
        VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=-2.000000,Y=-2.000000,Z=2.000000))
        LowDetailFactor=+1.0
        Name="SpriteEmitter7"
        Acceleration=(Z=10)
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter2'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter222
	UseColorScale=True
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=0,G=10,R=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=0,G=10,R=255))
        //FadeOutStartTime=1.300000
        //FadeOut=True
        FadeInEndTime=0.250000
        FadeIn=True
        //MaxParticles=15
        MaxParticles=300
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=16.000000,Max=16.000000)
        //SphereRadiusRange=(Min=8.000000,Max=8.000000)
        //SphereRadiusRange=(Min=0.100000,Max=0.100000)
        RevolutionsPerSecondRange=(Z=(Min=0.200000,Max=0.500000))
        RevolutionScale(0)=(RelativeRevolution=(Z=2.000000))
        RevolutionScale(1)=(RelativeTime=0.600000)
        RevolutionScale(2)=(RelativeTime=1.000000,RelativeRevolution=(Z=2.000000))
        SpinsPerSecondRange=(X=(Max=4.000000))
        //StartSizeRange=(X=(Min=4.000000,Max=4.000000),Y=(Min=4.000000,Max=4.000000),Z=(Min=8.000000,Max=8.000000))
        StartSizeRange=(X=(Min=4.000000,Max=8.000000),Y=(Min=4.000000,Max=8.000000),Z=(Min=8.000000,Max=16.000000))
        //UniformSize=True
        Texture=Texture'EpicParticles.Flares.HotSpot'
        //Texture=Texture'AW-2004Particles.Energy.EclipseCircle'

        //LifetimeRange=(Min=1.600000,Max=1.600000)
        LifetimeRange=(Min=1.600000,Max=2.600000)
        //StartVelocityRadialRange=(Min=-20.000000,Max=-20.000000)
        StartVelocityRadialRange=(Min=-30.000000,Max=-30.000000)
        VelocityLossRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=1.000000,Max=1.000000))
        GetVelocityDirectionFrom=PTVD_AddRadial
        UseVelocityScale=True
        VelocityScale(0)=(RelativeVelocity=(X=2.000000,Y=2.000000,Z=2.000000))
        VelocityScale(1)=(RelativeTime=0.600000)
        VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=-2.000000,Y=-2.000000,Z=2.000000))
        LowDetailFactor=+1.0
        Name="SpriteEmitter222"
        Acceleration=(Z=10)
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter222'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter223
	UseColorScale=True
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=10,R=0))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=10,R=0))
        //FadeOutStartTime=1.300000
        //FadeOut=True
        FadeInEndTime=0.250000
        FadeIn=True
        //MaxParticles=15
        //MaxParticles=150
        MaxParticles=300
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=16.000000,Max=16.000000)
        //SphereRadiusRange=(Min=8.000000,Max=8.000000)
        //SphereRadiusRange=(Min=1.000000,Max=1.000000)
        RevolutionsPerSecondRange=(Z=(Min=0.200000,Max=0.500000))
        RevolutionScale(0)=(RelativeRevolution=(Z=2.000000))
        RevolutionScale(1)=(RelativeTime=0.600000)
        RevolutionScale(2)=(RelativeTime=1.000000,RelativeRevolution=(Z=2.000000))
        SpinsPerSecondRange=(X=(Max=4.000000))
        //StartSizeRange=(X=(Min=4.000000,Max=4.000000),Y=(Min=4.000000,Max=4.000000),Z=(Min=8.000000,Max=8.000000))
        StartSizeRange=(X=(Min=4.000000,Max=8.000000),Y=(Min=4.000000,Max=8.000000),Z=(Min=8.000000,Max=16.000000))
        //UniformSize=True
        Texture=Texture'EpicParticles.Flares.HotSpot'
        //Texture=Texture'AW-2004Particles.Energy.EclipseCircle'

        //LifetimeRange=(Min=1.600000,Max=1.600000)
        LifetimeRange=(Min=1.600000,Max=2.600000)
        //StartVelocityRadialRange=(Min=-20.000000,Max=-20.000000)
        StartVelocityRadialRange=(Min=-30.000000,Max=-30.000000)
        VelocityLossRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=1.000000,Max=1.000000))
        GetVelocityDirectionFrom=PTVD_AddRadial
        UseVelocityScale=True
        VelocityScale(0)=(RelativeVelocity=(X=2.000000,Y=2.000000,Z=2.000000))
        VelocityScale(1)=(RelativeTime=0.600000)
        VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=-2.000000,Y=-2.000000,Z=2.000000))
        LowDetailFactor=+1.0
        Name="SpriteEmitter223"
        Acceleration=(Z=10)
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter223'



    // end dots

////////////////

     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
        StartLocationShape=PTLS_Sphere
        RotationOffset=(Pitch=16384)
         UseDirectionAs=PTDU_Scale
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         ColorScale(0)=(Color=(B=10,G=172,R=5))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=10,G=172,R=5))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=10,G=172,R=5))
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         //StartLocationOffset=(X=150.000000)
         StartSpinRange=(X=(Max=1.000000))
         //StartSizeRange=(X=(Min=75.000000))
         StartSizeRange=(X=(Min=300.000000))
         InitialParticlesPerSecond=8000.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
        //Texture=Texture'ONSBPTextures.fX.Flair1'
        //Texture=Texture'AW-2004Particles.Weapons.BoloBlob'


         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(3)=SpriteEmitter'CSMarvin.CSMarvinMissileEffect.SpriteEmitter8'

    /*
    Begin Object Class=SpriteEmitter Name=SpriteEmitter9
        UseColorScale=True
        RespawnDeadParticles=False
        Backup_Disabled=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        Acceleration=(Z=20.000000)
        ColorScale(0)=(Color=(B=10,G=172,R=5,A=255))
        ColorScale(1)=(RelativeTime=0.500000,Color=(B=10,G=172,R=5,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=10,G=172,R=5))
        MaxParticles=1000
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=8.000000)
        SpinsPerSecondRange=(X=(Max=0.050000))
        StartSpinRange=(X=(Min=0.550000,Max=0.450000))
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=0.150000,RelativeSize=2.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.000000)
        StartSizeRange=(X=(Min=10.000000,Max=15.000000))
        ParticlesPerSecond=150.000000
        InitialParticlesPerSecond=150.000000
        //DrawStyle=PTDS_AlphaBlend
        DrawStyle=PTDS_Translucent
        //Texture=AW-2004Particles.Fire.MuchSmoke1
        Texture=AW-2004Particles.Weapons.HardSpot

        //TextureUSubdivisions=4
        //TextureVSubdivisions=4
        LifetimeRange=(Min=0.800000,Max=1.500000)
        StartVelocityRange=(X=(Min=-5.000000,Max=-5.000000),Y=(Min=-5.000000,Max=-5.000000),Z=(Min=-5.000000,Max=-5.000000))
        Name="SpriteEmitter9"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter9'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter12
         UseDirectionAs=PTDU_Right
         AutomaticInitialSpawning=False
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         UseColorScale=True
         ColorScale(0)=(Color=(G=172,R=172))
         StartLocationOffset=(X=50.000000)
         //StartSizeRange=(X=(Min=-150.000000,Max=-150.000000),Y=(Min=50.000000,Max=55.000000))
         StartSizeRange=(X=(Min=-600.000000,Max=-600.000000),Y=(Min=400.000000,Max=500.000000))
         InitialParticlesPerSecond=500.000000
         //Texture=Texture'AW-2004Particles.Weapons.PlasmaHeadDesat'
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar2'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Max=10.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(1)=SpriteEmitter'CSMarvin.CSMarvinMissileEffect.SpriteEmitter12'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter43
         UseDirectionAs=PTDU_Normal
         AutomaticInitialSpawning=False
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         UseColorScale=True
         ColorScale(0)=(Color=(G=172,R=172))
         StartLocationOffset=(X=50.000000)
         RotationNormal=(Z=1)
         RotationOffset=(Yaw=16384)
         //StartSizeRange=(X=(Min=-150.000000,Max=-150.000000),Y=(Min=50.000000,Max=55.000000))
         StartSizeRange=(X=(Min=-600.000000,Max=-600.000000),Y=(Min=400.000000,Max=500.000000))
         InitialParticlesPerSecond=500.000000
         //Texture=Texture'AW-2004Particles.Weapons.PlasmaHeadDesat'
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar2'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Max=10.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(4)=SpriteEmitter'CSMarvin.CSMarvinMissileEffect.SpriteEmitter43'


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
     Emitters(2)=SpriteEmitter'CSMarvin.CSMarvinMissileEffect.SpriteEmitter13'
     */

    Begin Object Class=TrailEmitter Name=TrailEmitter0
         TrailShadeType=PTTST_PointLife
         TrailLocation=PTTL_FollowEmitter
         //MaxPointsPerTrail=150
         MaxPointsPerTrail=300
         DistanceThreshold=300.000000
         //DistanceThreshold=30.000000
         UseCrossedSheets=True
         PointLifeTime=0.800000
         //PointLifeTime=1.600000
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=10,G=172,R=5))
         ColorScale(1)=(RelativeTime=0.5,Color=(B=255,G=10,R=0))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=0,G=10,B=0,R=255))
         Opacity=0.900000
         MaxParticles=1
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=0.800000,Max=0.800000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AW-2004Particles.Weapons.TrailBlur'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=500.000000,Max=500.000000)
     End Object
     Emitters(4)=TrailEmitter'CSMarvin.CSMarvinMissileEffect.TrailEmitter0'     

     bNoDelete=False

    bStasis=false
    bDirectional=true
     bhardAttach=true
     bBlockActors=false
     Physics=PHYS_Trailer
     RemoteRole=ROLE_None
}
