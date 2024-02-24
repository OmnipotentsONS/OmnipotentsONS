

class DamTypeFBONapalmGlob extends VehicleDamageType abstract;


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
     VehicleClass=Class'FireBladeOmni'
     DeathString="%o was charred by %k's FireBlade napalm."
     FemaleSuicide="%o charred herself."
     MaleSuicide="%o Charred himself."
     bDetonatesGoop=True
     bDelayedDamage=True
     bFlaming=True
     FlashFog=(X=700.000000,Y=100.000000)
     VehicleDamageScaling=0.75000
     VehicleMomentumScaling=0.500000
}
