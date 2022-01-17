/******************************************************************************
SmallHoverTankDustEmitter

Creation date: 2012-10-12 16:28
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class FirebugDustEmitter extends HoverTankDustEmitter;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     RingSize=22.000000
     Begin Object Class=SpriteEmitter Name=FireSpray
         UseDirectionAs=PTDU_Right
         UseCollision=True
         UseMaxCollisions=True
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         TriggerDisabled=False
         AddVelocityFromOwner=True
         ColorScale(0)=(Color=(B=255))
         ColorScale(1)=(RelativeTime=0.300000,Color=(G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(G=255,R=255))
         StartLocationOffset=(Z=50.000000)
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
         Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(Z=(Min=-100.000000,Max=-100.000000))
         AddVelocityMultiplierRange=(X=(Min=0.900000,Max=0.900000),Y=(Min=0.900000,Max=0.900000),Z=(Min=0.100000,Max=0.100000))
     End Object
     Emitters(2)=SpriteEmitter'FireVehiclesV2Omni.FirebugDustEmitter.FireSpray'

     Begin Object Class=SpriteEmitter Name=FireCloud
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         TriggerDisabled=False
         AddVelocityFromOwner=True
         Acceleration=(Z=100.000000)
         DampingFactorRange=(X=(Min=0.100000,Max=0.200000),Y=(Min=0.100000,Max=0.200000),Z=(Min=0.100000,Max=0.200000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(R=255,A=255))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.100000
         StartLocationOffset=(Z=50.000000)
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.200000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         SpawnOnTriggerRange=(Min=10.000000,Max=10.000000)
         SpawnOnTriggerPPS=10.000000
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-250.000000,Max=-200.000000))
         VelocityLossRange=(X=(Min=0.900000,Max=1.000000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         AddVelocityMultiplierRange=(X=(Min=0.900000,Max=0.900000),Y=(Min=0.900000,Max=0.900000),Z=(Min=0.900000,Max=0.900000))
     End Object
     Emitters(3)=SpriteEmitter'FireVehiclesV2Omni.FirebugDustEmitter.FireCloud'

     CullDistance=10000.000000
}
