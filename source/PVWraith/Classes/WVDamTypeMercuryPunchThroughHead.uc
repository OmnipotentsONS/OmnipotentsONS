//=============================================================================
// WVDamTypeDirectHit
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Damage type for mercury missile hitting head without missile blowing up.
//=============================================================================


class WVDamTypeMercuryPunchThroughHead extends WVDamTypeMercuryHeadHit abstract;


/**
No flame effects for punch through.
*/
static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth);


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     DeathString="%k drove a mercury missile through %o's head."
     KDeathVel=400.000000
}
