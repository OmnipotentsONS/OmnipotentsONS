//=============================================================================
// BioBadgerBeamTurret.
//=============================================================================
class BioBadgerBeamTurret extends BioSecondaryTurret;

defaultproperties
{
     YawBone="MiniGunBase"
     PitchBone="MinigunBarrel"
     PitchUpLimit=8000
     PitchDownLimit=62500
     WeaponFireAttachmentBone="MinigunFire"
     WeaponFireOffset=80.000000
     RedSkin=Texture'MoreBadgers.BioBadger.BioBadgerRed'
     BlueSkin=Texture'MoreBadgers.BioBadger.BioBadgerBlue'
     DamageType=Class'CSBadgerFix.BioBadgerBeamKill'
     Mesh=SkeletalMesh'CSBadgerFix.BadgerMinigun'
}
