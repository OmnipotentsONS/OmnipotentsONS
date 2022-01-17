//=============================================================================
// ONSShockTankShieldComboHit
//=============================================================================
// Created by Alan Willard (C) 2004 Epic Games
//=============================================================================

class HospitilarShieldComboHit extends Emitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2k4XP.utx"

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter15
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=66,R=128))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=66,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         EffectAxis=PTEA_PositiveZ
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=32.000000
         Texture=Texture'AW-2004Particles.Energy.SmoothRing'
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'OnslaughtBP.ONSShockTankShieldComboHit.SpriteEmitter15'

     Begin Object Class=BeamEmitter Name=BeamEmitter0
         BeamDistanceRange=(Min=498.000000,Max=498.000000)
         DetermineEndPointBy=PTEP_Distance
         RotatingSheets=3
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=66,R=128))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=66,R=128))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.250000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Weapons.SoftFade'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=-1.000000,Max=-1.000000))
     End Object
     Emitters(1)=BeamEmitter'OnslaughtBP.ONSShockTankShieldComboHit.BeamEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter16
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=64,R=128))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=64,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=32.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Fire.SmokeFragment'
         LifetimeRange=(Min=0.600000,Max=0.800000)
     End Object
     Emitters(2)=SpriteEmitter'OnslaughtBP.ONSShockTankShieldComboHit.SpriteEmitter16'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter18
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=81,R=172))
         ColorScale(2)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=80.000000
         Texture=Texture'AW-2004Particles.Weapons.HardSpot'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=-750.000000,Max=-800.000000))
     End Object
     Emitters(3)=SpriteEmitter'OnslaughtBP.ONSShockTankShieldComboHit.SpriteEmitter18'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     bDirectional=True
}
