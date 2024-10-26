class MirageRaptorOmniProjectileFireEffectBlue extends MirageRaptorOmniProjectileFireEffect notplaceable;

defaultproperties
{


// below is good from ONSDualMissleTrail but only one color
// its blue here.
Begin Object Class=TrailEmitter Name=TrailEmitter2
         TrailShadeType=PTTST_PointLife
         TrailLocation=PTTL_FollowEmitter
         MaxPointsPerTrail=150
         DistanceThreshold=20.000000
         UseCrossedSheets=True
         PointLifeTime=0.750000
         UniformSize=True
         AutomaticInitialSpawning=False
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=128,R=92))
         MaxParticles=1
         StartSizeRange=(X=(Min=80.000000,Max=80.000000))
         InitialParticlesPerSecond=2000.000000
         //Texture=Texture'AW-2k4XP.Cicada.MissileTrail1a'
         Texture=Texture'XGameTextures.SuperPickups.BombgatePulseBlue2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=999999.000000,Max=999999.000000)
     End Object
     Emitters(2)=TrailEmitter'MirageRaptorOmni.MirageRaptorOmniProjectileFireEffectBlue.TrailEmitter2'
