//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CSMarvinMissileTrailEffectRed extends Emitter;

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
    /*
    //////
    /// dots
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
    Emitters(0)=SpriteEmitter'SpriteEmitter222'

*/


    // end dots

////////////////

     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
        StartLocationShape=PTLS_Sphere
        RotationOffset=(Pitch=16384)
         UseDirectionAs=PTDU_Scale
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         ColorScale(0)=(Color=(B=10,G=30,R=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=10,G=30,R=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=30,G=50,R=255))
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         //StartLocationOffset=(X=150.000000)
         StartSpinRange=(X=(Max=1.000000))
         //StartSizeRange=(X=(Min=75.000000))
         StartSizeRange=(X=(Min=30.000000))
         InitialParticlesPerSecond=8000.000000
         //Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
        //Texture=Texture'ONSBPTextures.fX.Flair1'
        //Texture=Texture'AW-2004Particles.Weapons.BoloBlob'
        Texture=Texture'XEffects.Skins.pcl_ball'


         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter8'


    Begin Object Class=TrailEmitter Name=TrailEmitter0
         TrailShadeType=PTTST_PointLife
         TrailLocation=PTTL_FollowEmitter
         //MaxPointsPerTrail=150
         MaxPointsPerTrail=150
         //DistanceThreshold=1300.000000
         DistanceThreshold=30.000000
         UseCrossedSheets=True
         //PointLifeTime=0.800000
         PointLifeTime=0.800000
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=2,G=30,R=255))
         ColorScale(1)=(RelativeTime=0.5,Color=(B=2,G=30,R=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=40,G=30,R=255))
         Opacity=0.900000
         MaxParticles=1
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=0.800000,Max=0.800000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AW-2004Particles.Weapons.TrailBlur'
         //Texture=Texture'AW-2004Particles.Weapons.TankTrail'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=200.000000,Max=200.000000)
     End Object
     Emitters(2)=TrailEmitter'TrailEmitter0'     

     bNoDelete=False

    bStasis=false
    bDirectional=true
     bhardAttach=true
     bBlockActors=false
     Physics=PHYS_Trailer
     RemoteRole=ROLE_None
}
