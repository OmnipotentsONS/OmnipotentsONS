//=============================================================================
// WVDamTypeDirectHit
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Damage type for direct mercury missile hit with missile blowing up.
//=============================================================================


class PVWDamTypeMercuryDirectHit extends VehicleDamageType abstract;


/**
Flame effects.
*/
static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth)
{
	HitEffects[0] = class'HitSmoke';

	if (VictimHealth <= 0 && FRand() < 0.5)
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
     DeathString="%k drove a Wraith missile into %o."
     FemaleSuicide="%o somehow managed to get hit by her own Wraith missile."
     MaleSuicide="%o somehow managed to get hit by his own Wraith missile."
     bDetonatesGoop=True
     bKUseOwnDeathVel=True
     bDelayedDamage=True
     bRagdollBullet=True
     bBulletHit=True
     GibPerterbation=0.350000
     KDamageImpulse=20000.000000
     KDeathVel=550.000000
     KDeathUpKick=100.000000
}
