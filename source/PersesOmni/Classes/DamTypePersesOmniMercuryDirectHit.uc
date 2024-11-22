//=============================================================================
// DamTypePersesDirectHit
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Damage type for direct mercury missile hit with missile blowing up.
//=============================================================================


class DamTypePersesOmniMercuryDirectHit extends DamTypePersesOmniRocket abstract;


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
     DeathString="%k drove a Perses mercury missile into %o."
     FemaleSuicide="%o somehow managed to get hit by her own mercury missile."
     MaleSuicide="%o somehow managed to get hit by his own mercury missile."
     bKUseOwnDeathVel=True
     bRagdollBullet=True
     bBulletHit=True
     GibPerterbation=0.350000
     KDeathVel=550.000000
     KDeathUpKick=100.000000
     VehicleDamageScaling=1.25
     VehicleMomentumScaling=1.5
}
