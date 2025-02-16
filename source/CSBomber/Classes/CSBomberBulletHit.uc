class CSBomberBulletHit extends Emitter;

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter18
        StaticMesh=StaticMesh'ArboreaLanscape.Cliffs.littlerock01'
        Acceleration=(Z=-950.000000)
        UseCollision=True
        DampingFactorRange=(X=(Min=-0.500000,Max=-0.250000),Y=(Min=-0.500000,Max=-0.250000),Z=(Min=-0.500000,Max=-0.250000))
        MaxParticles=30
        ResetAfterChange=True
        RespawnDeadParticles=False
        StartMassRange=(Min=100.000000,Max=500.000000)
        UniformMeshScale=False
        UniformVelocityScale=False
        SpinParticles=True
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        StartSizeRange=(X=(Min=-0.020000,Max=0.004000),Y=(Min=0.020000,Max=0.004000),Z=(Min=0.020000,Max=0.004000))
        InitialParticlesPerSecond=500.000000
        AutomaticInitialSpawning=False
        LifetimeRange=(Min=2.000000)
        TriggerDisabled=False
        ResetOnTrigger=True
        StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=500.000000,Max=800.000000))
    End Object
    Emitters(0)=MeshEmitter18
    Begin Object Class=MeshEmitter Name=MeshEmitter19
        StaticMesh=StaticMesh'ArboreaLanscape.Cliffs.littlerock01'
        Acceleration=(Z=-950.000000)
        MaxParticles=25
        ResetAfterChange=True
        RespawnDeadParticles=False
        UniformMeshScale=False
        UniformVelocityScale=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
        StartSpinRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
        StartSizeRange=(X=(Min=0.002000,Max=0.004000),Y=(Min=0.002000,Max=0.004000),Z=(Min=0.002000,Max=0.004000))
        InitialParticlesPerSecond=1100.000000
        AutomaticInitialSpawning=False
        LifetimeRange=(Min=2.000000,Max=1.000000)
        TriggerDisabled=False
        ResetOnTrigger=True
        StartVelocityRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=300.000000,Max=600.000000))
    End Object
    Emitters(1)=MeshEmitter19
    Begin Object Class=SpriteEmitter Name=SpriteEmitter27
        Acceleration=(Z=-950.000000)
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
        StartSpinRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
        UseRegularSizeScale=False
        StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
        UniformSize=True
        InitialParticlesPerSecond=500.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'EmitterTextures.MultiFrame.rockchunks02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.000000,Max=2.000000)
        TriggerDisabled=False
        ResetOnTrigger=True
        StartVelocityRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=600.000000,Max=800.000000))
    End Object
    Emitters(2)=SpriteEmitter27
    Begin Object Class=SpriteEmitter Name=SpriteEmitter28
        Acceleration=(Z=-750.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=34,G=141,R=238))
        ColorScale(1)=(RelativeTime=0.250000,Color=(B=43,G=68,R=77))
        ColorScale(2)=(RelativeTime=0.900000,Color=(B=51,G=51,R=51))
        ColorMultiplierRange=(X=(Min=0.750000,Max=0.750000),Y=(Min=0.750000,Max=0.750000),Z=(Min=0.750000,Max=0.750000))
        FadeOutFactor=(W=0.250000,X=0.100000,Y=0.100000,Z=0.100000)
        FadeOutStartTime=0.750000
        FadeOut=True
        MaxParticles=25
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
        StartSpinRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.500000,RelativeSize=10.000000)
        StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
        UniformSize=True
        InitialParticlesPerSecond=500.000000
        AutomaticInitialSpawning=False
        Texture=Texture'EmitterTextures.MultiFrame.smokelight_a'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        UseRandomSubdivision=True
        LifetimeRange=(Min=3.000000)
        TriggerDisabled=False
        ResetOnTrigger=True
        StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=300.000000,Max=700.000000))
        RelativeWarmupTime=1.000000
    End Object
    Emitters(3)=SpriteEmitter28

    //RemoteRole=ROLE_DumbProxy
    RemoteRole=ROLE_None
    bNetTemporary=true
    bNoDelete=false
    AutoDestroy=true
    bLightChanged=True
    bUnlit=False
    ForceType=FT_Constant
    ForceRadius=1000.000000
    ForceScale=10.000000
}
