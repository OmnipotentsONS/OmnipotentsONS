
class CSShieldMechShieldHitEffectRed extends Emitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2k4XP.utx"

DefaultProperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter2
        StaticMesh=StaticMesh'CSMech.Shield'
        //DrawStyle=PTDS_AlphaBlend
        UseParticleColor=True
        UseColorScale=True
        RespawnDeadParticles=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=70,G=70,R=255))
        ColorScale(1)=(RelativeTime=1.000000)
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        UniformSize=false
        //StartSizeRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
        StartSizeRange=(X=(Min=32.000000,Max=32.000000),Y=(Min=40.000000,Max=40.000000),Z=(Min=40.000000,Max=40.000000))
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=0.200000,Max=0.200000)
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter2'

    bNoDelete=False
    AutoDestroy=True
    AmbientGlow=254
}
