//=============================================================================
// DamTypePersesDirectHit
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Damage type for direct mercury missile hit without missile blowing up.
//=============================================================================


class DamTypePersesOmniMercuryPunchThrough extends DamTypePersesOmniMercuryDirectHit abstract;


/**
No flame effects for punch through.
*/
static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth);


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     DeathString="%k drove a Perses mercury missile through %o."
     bFlaming=False
     GibModifier=2.000000
     GibPerterbation=0.500000
     KDeathVel=400.000000
     VehicleDamageScaling=1.25
     VehicleMomentumScaling=1.25
}
