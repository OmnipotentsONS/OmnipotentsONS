/**
Creation date: 2013-12-12 13:23
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class DamTypePersesOmniRocket extends VehicleDamageType abstract hidedropdown;


/** Flame effects. */
static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth)
{
	HitEffects[0] = class'HitSmoke';

	if (VictimHealth <= 0)
		HitEffects[1] = class'HitFlameBig';
	else if (FRand() < 0.5)
		HitEffects[1] = class'HitFlame';
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     VehicleClass=Class'PersesOmni.PersesOmniMAS'
     bDetonatesGoop=True
     bDelayedDamage=True
     bThrowRagdoll=True
     bFlaming=True
     GibPerterbation=0.150000
     KDamageImpulse=20000.000000
}
