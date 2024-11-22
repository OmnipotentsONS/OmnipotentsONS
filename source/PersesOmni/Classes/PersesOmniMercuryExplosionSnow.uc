//=============================================================================
// MercuryExplosionSnow
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Emitter that creates an explosion effect.
//=============================================================================


class PersesOmniMercuryExplosionSnow extends PersesOmniMercuryExplosion;


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=ExplosionChunks
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-600.000000)
         FadeOutFactor=(X=0.000000,Y=0.000000,Z=0.000000)
         FadeOutStartTime=1.000000
         MaxParticles=25
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=10.000000)
         StartSizeRange=(X=(Min=2.000000,Max=6.000000),Y=(Min=2.000000,Max=6.000000),Z=(Min=2.000000,Max=6.000000))
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'EmitterTextures.MultiFrame.smoke_a'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=3.400000)
         StartVelocityRadialRange=(Min=-200.000000,Max=-500.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(2)=SpriteEmitter'PersesOmni.PersesOmniMercuryExplosionSnow.ExplosionChunks'

     LifeSpan=3.100000
}
