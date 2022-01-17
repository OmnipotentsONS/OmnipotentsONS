/******************************************************************************
FlameJumpEmitter

Creation date: 2012-10-15 17:17
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.

Modified by Castiel Aug. 3, 2016. Adjusted emitter start points for a manta.
******************************************************************************/

class FlameDuckEmitter extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
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
         AddVelocityFromOwner=True
         Acceleration=(Z=100.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(R=255,A=255))
         StartLocationOffset=(X=25.000000,Y=-80.000000,Z=10.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=18.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=100.000000),Y=(Min=100.000000,Max=100.000000),Z=(Min=900.000000,Max=750.000000))
         StartVelocityRadialRange=(Min=150.000000,Max=50.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=0.500000),Z=(Min=1.000000,Max=0.500000))
         AddVelocityMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.900000,Max=0.900000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(0)=SpriteEmitter'FireVehiclesV2Omni.FlameDuckEmitter.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
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
         AddVelocityFromOwner=True
         Acceleration=(Z=100.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(R=255,A=255))
         StartLocationOffset=(X=25.000000,Y=80.000000,Z=10.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=18.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=100.000000),Y=(Min=100.000000,Max=100.000000),Z=(Min=900.000000,Max=750.000000))
         StartVelocityRadialRange=(Min=150.000000,Max=50.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=0.500000),Z=(Min=1.000000,Max=0.500000))
         AddVelocityMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.900000,Max=0.900000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(1)=SpriteEmitter'FireVehiclesV2Omni.FlameDuckEmitter.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
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
         AddVelocityFromOwner=True
         Acceleration=(Z=100.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(R=255,A=255))
         StartLocationOffset=(X=25.000000,Y=-80.000000,Z=10.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=18.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=100.000000),Y=(Min=100.000000,Max=100.000000),Z=(Min=900.000000,Max=750.000000))
         StartVelocityRadialRange=(Min=150.000000,Max=50.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=0.500000),Z=(Min=1.000000,Max=0.500000))
         AddVelocityMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.900000,Max=0.900000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(2)=SpriteEmitter'FireVehiclesV2Omni.FlameDuckEmitter.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
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
         AddVelocityFromOwner=True
         Acceleration=(Z=100.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(R=255,A=255))
         StartLocationOffset=(X=25.000000,Y=80.000000,Z=10.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=18.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=100.000000),Y=(Min=100.000000,Max=100.000000),Z=(Min=900.000000,Max=750.000000))
         StartVelocityRadialRange=(Min=150.000000,Max=50.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=0.500000),Z=(Min=1.000000,Max=0.500000))
         AddVelocityMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.900000,Max=0.900000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(3)=SpriteEmitter'FireVehiclesV2Omni.FlameDuckEmitter.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
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
         AddVelocityFromOwner=True
         Acceleration=(Z=100.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(R=255,A=255))
         StartLocationOffset=(X=25.000000,Y=-80.000000,Z=10.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=18.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=100.000000),Y=(Min=100.000000,Max=100.000000),Z=(Min=900.000000,Max=750.000000))
         StartVelocityRadialRange=(Min=150.000000,Max=50.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=0.500000),Z=(Min=1.000000,Max=0.500000))
         AddVelocityMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.900000,Max=0.900000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(4)=SpriteEmitter'FireVehiclesV2Omni.FlameDuckEmitter.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
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
         AddVelocityFromOwner=True
         Acceleration=(Z=100.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(R=255,A=255))
         StartLocationOffset=(X=25.000000,Y=80.000000,Z=10.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=18.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=100.000000),Y=(Min=100.000000,Max=100.000000),Z=(Min=900.000000,Max=750.000000))
         StartVelocityRadialRange=(Min=150.000000,Max=50.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=0.500000),Z=(Min=1.000000,Max=0.500000))
         AddVelocityMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.900000,Max=0.900000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(5)=SpriteEmitter'FireVehiclesV2Omni.FlameDuckEmitter.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
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
         AddVelocityFromOwner=True
         Acceleration=(Z=100.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(R=255,A=255))
         StartLocationOffset=(X=25.000000,Y=-80.000000,Z=10.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=18.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=100.000000),Y=(Min=100.000000,Max=100.000000),Z=(Min=900.000000,Max=750.000000))
         StartVelocityRadialRange=(Min=150.000000,Max=50.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=0.500000),Z=(Min=1.000000,Max=0.500000))
         AddVelocityMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.900000,Max=0.900000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(6)=SpriteEmitter'FireVehiclesV2Omni.FlameDuckEmitter.SpriteEmitter6'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter7
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
         AddVelocityFromOwner=True
         Acceleration=(Z=100.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.100000,Max=0.100000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(R=255,A=255))
         StartLocationOffset=(X=25.000000,Y=80.000000,Z=10.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=18.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=100.000000),Y=(Min=100.000000,Max=100.000000),Z=(Min=900.000000,Max=750.000000))
         StartVelocityRadialRange=(Min=150.000000,Max=50.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=0.500000),Z=(Min=1.000000,Max=0.500000))
         AddVelocityMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.900000,Max=0.900000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(7)=SpriteEmitter'FireVehiclesV2Omni.FlameDuckEmitter.SpriteEmitter7'

     AutoDestroy=True
     bNoDelete=False
     LifeSpan=2.000000
}
