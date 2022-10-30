//=============================================================================
// MercuryExplosionLight
// Copyright 2007-2010 by Wormbo <wormbo@online.de>
//
// Light effect for mercury missile explosions.
//=============================================================================


class PVWMercuryExplosionLight extends Effects;


simulated function PostNetBeginPlay()
{
	if (Level.bDropDetail)
		LightRadius = 5;
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     LightType=LT_FadeOut
     LightEffect=LE_QuadraticNonIncidence
     LightHue=20
     LightSaturation=90
     LightBrightness=200.000000
     LightRadius=7.000000
     LightPeriod=32
     LightCone=128
     CullDistance=5000.000000
     bHidden=True
     bDynamicLight=True
     LifeSpan=0.500000
}
