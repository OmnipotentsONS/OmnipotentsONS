class CSSpankBadgerMuzzleFlash extends Emitter;


function PostBeginPlay()
{
	local PlayerController PC;

	PC = Level.GetLocalPlayerController();
	if ( PC == None )
	{
		Destroy();
		return;
	}
	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 4000) )
	{
		Emitters[1].Disabled = true;
		Emitters[2].Disabled = true;
		Emitters[3].Disabled = true;
	}
}

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter6
        StaticMesh=StaticMesh'AW-2k4XP.Weapons.ShockTankEffectRing'
        UseParticleColor=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=0,G=20,R=255))
        ColorScale(1)=(RelativeTime=0.500000,Color=(B=74,G=142,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        Opacity=0.500000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartLocationOffset=(X=12.000000)
        StartSpinRange=(Y=(Min=0.250000,Max=0.250000))
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.200000,Max=0.200000))
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter6'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=64,G=158,R=255))
        ColorScale(1)=(RelativeTime=1.000000)
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        StartLocationOffset=(X=5.000000)
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        InitialParticlesPerSecond=20.000000
        Texture=Texture'CSSpankBadger.Badger.SpankerEffectCore'
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter5'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=51,G=185,R=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=81,G=199,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        MaxParticles=3
        StartLocationRange=(X=(Max=32.000000),Y=(Min=-16.000000,Max=16.000000),Z=(Min=-16.000000,Max=16.000000))
        SphereRadiusRange=(Min=4.000000,Max=16.000000)
        UseRotationFrom=PTRS_Actor
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.750000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=20.000000,Max=35.000000))
        InitialParticlesPerSecond=200.000000
        Texture=Texture'AW-2004Particles.Fire.SmokeFragment'
        LifetimeRange=(Min=0.500000,Max=0.800000)
        StartVelocityRadialRange=(Min=-60.000000,Max=-80.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter2'

    AmbientGlow=254
    RemoteRole=ROLE_None
    bNoDelete=false
}