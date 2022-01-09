class CSShockMechDamTypeShockBall extends VehicleDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
    DeathString="%o was wasted by %k's mega shock core."
	MaleSuicide="%o snuffed himself with the mega shock core."
	FemaleSuicide="%o snuffed herself with the mega shock core."

    VehicleClass=class'CSShockMech'
    bDetonatesGoop=true

    DamageOverlayMaterial=Material'UT2004Weapons.ShockHitShader'
    DamageOverlayTime=0.8
    bDelayedDamage=true
}

