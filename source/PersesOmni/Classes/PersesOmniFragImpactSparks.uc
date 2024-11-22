/**
PersesFragImpactSparks

Creation date: 2013-12-14 09:55
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniFragImpactSparks extends Emitter;


simulated function PostBeginPlay()
{
	Trigger(Self, None);
}

//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=TrailEmitter Name=TrailEmitter0
         TrailShadeType=PTTST_PointLife
         PointLifeTime=0.100000
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         TriggerDisabled=False
         Acceleration=(Z=-900.000000)
         ColorMultiplierRange=(Y=(Min=0.500000),Z=(Min=0.000000,Max=0.500000))
         MaxParticles=3
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=5.000000,Max=10.000000))
         Texture=Texture'AW-2004Particles.Weapons.TracerShot'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.800000)
         SpawnOnTriggerRange=(Min=1.000000,Max=3.000000)
         SpawnOnTriggerPPS=100.000000
         StartVelocityRange=(X=(Min=-500.000000,Max=-100.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-150.000000,Max=150.000000))
     End Object
     Emitters(0)=TrailEmitter'PersesOmni.PersesOmniFragImpactSparks.TrailEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter31
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         TriggerDisabled=False
         Acceleration=(Z=50.000000)
         MaxParticles=5
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=10.000000,Max=25.000000))
         Texture=Texture'EmitterTextures.MultiFrame.smokelight_a'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=1.500000)
         SpawnOnTriggerRange=(Min=2.000000,Max=5.000000)
         SpawnOnTriggerPPS=20.000000
         StartVelocityRange=(X=(Min=-10.000000,Max=-20.000000),Y=(Min=-10.000000,Max=10.000000))
     End Object
     Emitters(1)=SpriteEmitter'PersesOmni.PersesOmniFragImpactSparks.SpriteEmitter31'

     AutoDestroy=True
     bNoDelete=False
}
