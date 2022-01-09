//=============================================================================
// FireBadgerLaserTurret.
//=============================================================================
class FireBadgerLaserTurret extends FireTankSecondaryTurret;

state InstantFireMode 
{ 
    function AltFire(Controller C)
    {
		if (AltFireProjectileClass == None)
			Fire(C);
		else
			SpawnProjectile(AltFireProjectileClass, True);
    }
}

defaultproperties
{
     YawBone="MiniGunBase"
     PitchBone="MinigunBarrel"
     PitchUpLimit=8000
     PitchDownLimit=62500
     WeaponFireAttachmentBone="MinigunFire"
     RedSkin=Texture'MoreBadgers.FireBadger.FireBadgerRed'
     BlueSkin=Texture'MoreBadgers.FireBadger.FireBadgerBlue'
     AltFireInterval=0.100000
     AltFireForce="minifireb"
     DamageType=Class'CSBadgerFix.FireBadgerHeatRayKill'
     AltFireProjectileClass=Class'CSBadgerFix.BadgerFlameProjectile'
     Mesh=SkeletalMesh'CSBadgerFix.BadgerMinigun'
}
