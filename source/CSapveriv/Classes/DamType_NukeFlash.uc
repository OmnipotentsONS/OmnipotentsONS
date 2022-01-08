class DamType_NukeFlash extends WeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth )
{
    HitEffects[0] = class'HitFlame';
    HitEffects[1]=class'CSAPVerIV.FX_NukeFleshfire';
}

defaultproperties
{
     DeathString="%o's flesh got Vaporized by %k's Nuke!!!"
     FemaleSuicide="%o couldn't hide from her own Nuke!!!"
     MaleSuicide="%o couldn't hide from his own Nuke!!!"
     bArmorStops=False
     bSkeletize=True
     bSuperWeapon=True
     KDamageImpulse=40000.000000
     VehicleDamageScaling=2.000000
}
