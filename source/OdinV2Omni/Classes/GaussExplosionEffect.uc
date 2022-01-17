/******************************************************************************
GaussExplosionEffect

Creation date: 2010-09-20 20:25
Last change: $Id$
Copyright (c) 2010, Wormbo
******************************************************************************/

class GaussExplosionEffect extends Emitter;


//=============================================================================
// Imports
//=============================================================================

#exec load file=ExplosionTex.utx
#exec audio import file=Sounds\GaussExplosion.wav


simulated function PostBeginPlay()
{
	PlaySound(Sound'GaussExplosion');
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=1
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=25.000000,Max=30.000000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'ExplosionTex.Framed.we1_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.300000,Max=0.400000)
     End Object
     Emitters(0)=SpriteEmitter'WVHoverTankV2.GaussExplosionEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=1
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=20.000000,Max=25.000000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'ExplosionTex.Framed.exp2_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.300000,Max=0.400000)
     End Object
     Emitters(1)=SpriteEmitter'WVHoverTankV2.GaussExplosionEffect.SpriteEmitter1'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     LifeSpan=1.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=500.000000
}
