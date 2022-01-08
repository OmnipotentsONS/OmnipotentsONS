class FX_NukeShroom extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'APVerIV_ST.AP_FX_ST.Shroom'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=123,G=123,R=230))
         FadeOutStartTime=7.500000
         FadeInEndTime=0.200000
         MaxParticles=1
         SizeScale(0)=(RelativeSize=3.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=9.000000)
         StartSizeRange=(Z=(Min=0.800000,Max=0.800000))
         InitialParticlesPerSecond=50000.000000
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=9.000000,Max=10.000000)
         StartVelocityRange=(Z=(Min=211.000000,Max=211.000000))
         MaxAbsVelocity=(Z=2000.000000)
         VelocityLossRange=(X=(Max=0.110000),Y=(Max=0.110000))
     End Object
     Emitters(0)=MeshEmitter'CSAPVerIV.FX_NukeShroom.MeshEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     Style=STY_Masked
     bDirectional=True
}
