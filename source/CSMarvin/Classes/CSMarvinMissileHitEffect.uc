//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CSMarvinMissileHitEffect extends Emitter;

DefaultProperties
{
    /* explosion
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        RespawnDeadParticles=False
        AutoDestroy=True
        SpinParticles=True
        UseSizeScale=True
        UseColorScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        MaxParticles=3
        ColorScale(1)=(RelativeTime=0.250000,Color=(B=255,G=20,R=25,A=128))
        ColorScale(2)=(RelativeTime=1.000000)

        StartLocationShape=PTLS_Sphere
        //SphereRadiusRange=(Min=32.000000,Max=64.000000)
        SphereRadiusRange=(Min=16.000000,Max=32.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.250000)
        StartSizeRange=(X=(Min=150.000000,Max=300.000000))
        //StartSizeRange=(X=(Min=75.000000,Max=150.000000))
        SpawningSound=PTSC_Random
        InitialParticlesPerSecond=6.000000
        DrawStyle=PTDS_AlphaBlend
        //DrawStyle=PTDS_Transparent
        Texture=ExplosionTex.Framed.exp7_frames
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        SecondsBeforeInactive=0.000000
        //LifetimeRange=(Min=1.000000,Max=1.000000)
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'
    */

    /* glow 
    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseColorScale=True
        RespawnDeadParticles=False
        AutoDestroy=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        ColorScale(1)=(RelativeTime=0.250000,Color=(B=72,G=160,R=244))
        ColorScale(2)=(RelativeTime=0.670000,Color=(B=72,G=160,R=244))
        ColorScale(3)=(RelativeTime=1.000000)
        MaxParticles=1
        SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.750000)
        SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.500000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=425.000000,Max=425.000000))
        InitialParticlesPerSecond=2000.000000
        Texture=EpicParticles.Flares.SoftFlare
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.670000,Max=1.670000)
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'
    */

    

    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        UseCollision=True
        RespawnDeadParticles=False
        AutoDestroy=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-750.000000)
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=48.000000,Max=64.000000)
        //SphereRadiusRange=(Min=24.000000,Max=48.000000)
        StartSizeRange=(X=(Min=0.000000,Max=0.000000))
        InitialParticlesPerSecond=2000.000000
        //InitialParticlesPerSecond=500.000000
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=3.000000,Max=0.670000)
        //LifetimeRange=(Min=0.01500000,Max=0.18)
        //InitialDelayRange=(Min=0.250000,Max=0.250000)
        StartVelocityRadialRange=(Min=-800.000000,Max=-800.000000)
        //StartVelocityRadialRange=(Min=-400.000000,Max=-400.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial

    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter2'
    
    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        UseColorScale=True
        RespawnDeadParticles=False
        AutoDestroy=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ScaleSizeYByVelocity=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        //ColorScale(0)=(Color=(B=160,G=255,R=255,A=255))
        ColorScale(0)=(Color=(B=10,G=255,R=5,A=255))
        ColorScale(1)=(RelativeTime=1.000000)
        MaxParticles=150
        AddLocationFromOtherEmitter=2
        SpinsPerSecondRange=(X=(Max=0.001000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.330000,RelativeSize=2.500000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=4.000000)
        StartSizeRange=(X=(Min=10.000000,Max=16.000000))
        InitialParticlesPerSecond=300.000000
        //Texture=AW-2004Particles.Fire.MuchSmoke2t
        //Texture=AW-2004Particles.Weapons.DustSmoke
        //TextureUSubdivisions=4
        //TextureVSubdivisions=4
        Texture=AW-2004Particles.Weapons.HardSpot

        SecondsBeforeInactive=0.000000
        //LifetimeRange=(Min=1.000000,Max=1.500000)
        LifetimeRange=(Min=0.500000,Max=0.7500000)
        //InitialDelayRange=(Min=0.300000,Max=0.300000)
        AddVelocityMultiplierRange=(X=(Min=0.001000,Max=0.001000),Y=(Min=0.001000,Max=0.001000),Z=(Min=0.001000,Max=0.001000))
    End Object
    Emitters(3)=SpriteEmitter'SpriteEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter4
        UseCollision=True
        RespawnDeadParticles=False
        AutoDestroy=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-750.000000)
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=48.000000,Max=64.000000)
        //SphereRadiusRange=(Min=24.000000,Max=48.000000)
        StartSizeRange=(X=(Min=0.000000,Max=0.000000))
        InitialParticlesPerSecond=2000.000000
        //InitialParticlesPerSecond=500.000000
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=3.000000,Max=0.670000)
        //LifetimeRange=(Min=0.01500000,Max=0.18)
        //InitialDelayRange=(Min=0.250000,Max=0.250000)
        StartVelocityRadialRange=(Min=-800.000000,Max=-800.000000)
        //StartVelocityRadialRange=(Min=-400.000000,Max=-400.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial

    End Object
    Emitters(4)=SpriteEmitter'SpriteEmitter4'
    
    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
        UseColorScale=True
        RespawnDeadParticles=False
        AutoDestroy=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ScaleSizeYByVelocity=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        //ColorScale(0)=(Color=(B=160,G=255,R=255,A=255))
        ColorScale(0)=(Color=(B=255,G=10,R=5,A=255))
        ColorScale(1)=(RelativeTime=1.000000)
        MaxParticles=150
        AddLocationFromOtherEmitter=4
        SpinsPerSecondRange=(X=(Max=0.001000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.330000,RelativeSize=2.500000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=4.000000)
        StartSizeRange=(X=(Min=10.000000,Max=16.000000))
        InitialParticlesPerSecond=300.000000
        //Texture=AW-2004Particles.Fire.MuchSmoke2t
        //Texture=AW-2004Particles.Weapons.DustSmoke
        //TextureUSubdivisions=4
        //TextureVSubdivisions=4
        Texture=AW-2004Particles.Weapons.HardSpot

        SecondsBeforeInactive=0.000000
        //LifetimeRange=(Min=1.000000,Max=1.500000)
        LifetimeRange=(Min=0.500000,Max=0.7500000)
        //InitialDelayRange=(Min=0.300000,Max=0.300000)
        AddVelocityMultiplierRange=(X=(Min=0.001000,Max=0.001000),Y=(Min=0.001000,Max=0.001000),Z=(Min=0.001000,Max=0.001000))
    End Object
    Emitters(5)=SpriteEmitter'SpriteEmitter5'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter6
        UseCollision=True
        RespawnDeadParticles=False
        AutoDestroy=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-750.000000)
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=48.000000,Max=64.000000)
        //SphereRadiusRange=(Min=24.000000,Max=48.000000)
        StartSizeRange=(X=(Min=0.000000,Max=0.000000))
        InitialParticlesPerSecond=2000.000000
        //InitialParticlesPerSecond=500.000000
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=3.000000,Max=0.670000)
        //LifetimeRange=(Min=0.01500000,Max=0.18)
        //InitialDelayRange=(Min=0.250000,Max=0.250000)
        StartVelocityRadialRange=(Min=-800.000000,Max=-800.000000)
        //StartVelocityRadialRange=(Min=-400.000000,Max=-400.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial

    End Object
    Emitters(6)=SpriteEmitter'SpriteEmitter6'
    
    Begin Object Class=SpriteEmitter Name=SpriteEmitter7
        UseColorScale=True
        RespawnDeadParticles=False
        AutoDestroy=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ScaleSizeYByVelocity=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        //ColorScale(0)=(Color=(B=160,G=255,R=255,A=255))
        ColorScale(0)=(Color=(B=15,G=10,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000)
        MaxParticles=150
        AddLocationFromOtherEmitter=6
        SpinsPerSecondRange=(X=(Max=0.001000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.330000,RelativeSize=2.500000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=4.000000)
        StartSizeRange=(X=(Min=10.000000,Max=16.000000))
        InitialParticlesPerSecond=300.000000
        //Texture=AW-2004Particles.Fire.MuchSmoke2t
        //Texture=AW-2004Particles.Weapons.DustSmoke
        //TextureUSubdivisions=4
        //TextureVSubdivisions=4
        Texture=AW-2004Particles.Weapons.HardSpot

        SecondsBeforeInactive=0.000000
        //LifetimeRange=(Min=1.000000,Max=1.500000)
        LifetimeRange=(Min=0.500000,Max=0.7500000)
        //InitialDelayRange=(Min=0.300000,Max=0.300000)
        AddVelocityMultiplierRange=(X=(Min=0.001000,Max=0.001000),Y=(Min=0.001000,Max=0.001000),Z=(Min=0.001000,Max=0.001000))
    End Object
    Emitters(7)=SpriteEmitter'SpriteEmitter7'






/*
    Begin Object Class=TrailEmitter Name=TrailEmitter0
        TrailShadeType=PTTST_Linear
        DistanceThreshold=3.000000
        UseCrossedSheets=True
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        AutoDestroy=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-750.000000)
        ColorScale(0)=(Color=(B=160,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000)
        ColorMultiplierRange=(X=(Max=2.000000))
        DetailMode=DM_SuperHigh
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=32.000000,Max=32.000000)
        StartSizeRange=(X=(Min=2.000000,Max=7.000000))
        InitialParticlesPerSecond=30.000000
        Texture=AS_FX_TX.Trails.Trail_red
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.670000,Max=1.500000)
        StartVelocityRadialRange=(Min=-1200.000000,Max=-800.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(4)=TrailEmitter'TrailEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter4
        RespawnDeadParticles=False
        AutoDestroy=True
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        MaxParticles=5
        StartLocationShape=PTLS_All
        SphereRadiusRange=(Min=48.000000,Max=96.000000)
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Max=200.000000))
        SpawningSound=PTSC_Random
        InitialParticlesPerSecond=9.000000
        DrawStyle=PTDS_Brighten
        Texture=ExplosionTex.Framed.exp1_frames
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.500000,Max=1.000000)
        InitialDelayRange=(Min=0.550000,Max=0.550000)
    End Object
    Emitters(5)=SpriteEmitter'SpriteEmitter4'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
        RespawnDeadParticles=False
        AutoDestroy=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.670000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=150.000000,Max=150.000000))
        InitialParticlesPerSecond=2000.000000
        Texture=ExplosionTex.Framed.exp1_frames
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(6)=SpriteEmitter'SpriteEmitter5'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter6
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        AutoDestroy=True
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        Acceleration=(Z=-750.000000)
        DampingFactorRange=(Z=(Min=0.500000,Max=0.500000))
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.150000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutStartTime=0.750000
        MaxParticles=60
        StartLocationShape=PTLS_All
        SphereRadiusRange=(Min=64.000000,Max=64.000000)
        SpinsPerSecondRange=(X=(Min=0.500000,Max=1.500000))
        StartSpinRange=(X=(Max=2.000000))
        StartSizeRange=(X=(Min=3.000000,Max=18.000000))
        InitialParticlesPerSecond=300.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=EmitterTextures.MultiFrame.rockchunks02
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.500000,Max=2.500000)
        InitialDelayRange=(Min=0.100000,Max=0.100000)
        StartVelocityRadialRange=(Min=-800.000000,Max=-1200.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(7)=SpriteEmitter'SpriteEmitter6'
    */

    bDirectional=true
    bNoDelete=false
    AutoDestroy=true
	RemoteRole=ROLE_None
}