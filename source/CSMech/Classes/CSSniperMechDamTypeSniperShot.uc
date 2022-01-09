class CSSniperMechDamTypeSniperShot extends VehicleDamageType
    abstract;

defaultproperties
{
    DeathString="%o rode %k's mega lightning."
	MaleSuicide="%o had an electrifying experience."
	FemaleSuicide="%o had an electrifying experience."

    DamageOverlayMaterial=Material'XGameShaders.PlayerShaders.LightningHit'
    DamageOverlayTime=0.9

    VehicleClass=class'CSSniperMech'

    GibPerterbation=0.25
    bDetonatesGoop=true

    bCauseConvulsions=true
    VehicleDamageScaling=0.85
}