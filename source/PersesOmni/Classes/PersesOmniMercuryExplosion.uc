//=============================================================================
// MercuryExplosion
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Emitter that creates an explosion effect with a smoke ring and small stuff
// flying around.
//=============================================================================


class PersesOmniMercuryExplosion extends Emitter notplaceable;


//=============================================================================
// Imports
//=============================================================================

//#exec audio import file=Sounds\MercImpact.wav
//#exec audio import file=Sounds\MercWaterImpact.wav

#exec obj load file=WVMercuryMissiles_Tex.utx
#exec obj load file=WVMercuryMissilesSounds.uax

//=============================================================================
// Variables
//=============================================================================

var bool bWaterExplosion;


//=============================================================================
// Replication
//=============================================================================

replication
{
	reliable if (bNetInitial)
		bWaterExplosion;
}


//=============================================================================
// PostBeginPlay
//
// Handle low framerate conditions.
//=============================================================================

simulated event PostNetBeginPlay()
{
	local PlayerController PC;

	PC = Level.GetLocalPlayerController();
	if (Level.NetMode == NM_DedicatedServer || PC == None) {
		return;
	}
	if (!PC.BeyondViewDistance(Location, class'PersesOmniMercuryExplosionLight'.default.CullDistance)) {
		Spawn(class'PersesOmniMercuryExplosionLight');
	}

	if (Emitters.Length > 2) {
		if (Level.DetailMode == DM_Low || Level.DetailMode == DM_High && Level.bAggressiveLOD) {
			Emitters[2] = None;
		}
		else if (Emitters[2] != None && Level.bDropDetail) {
			Emitters[2].UseCollision = False;
			Emitters[2].LifetimeRange.Min = 1;
			Emitters[2].LifetimeRange.Max = 1.5;
		}
	}
}

auto simulated state Exploding
{
Begin:
	if (PhysicsVolume.bWaterVolume || bWaterExplosion)
		PlaySound(Sound'WVMercuryMissilesSounds.Effects.MercWaterImpact');
	else
		PlaySound(Sound'WVMercuryMissilesSounds.Effects.MercImpact');
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=ExplosionRing
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=128,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.400000,Color=(B=64,G=192,R=255,A=96))
         ColorScale(2)=(RelativeTime=0.800000,Color=(G=96,R=255,A=16))
         ColorScale(3)=(RelativeTime=1.000000,Color=(R=255))
         CoordinateSystem=PTCS_Relative
         MaxParticles=50
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(Y=(Max=65535.000000),Z=(Min=5.000000,Max=5.000000))
         UseRotationFrom=PTRS_Actor
         RotationOffset=(Yaw=16384,Roll=16384)
         StartSpinRange=(Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.600000,RelativeSize=0.800000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=0.700000)
         StartSizeRange=(X=(Min=20.000000,Max=25.000000),Y=(Min=20.000000,Max=25.000000),Z=(Min=20.000000,Max=25.000000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'WVMercuryMissiles_Tex.Particles.MercuryExplosionSprites'
         //Texture=Texture'PersesOmni.Particles.MercuryExplosionSprites'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.300000,Max=0.500000)
         StartVelocityRadialRange=(Min=100.000000,Max=170.000000)
         VelocityLossRange=(X=(Min=1.500000,Max=2.500000),Y=(Min=1.500000,Max=2.500000),Z=(Min=1.500000,Max=2.500000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(0)=SpriteEmitter'PersesOmni.PersesOmniMercuryExplosion.ExplosionRing'

     Begin Object Class=SpriteEmitter Name=ExplosionSmokeRing
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Opacity=0.500000
         FadeOutStartTime=0.200000
         FadeInEndTime=0.200000
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(Y=(Max=65535.000000),Z=(Min=20.000000,Max=20.000000))
         UseRotationFrom=PTRS_Actor
         RotationOffset=(Yaw=16384,Roll=16384)
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=0.700000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=25.000000,Max=25.000000),Y=(Min=25.000000,Max=25.000000),Z=(Min=25.000000,Max=25.000000))
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'EmitterTextures.MultiFrame.smokelight_a'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.800000,Max=1.000000)
         StartVelocityRadialRange=(Min=60.000000,Max=60.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(1)=SpriteEmitter'PersesOmni.PersesOmniMercuryExplosion.ExplosionSmokeRing'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     LifeSpan=1.100000
     TransientSoundVolume=0.500000
}
