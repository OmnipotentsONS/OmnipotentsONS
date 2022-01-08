class DamType_NukeHeat extends WeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth )
{
    HitEffects[0] = class'HitFlame';
    HitEffects[1] = class'HitFlameBig';
    HitEffects[2]=class'CSAPVerIV.FX_NukeFleshfire';
}

defaultproperties
{
     DeathString="%o was crisply cooked by %k's Nuke!!!"
     FemaleSuicide="%o stayed at her own Nuke!!!"
     MaleSuicide="%o stayed at his own Nuke!!!"
     bDetonatesGoop=True
     bSkeletize=True
     bSuperWeapon=True
     KDamageImpulse=40000.000000
     VehicleDamageScaling=2.000000
}
