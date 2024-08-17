class DamTypeOmniNukeHeat extends WeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth )
{
    HitEffects[0] = class'HitFlame';
    HitEffects[1] = class'HitFlameBig';
    HitEffects[2]=class'OmniNukes.OmniNukeFleshfire';
}

defaultproperties
{
     WeaponClass=Class'OmniNukes.OmniRedeemerII'
     DeathString="%o was crisply cooked by %k's Nuke!!!"
     FemaleSuicide="%o cooked her ass by her own Nuke!!!"
     MaleSuicide="%o cooked his ass by his own Nuke!!!"
     bDetonatesGoop=True
     bSkeletize=True
     bSuperWeapon=True
}
