/******************************************************************************
DamTypeHoverTankBeam

Creation date: 2011-08-07 13:42
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DamTypePoltergeistBeam extends VehicleDamageType abstract;


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
     VehicleClass=Class'WVHoverTankV2.PoltergeistTank'
     DeathString="%o was fried by %k's heat ray."
     FemaleSuicide="%o fried herself."
     MaleSuicide="%o fried himself."
     bInstantHit=True
     bAlwaysSevers=True
     bDetonatesGoop=True
     bFlaming=True
     GibModifier=2.000000
     FlashFog=(X=800.000000,Y=600.000000,Z=240.000000)
     GibPerterbation=0.500000
     VehicleDamageScaling=1.500000
     VehicleMomentumScaling=2.000000
}
