//=============================================================================
// DamTypeMercuryDirectHit
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Damage type for mercury missile splash damage.
//=============================================================================


class PVWDamTypeMercurySplashDamage extends VehicleDamageType abstract;


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
     VehicleClass=Class'PVWraith.Wraith'
     DeathString="%o was way too slow and got splatted by %k's Wraith missile."
     FemaleSuicide="%o checked if her Wraith's rocket launchers were loaded."
     MaleSuicide="%o checked if his Wraith's rocket launchers were loaded."
     bDetonatesGoop=True
     bKUseOwnDeathVel=True
     bDelayedDamage=True
     GibPerterbation=0.150000
     KDeathVel=150.000000
     KDeathUpKick=50.000000
     VehicleDamageScaling=1.4
     VehicleMomentumScaling=1.0
}
