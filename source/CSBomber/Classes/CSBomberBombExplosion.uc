
//class CSBomberBombExplosion extends RocketExplosion;
class CSBomberBombExplosion extends Emitter;

defaultproperties
{
    DrawScale=8.0

        Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=30.000000)
        ColorScale(1)=(RelativeTime=0.200000,Color=(A=128))
        ColorScale(2)=(RelativeTime=0.300000,Color=(A=128))
        ColorScale(3)=(RelativeTime=1.000000)
        MaxParticles=2
        AddLocationFromOtherEmitter=1
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=3.000000)
        SizeScale(1)=(RelativeTime=3.000000,RelativeSize=6.000000)
        InitialParticlesPerSecond=500.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=EpicParticles.Smoke.Smokepuff2
        LifetimeRange=(Min=0.500000,Max=0.500000)
        Name="SpriteEmitter0"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter4
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        UseVelocityScale=True
        Acceleration=(Z=50.000000)
        ColorScale(0)=(Color=(B=150,G=150,R=150))
        ColorScale(1)=(RelativeTime=0.100000,Color=(B=150,G=150,R=150,A=128))
        ColorScale(2)=(RelativeTime=0.500000,Color=(B=150,G=150,R=150,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=150,G=150,R=150))
        MaxParticles=3
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=1.000000,Max=1.000000)
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=9.000000)
        SizeScale(1)=(RelativeTime=3.000000,RelativeSize=18.000000)
        StartSizeRange=(X=(Min=90.000000,Max=90.000000))
        InitialParticlesPerSecond=500.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=AW-2004Particles.Weapons.SmokePanels2
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRadialRange=(Min=-50.000000,Max=-100.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.100000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(X=0.050000,Y=0.050000,Z=0.050000))
        VelocityScale(3)=(RelativeTime=1.000000)
        Name="SpriteEmitter4"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter4'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        Acceleration=(Z=25.000000)
        ColorScale(1)=(RelativeTime=0.100000,Color=(A=128))
        ColorScale(2)=(RelativeTime=0.500000,Color=(A=128))
        ColorScale(3)=(RelativeTime=1.000000)
        MaxParticles=3
        DetailMode=DM_High
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=1.000000,Max=1.000000)
        SpinsPerSecondRange=(X=(Max=0.020000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=9.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=15.000000)
        StartSizeRange=(X=(Min=90.000000,Max=90.000000))
        InitialParticlesPerSecond=500.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=AW-2004Particles.Weapons.SmokePanels2
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=1.500000,Max=1.500000)
        StartVelocityRadialRange=(Min=-10.000000,Max=-20.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.100000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(X=0.050000,Y=0.050000,Z=0.050000))
        VelocityScale(3)=(RelativeTime=1.000000)
        Name="SpriteEmitter2"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter2'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.6500000,Color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        MaxParticles=3
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=16.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.750000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=4.500000)
        InitialParticlesPerSecond=500.000000
        Texture=AW-2004Particles.Fire.GrenadeTest
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=0.350000,Max=0.350000)
        InitialDelayRange=(Min=0.050000,Max=0.050000)
        Name="SpriteEmitter1"
    End Object
    Emitters(3)=SpriteEmitter'SpriteEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=22,G=137,R=241))
        ColorScale(1)=(RelativeTime=0.300000,Color=(G=64,R=192))
        ColorScale(2)=(RelativeTime=1.000000)
        Opacity=0.500000
        MaxParticles=3
        DetailMode=DM_High
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=8.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.750000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
        StartSizeRange=(X=(Min=150.000000,Max=150.000000))
        InitialParticlesPerSecond=500.000000
        Texture=AW-2004Particles.Energy.AirBlast
        LifetimeRange=(Min=0.300000,Max=0.300000)
        Name="SpriteEmitter3"
    End Object
    Emitters(4)=SpriteEmitter'SpriteEmitter3'
    AutoDestroy=True
    bNoDelete=False
}

/*
#exec OBJ LOAD File=WeaponSounds.uax

simulated function PostBeginPlay()
{
	local PlayerController PC;

	PC = Level.GetLocalPlayerController();
	if ( (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 5000) ) 
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
	else 
	{
		Spawn(class'RocketSmokeRing');
		if ( Level.bDropDetail )
			LightRadius = 7;	
	}
}

defaultproperties 
{
    DrawScale=2.5
    Style=STY_Additive
    mParticleType=PL_Sprite
    mDirDev=(X=1.0,Y=1.0,Z=1.0)
    mPosDev=(X=0.0,Y=0.0,Z=0.0) 
    mLifeRange(0)=0.5
    mLifeRange(1)=1.0
    mSpeedRange(0)=3.0
    mSpeedRange(1)=10.0
    mSizeRange(0)=100.0
    mSizeRange(1)=200.0
    mMassRange(0)=0.0
    mMassRange(1)=0.0
    mSpinRange(0)=-20.0
    mSpinRange(1)=20.0
    mStartParticles=4
    mMaxParticles=4
    mAttenuate=true
    mRandOrient=true
    mRegen=false
    mRandTextures=false
    LifeSpan=2.0
    bForceAffected=false

    bDynamicLight=true
    LightEffect=LE_QuadraticNonIncidence
    LightType=LT_FadeOut
    LightBrightness=255
    LightHue=28
    LightSaturation=90
    LightRadius=9
    LightPeriod=32
    LightCone=128
}
*/