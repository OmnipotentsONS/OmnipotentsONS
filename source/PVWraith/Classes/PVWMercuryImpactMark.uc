//=============================================================================
// MercuryImpactMark
// Copyright 2007-2010 by Wormbo <wormbo@online.de>
//
// Impact decal for Mercury Missile explosions.
//=============================================================================


class PVWMercuryImpactMark extends RocketMark;

#exec TEXTURE IMPORT NAME=Decals_MercImpactMark FILE=Textures\Decals_MercImpactMark.tga DXT=5
//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     ProjTexture=Texture'PVWraith.Decals_MercImpactMark'
     DrawScale=0.800000
}
