/**
PersesMercuryMissileFlightEffectsBlue

Creation date: 2013-12-13 21:12
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniMercuryMissileFlightEffectsBlue extends PersesOmniMercuryMissileFlightEffects;



//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=TrailEmitter Name=MissileTrailBlue
         TrailShadeType=PTTST_PointLife
         TrailLocation=PTTL_FollowEmitter
         MaxPointsPerTrail=400
         DistanceThreshold=10.000000
         PointLifeTime=0.600000
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorMultiplierRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
         MaxParticles=1
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=2000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'WVMercuryMissiles_Tex.Particles.MercurySmokeLine'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=10.000000,Max=10.000000)
     End Object
     Emitters(1)=TrailEmitter'PersesOmni.PersesOmniMercuryMissileFlightEffectsBlue.MissileTrailBlue'

}
