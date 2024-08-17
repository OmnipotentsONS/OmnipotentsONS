class OmniNukeCloudWave extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=200,G=244,R=255))
         ColorScale(1)=(RelativeTime=3.000000,Color=(B=255,G=255,R=255))
         ColorMultiplierRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
         FadeOutStartTime=6.000000
         FadeInEndTime=4.000000
         MaxParticles=1
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere3'
         SizeScale(0)=(RelativeSize=6.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=20.000000)
         StartSizeRange=(Z=(Min=0.700000))
         InitialParticlesPerSecond=50000.000000
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=30.000000,Max=45.000000)
         StartVelocityRange=(Z=(Min=15.000000,Max=100.000000))
         MaxAbsVelocity=(Z=2000.000000)
         VelocityLossRange=(X=(Max=0.250000),Y=(Max=0.250000))
     End Object
     Emitters(0)=MeshEmitter'OmniNukes.OmniNukeCloudWave.MeshEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     Style=STY_Additive
     bDirectional=True
}
