class DamTypePersesOmniNapalmRocket extends DamTypePersesOmniRocket abstract;


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
     DeathString="%o was roasted by %k's Perses napalm rocket."
     FemaleSuicide="%o roasted herself."
     MaleSuicide="%o roasted himself."
     FlashFog=(X=700.000000,Y=100.000000)
}
