//=============================================================================
// BadgertaurLaserTurret.
//=============================================================================
class BadgertaurLaserTurret extends MinotaurSecondaryTurret;

defaultproperties
{
     YawBone="MiniGunBase"
     YawStartConstraint=57344.000000
     YawEndConstraint=8192.000000
     PitchBone="MinigunBarrel"
     PitchUpLimit=12000
     PitchDownLimit=56000
     WeaponFireAttachmentBone="MinigunFire"
     RedSkin=Texture'MoreBadgers.Badgertaur.BadgertaurRed'
     BlueSkin=Texture'MoreBadgers.Badgertaur.BadgertaurBlue'
     DamageType=Class'BadgerTaurV2Omni.MegabadgerLaserKill'
     Mesh=SkeletalMesh'Badger_Ani.BadgerMinigun'
     DrawScale=2.000000
}
