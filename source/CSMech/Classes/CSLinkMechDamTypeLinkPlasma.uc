class CSLinkMechDamTypeLinkPlasma extends VehicleDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
    DeathString="%o was served an extra helping of %k's mega plasma."
	MaleSuicide="%o fried himself with his own mega plasma blast."
	FemaleSuicide="%o fried herself with her own mega plasma blast."
	FlashFog=(X=700.00000,Y=0.000000,Z=0.00000)
    DamageOverlayMaterial=Material'XGameShaders.PlayerShaders.LinkHit'
    DamageOverlayTime=0.5

    VehicleClass=class'CSLinkMech'

    bDetonatesGoop=true
    VehicleDamageScaling=0.67
    bDelayedDamage=true
}

