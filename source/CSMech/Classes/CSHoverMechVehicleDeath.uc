class CSHoverMechVehicleDeath extends Emitter;

#exec OBJ LOAD FILE="..\Textures\ExplosionTex.utx"
#exec OBJ LOAD FILE="..\StaticMeshes\ONSFullStaticMeshes.usx"

defaultproperties
{
	bNoDelete=False
	AutoDestroy=True

    Begin Object Class=SpriteEmitter Name=SpriteEmitter50
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        StartLocationRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-50.000000,Max=150.000000))
        UseRotationFrom=PTRS_Actor
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        InitialParticlesPerSecond=20.000000
        Texture=ExplosionTex.Framed.exp1_frames
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        LifetimeRange=(Min=1.000000,Max=1.000000)
        Name="SpriteEmitter50"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter50'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter51
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        MaxParticles=20
        DetailMode=DM_High
        StartLocationRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-50.000000,Max=150.000000))
        UseRotationFrom=PTRS_Actor
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        InitialParticlesPerSecond=100.000000
        Texture=ExplosionTex.Framed.we1_frames
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=1.000000,Max=1.000000)
        InitialDelayRange=(Min=0.700000,Max=0.700000)
        Name="SpriteEmitter51"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter51'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter53
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        MaxParticles=20
        StartLocationRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-50.000000,Max=150.000000))
        UseRotationFrom=PTRS_Actor
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        InitialParticlesPerSecond=100.000000
        Texture=ExplosionTex.Framed.exp2_frames
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=1.000000,Max=1.000000)
        InitialDelayRange=(Min=0.700000,Max=0.700000)
        StartVelocityRadialRange=(Min=-40.000000,Max=-50.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        Name="SpriteEmitter53"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter53'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter55
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        MaxParticles=3
        DetailMode=DM_High
        StartLocationOffset=(Z=100.000000)
        StartLocationRange=(X=(Min=-50.000000,Max=50.000000))
        UseRotationFrom=PTRS_Actor
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.250000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=400.000000,Max=400.000000))
        InitialParticlesPerSecond=20.000000
        Texture=ExplosionTex.Framed.exp2_frames
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.700000,Max=0.700000)
        InitialDelayRange=(Min=0.500000,Max=0.500000)
        Name="SpriteEmitter55"
    End Object
    Emitters(3)=SpriteEmitter'SpriteEmitter55'

    Begin Object Class=MeshEmitter Name=MeshEmitter34
        StaticMesh=ParticleMeshes.Complex.ExplosionRing
        UseParticleColor=True
        UseColorScale=True
        RespawnDeadParticles=False
        Disabled=True
        Backup_Disabled=True
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=28,G=141,R=255))
        ColorScale(1)=(RelativeTime=0.850000,Color=(B=28,G=141,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        MaxParticles=1
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=8.000000)
        InitialParticlesPerSecond=500.000000
        LifetimeRange=(Min=0.500000,Max=0.500000)
        InitialDelayRange=(Min=0.600000,Max=0.600000)
        Name="MeshEmitter34"
    End Object
    Emitters(4)=MeshEmitter'MeshEmitter34'

    Begin Object Class=MeshEmitter Name=MeshEmitter39
        StaticMesh=ParticleMeshes.Complex.ExplosionRing
        UseParticleColor=True
        UseColorScale=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=28,G=141,R=255))
        ColorScale(1)=(RelativeTime=0.850000,Color=(B=28,G=141,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        MaxParticles=1
        StartLocationOffset=(Z=100.000000)
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=8.000000)
        InitialParticlesPerSecond=500.000000
        LifetimeRange=(Min=0.500000,Max=0.500000)
        InitialDelayRange=(Min=0.700000,Max=0.700000)
        Name="MeshEmitter39"
    End Object
    Emitters(5)=MeshEmitter'MeshEmitter39'

    /*
    Begin Object Class=MeshEmitter Name=MeshEmitter35
        StaticMesh=ONSFullStaticMeshes.LEVexploded.BayDoor
        UseMeshBlendMode=False
        UseParticleColor=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-900.000000)
        ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
        ColorScale(1)=(RelativeTime=0.950000,Color=(B=128,G=128,R=128,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
        MaxParticles=1
        DetailMode=DM_High
        StartLocationOffset=(Y=75.000000,Z=150.000000)
        UseRotationFrom=PTRS_Actor
        SpinCCWorCW=(Z=0.000000)
        SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        InitialParticlesPerSecond=500.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=2.000000,Max=2.000000)
        InitialDelayRange=(Min=0.550000,Max=0.550000)
        StartVelocityRange=(Y=(Min=200.000000,Max=300.000000),Z=(Min=800.000000,Max=1000.000000))
        Name="MeshEmitter35"
    End Object
    Emitters(6)=MeshEmitter'MeshEmitter35'

    Begin Object Class=MeshEmitter Name=MeshEmitter37
        StaticMesh=ONSFullStaticMeshes.LEVexploded.BayDoor
        UseMeshBlendMode=False
        UseParticleColor=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-900.000000)
        ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
        ColorScale(1)=(RelativeTime=0.950000,Color=(B=128,G=128,R=128,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
        MaxParticles=1
        DetailMode=DM_High
        StartLocationOffset=(Y=-75.000000,Z=150.000000)
        UseRotationFrom=PTRS_Actor
        SpinCCWorCW=(Z=1.000000)
        SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        InitialParticlesPerSecond=500.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=2.000000,Max=2.000000)
        InitialDelayRange=(Min=0.550000,Max=0.550000)
        StartVelocityRange=(Y=(Min=-200.000000,Max=-300.000000),Z=(Min=800.000000,Max=1000.000000))
        Name="MeshEmitter37"
    End Object
    Emitters(7)=MeshEmitter'MeshEmitter37'

    Begin Object Class=MeshEmitter Name=MeshEmitter38
        StaticMesh=ONSFullStaticMeshes.LEVexploded.MainGun
        UseMeshBlendMode=False
        UseParticleColor=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-900.000000)
        ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
        ColorScale(1)=(RelativeTime=0.900000,Color=(B=128,G=128,R=128,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
        MaxParticles=1
        DetailMode=DM_High
        StartLocationOffset=(Z=120.000000)
        UseRotationFrom=PTRS_Actor
        SpinCCWorCW=(Y=1.000000)
        SpinsPerSecondRange=(Y=(Min=0.300000,Max=0.500000),Z=(Max=1.000000))
        InitialParticlesPerSecond=500.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=2.000000,Max=2.000000)
        InitialDelayRange=(Min=0.700000,Max=0.700000)
        StartVelocityRange=(X=(Min=100.000000,Max=200.000000),Z=(Min=1200.000000,Max=1500.000000))
        Name="MeshEmitter38"
    End Object
    Emitters(8)=MeshEmitter'MeshEmitter38'

    Begin Object Class=MeshEmitter Name=MeshEmitter27
        StaticMesh=ONSFullStaticMeshes.LEVexploded.SideFlap
        UseMeshBlendMode=False
        UseParticleColor=True
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        DampRotation=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-800.000000)
        DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.100000,Max=0.100000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=0.850000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        MaxParticles=1
        StartLocationOffset=(Y=200.000000)
        SpinCCWorCW=(Y=1.000000,Z=1.000000)
        SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        RotationDampingFactorRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=0.200000,Max=0.200000))
        InitialParticlesPerSecond=500.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=1.000000,Max=1.500000)
        InitialDelayRange=(Min=0.700000,Max=0.700000)
        StartVelocityRange=(Y=(Min=600.000000,Max=800.000000),Z=(Min=300.000000,Max=500.000000))
        Name="MeshEmitter27"
    End Object
    Emitters(9)=MeshEmitter'MeshEmitter27'
    */

    Begin Object Class=SpriteEmitter Name=SpriteEmitter26
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        MaxParticles=20
        StartLocationOffset=(Y=-10.000000)
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
        AddLocationFromOtherEmitter=9
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Max=150.000000))
        InitialParticlesPerSecond=40.000000
        Texture=ExplosionTex.Framed.exp1_frames
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.500000,Max=0.500000)
        InitialDelayRange=(Min=0.700000,Max=0.700000)
        Name="SpriteEmitter26"
    End Object
    Emitters(6)=SpriteEmitter'SpriteEmitter26'

    /*
    Begin Object Class=MeshEmitter Name=MeshEmitter40
        StaticMesh=ONSFullStaticMeshes.LEVexploded.SideFlap
        UseMeshBlendMode=False
        UseParticleColor=True
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        DampRotation=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-800.000000)
        DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.100000,Max=0.100000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=0.850000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        MaxParticles=1
        StartLocationOffset=(Y=-200.000000)
        SpinCCWorCW=(Y=1.000000,Z=0.000000)
        SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        RotationDampingFactorRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=0.200000,Max=0.200000))
        StartSizeRange=(X=(Min=-1.000000,Max=-1.000000))
        InitialParticlesPerSecond=500.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=1.000000,Max=1.500000)
        InitialDelayRange=(Min=0.700000,Max=0.700000)
        StartVelocityRange=(Y=(Min=-600.000000,Max=-800.000000),Z=(Min=300.000000,Max=500.000000))
        Name="MeshEmitter40"
    End Object
    Emitters(11)=MeshEmitter'MeshEmitter40'
    */

    Begin Object Class=SpriteEmitter Name=SpriteEmitter39
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        MaxParticles=20
        StartLocationOffset=(Y=10.000000)
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
        AddLocationFromOtherEmitter=11
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Max=150.000000))
        InitialParticlesPerSecond=40.000000
        Texture=ExplosionTex.Framed.exp1_frames
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.500000,Max=0.500000)
        InitialDelayRange=(Min=0.700000,Max=0.700000)
        Name="SpriteEmitter39"
    End Object
    Emitters(7)=SpriteEmitter'SpriteEmitter39'

    Begin Object Class=MeshEmitter Name=MeshEmitter41
        StaticMesh=AW-2004Particles.Debris.Veh_Debris1
        UseParticleColor=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1500.000000)
        ColorScale(0)=(Color=(B=128,G=128,R=128,A=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=128,G=128,R=128,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
        MaxParticles=30
        StartLocationRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-200.000000,Max=200.000000))
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=0.125000,Max=2.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=1.000000,Max=1.500000)
        InitialDelayRange=(Min=0.600000,Max=0.600000)
        StartVelocityRange=(X=(Min=-800.000000,Max=800.000000),Y=(Min=-800.000000,Max=800.000000),Z=(Min=500.000000,Max=1500.000000))
        Name="MeshEmitter41"
    End Object
    Emitters(8)=MeshEmitter'MeshEmitter41'

    ///

    Begin Object Class=SpriteEmitter Name=SpriteEmitter60
        RespawnDeadParticles=False
        AutoDestroy=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        MaxParticles=3
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=32.000000,Max=64.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.250000)
        StartSizeRange=(X=(Min=150.000000,Max=300.000000))
        SpawningSound=PTSC_Random
        InitialParticlesPerSecond=6.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=ExplosionTex.Framed.exp7_frames
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(9)=SpriteEmitter'SpriteEmitter60'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter61
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
    Emitters(10)=SpriteEmitter'SpriteEmitter61'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter62
        UseCollision=True
        RespawnDeadParticles=False
        AutoDestroy=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-750.000000)
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=48.000000,Max=64.000000)
        StartSizeRange=(X=(Min=0.000000,Max=0.000000))
        InitialParticlesPerSecond=2000.000000
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=3.000000,Max=0.670000)
        InitialDelayRange=(Min=0.250000,Max=0.250000)
        StartVelocityRadialRange=(Min=-800.000000,Max=-800.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(11)=SpriteEmitter'SpriteEmitter62'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter63
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
        ColorScale(0)=(Color=(B=160,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=45,G=158,R=234,A=255))
        ColorScale(2)=(RelativeTime=0.400000,Color=(B=40,G=103,R=172,A=255))
        ColorScale(3)=(RelativeTime=0.700000,Color=(B=40,G=40,R=40))
        ColorScale(4)=(RelativeTime=1.000000)
        MaxParticles=150
        AddLocationFromOtherEmitter=2
        SpinsPerSecondRange=(X=(Max=0.001000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.330000,RelativeSize=2.500000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=4.000000)
        StartSizeRange=(X=(Min=10.000000,Max=16.000000))
        InitialParticlesPerSecond=300.000000
        Texture=AW-2004Particles.Fire.MuchSmoke2t
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.000000,Max=1.500000)
        InitialDelayRange=(Min=0.300000,Max=0.300000)
        AddVelocityMultiplierRange=(X=(Min=0.001000,Max=0.001000),Y=(Min=0.001000,Max=0.001000),Z=(Min=0.001000,Max=0.001000))
    End Object
    Emitters(12)=SpriteEmitter'SpriteEmitter63'

    Begin Object Class=TrailEmitter Name=TrailEmitter64
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
    Emitters(13)=TrailEmitter'TrailEmitter64'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter65
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
    Emitters(14)=SpriteEmitter'SpriteEmitter65'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter66
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
    Emitters(15)=SpriteEmitter'SpriteEmitter66'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter67
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
    Emitters(16)=SpriteEmitter'SpriteEmitter67'
}
