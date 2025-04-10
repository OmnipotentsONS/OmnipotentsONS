//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CSSpankBadgerUltraExplosion extends Emitter;

#exec OBJ LOAD FILE="..\Textures\ExplosionTex.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2k4XP.utx"


simulated function PostBeginPlay()
{
	local PlayerController PC;

	if (Level.NetMode == NM_DedicatedServer)
	{
	   LifeSpan = 0.2;
	   return;
	}

	PC = Level.GetLocalPlayerController();
	if ( PC == None )
	{
		Destroy();
		return;
	}
	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 6000) )
	{
		Emitters[0].Disabled = true;
	}
}

DefaultProperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter25
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=0.600000,Color=(B=255,G=255,R=255))
        ColorScale(3)=(RelativeTime=1.000000)
        Opacity=0.600000
        FadeOutStartTime=0.555100
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=30.000000)
        StartSizeRange=(X=(Min=120.000000,Max=130.000000),Y=(Min=160.000000,Max=170.000000),Z=(Min=160.000000,Max=170.000000))
        InitialParticlesPerSecond=20.000000
        Texture=Texture'CSSpankBadger.SpankerEffectCore'
        LifetimeRange=(Min=0.25,Max=0.25)
        WarmupTicksPerSecond=1.000000
        RelativeWarmupTime=1.000000
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter25'

    Begin Object Class=MeshEmitter Name=MeshEmitter10
        StaticMesh=StaticMesh'Editor.TexPropSphere'
        UseMeshBlendMode=False
        UseParticleColor=True
        UseColorScale=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=10,G=20,R=200))
        ColorScale(1)=(RelativeTime=0.700000,Color=(B=57,G=187,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        MaxParticles=1
        StartSizeRange=(X=(Min=0.4,Max=0.4),Y=(Min=0.4,Max=0.4),Z=(Min=0.4,Max=0.4))
        SizeScale(0)=(RelativeTime=1.0,RelativeSize=10.000000)
        InitialParticlesPerSecond=1000.000000
        LifetimeRange=(Min=0.20,Max=0.20)
        Texture=AW-2004Particles.Energy.EclipseCircle
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter10'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter18
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=10,G=129,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(A=255))
         MaxParticles=2
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=4.000000)
         StartSizeRange=(X=(Min=480.000000,Max=544.000000))
         InitialParticlesPerSecond=32768.000000
         Texture=Texture'AW-2004Particles.Energy.AirBlast'
         LifetimeRange=(Min=0.250000,Max=0.250000)
     End Object
     Emitters(2)=SpriteEmitter'CSSpankBadger.SpriteEmitter18'

    bNoDelete=False
    AutoDestroy=True
    AmbientGlow=254
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=True
}
