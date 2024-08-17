class DamTypeOmniNukeFlash extends WeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth )
{
    HitEffects[0] = class'HitFlame';
    HitEffects[1]=class'OmniNukes.OmniNukeFleshfire';
}

defaultproperties
{
     WeaponClass=Class'OmniNukes.OmniRedeemerII'
     DeathString="%o's flesh got vaporized by %k's Nuke!!!"
     FemaleSuicide="%o own Nuke vaporized herself!!!"
     MaleSuicide="%o own Nuke vaporized himself!!!"
     bArmorStops=False
     bSkeletize=True
     bSuperWeapon=True
}
