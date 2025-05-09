class CSLinkMechDamTypeLinkShaft extends VehicleDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
    DeathString="%o was carved up by %k's mega green shaft."
	MaleSuicide="%o shafted himself."
	FemaleSuicide="%o shafted herself."

    VehicleClass=class'CSLinkMech'

    bDetonatesGoop=true
    bCausesBlood=false
	bLeaveBodyEffect=true
	bSkeletize=true

    DamageOverlayMaterial=Material'XGameShaders.PlayerShaders.LinkHit'
    DamageOverlayTime=0.5
}

