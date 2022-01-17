//=============================================================================
// DamTypeMercuryDirectHit
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Damage type for mercury missile splash damage.
//=============================================================================


class WVDamTypeMercurySplashDamage extends VehicleDamageType abstract;


/**
Flame effects.
*/
static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth)
{
	HitEffects[0] = class'HitSmoke';

	if (VictimHealth <= 0)
		HitEffects[1] = class'HitFlameBig';
	else if (FRand() < 0.5)
		HitEffects[1] = class'HitFlame';
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     VehicleClass=Class'PVWraith.Banshee'
     DeathString="%o was way too slow for %k's Banshee missile."
     FemaleSuicide="%o checked if her Banshee's rocket launchers were loaded."
     MaleSuicide="%o checked if his Banshee's rocket launchers were loaded."
     bDetonatesGoop=True
     bKUseOwnDeathVel=True
     bDelayedDamage=True
     GibPerterbation=0.150000
     KDeathVel=150.000000
     KDeathUpKick=50.000000
}
