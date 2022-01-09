//=============================================================================
// IonPlasmaBadgerWeapon.
//=============================================================================
class IonPlasmaBadgerWeapon extends IonTankTeamColorWeapon;

var() vector FireImpulse;

function TraceFire(Vector Start, Rotator Dir)
{
	Super.TraceFire(Start, Dir);
	Pawn(Base).KAddImpulse(FireImpulse >> Dir, Start, 'TurretSpawn');
}

defaultproperties
{
     FireImpulse=(X=-150000.000000)
     YawBone="BadgerTurret"
     PitchBone="TurretBarrel"
     WeaponFireAttachmentBone="TurretFire"
     WeaponFireOffset=80.000000
     RedSkin=Shader'MoreBadgers.IonBadger.IonBadgerRedShader'
     BlueSkin=Shader'MoreBadgers.IonBadger.IonBadgerBlueShader'
     FireInterval=2.000000
     AltFireInterval=0.000000
     Mesh=SkeletalMesh'CSBadgerFix.BadgerTurret'
     bSelected=True
}
