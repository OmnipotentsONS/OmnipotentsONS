class DamType_Bomb extends WeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth )
{
    HitEffects[0] = class'HitFlame';
    HitEffects[1]=class'CSAPVerIV.FX_NukeFleshfire';
}

defaultproperties
{
     DeathString="%o's flesh got Vaporized by %k's Bomb!!!"
     FemaleSuicide="%o couldn't hide from her own Bomb!!!"
     MaleSuicide="%o couldn't hide from his own Bomb!!!"
     bArmorStops=False
     bSkeletize=True
     bSuperWeapon=True
     KDamageImpulse=20000.000000
}
