//=============================================================================
// DamTypeMercuryDirectHit
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Damage type for mercury missile splash damage.
//=============================================================================


class DamTypePersesOmniMercurySplashDamage extends DamTypePersesOmniRocket abstract;


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     DeathString="%o was way too slow for %k's Perses mercury missile."
     FemaleSuicide="%o somehow managed to get hit by her own mercury missile."
     MaleSuicide="%o somehow managed to get hit by his own mercury missile."
     VehicleDamageScaling=1.4
     VehicleMomentumScaling=1.0
}
