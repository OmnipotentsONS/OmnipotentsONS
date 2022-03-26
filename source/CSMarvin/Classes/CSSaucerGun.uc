//=============================================================================
// SaucerGun.
//=============================================================================
class CSSaucerGun extends ONSAttackCraftGun
	placeable;

defaultproperties
{
     WeaponFireAttachmentBone="PlasmaGunAttachment"
     DualFireOffset=44.000000
     FireSoundClass=Sound'CSMarvin.ProjectileShoot'
     FireSoundVolume=130.000000
     AltFireSoundClass=Sound'CSMarvin.EngineStop'
     AltFireSoundVolume=300.000000
     AltFireSoundRadius=600.000000
     AmbientSoundScaling=3.000000
     DamageType=Class'CSMarvin.CSMyDamTypeAttackCraftPlasma'
     ProjectileClass=Class'OnslaughtFull.ONSMASPlasmaProjectile'
     AltFireProjectileClass=Class'CSMarvin.CSPlasmaBurst'
     bSelected=True
}
