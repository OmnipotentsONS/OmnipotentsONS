//=============================================================================
// MercuryExplosionDirt
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Emitter that creates an explosion effect.
//=============================================================================


class PVWMercuryExplosionDirt extends PVWMercuryExplosion;


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=ExplosionChunks
         UseCollision=True
         UseMaxCollisions=True
         UseColorScale=True
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-900.000000)
         DampingFactorRange=(X=(Min=0.300000,Max=0.500000),Y=(Min=0.300000,Max=0.500000),Z=(Min=0.300000,Max=0.500000))
         MaxCollisions=(Min=5.000000,Max=15.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.900000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         MaxParticles=50
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=10.000000)
         StartSizeRange=(X=(Min=2.000000,Max=6.000000),Y=(Min=2.000000,Max=6.000000),Z=(Min=2.000000,Max=6.000000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EmitterTextures.MultiFrame.rockchunks02'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=3.000000)
         StartVelocityRadialRange=(Min=-200.000000,Max=-700.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(2)=SpriteEmitter'PVWraith.PVWMercuryExplosionDirt.ExplosionChunks'

     LifeSpan=3.100000
}
