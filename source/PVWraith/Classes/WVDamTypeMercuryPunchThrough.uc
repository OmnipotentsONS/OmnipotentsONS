//=============================================================================
// WVDamTypeDirectHit
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Damage type for direct mercury missile hit without missile blowing up.
//=============================================================================


class WVDamTypeMercuryPunchThrough extends WVDamTypeMercuryDirectHit abstract;


/**
No flame effects for punch through.
*/
static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth);


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     DeathString="%k drove a mercury missile through %o."
     GibModifier=2.000000
     GibPerterbation=0.500000
     KDeathVel=400.000000
}
