/******************************************************************************
DamTypeDracoFlamethrower

Creation date: 2013-04-28 08:22
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DamTypeDracoFlamethrower extends VehicleDamageType abstract;


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
     VehicleClass=Class'WVDraco.Draco'
     DeathString="%o was roasted by %k's Draco flamethrower."
     FemaleSuicide="%o roasted herself."
     MaleSuicide="%o roasted himself."
     bDetonatesGoop=True
     bDelayedDamage=True
     bFlaming=True
     FlashFog=(X=700.000000,Y=100.000000)
     VehicleDamageScaling=0.500000
     VehicleMomentumScaling=0.500000
}
