/**
WVDraco.DamTypeDracoNapalmGlob

Creation date: 2013-11-11 10:16
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class DamTypeDracoNapalmGlob extends VehicleDamageType abstract;


static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth)
{
	HitEffects[0] = class'HitSmoke';

	if (VictimHealth <= 0)
		HitEffects[1] = class'HitFlameBig';
	else if (FRand() < 0.8)
		HitEffects[1] = class'HitFlame';
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     VehicleClass=Class'WVDraco.DracoRocketPackPawn'
     DeathString="%o was roasted by %k's Draco napalm."
     FemaleSuicide="%o roasted herself."
     MaleSuicide="%o roasted himself."
     bDetonatesGoop=True
     bDelayedDamage=True
     bFlaming=True
     FlashFog=(X=700.000000,Y=100.000000)
     VehicleDamageScaling=0.250000
     VehicleMomentumScaling=0.500000
}
