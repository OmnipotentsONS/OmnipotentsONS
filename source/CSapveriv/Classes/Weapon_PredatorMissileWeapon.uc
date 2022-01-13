class Weapon_PredatorMissileWeapon extends ONSWeapon;

var float MinAim;
var float MaxLockRange, LockAim;


function byte BestMode()
{
	return 0;
}
state ProjectileFireMode
{

	function Fire(Controller C)
	{
		local PROJ_PredatorMissle M;
		local float BestAim, BestDist;
        M = PROJ_PredatorMissle(SpawnProjectile(ProjectileClass, True));
		if (M != None)
		{
			if (AIController(C) != None)
			    {
			     M.HomingTarget = Vehicle(C.Enemy);
				 M.SetHomingTarget();
		        }
			else
			   {
				BestAim = LockAim;
				M.HomingTarget = Vehicle(C.PickTarget(BestAim, BestDist, vector(WeaponFireRotation), WeaponFireLocation, MaxLockRange));
  		        M.SetHomingTarget();
               }
        }
	}
}

defaultproperties
{
     MinAim=0.900000
     //MaxLockRange=30000.000000
     MaxLockRange=8000.000000
     LockAim=0.975000
     YawBone="PlasmaGunBarrel"
     PitchBone="PlasmaGunBarrel"
     PitchUpLimit=18000
     PitchDownLimit=49153
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     WeaponFireOffset=85.000000
     DualFireOffset=116.000000
     RotationsPerSecond=0.200000
     bInstantRotation=True
     bDualIndependantTargeting=True
     //FireInterval=1.500000
     FireInterval=2.000000
     FireSoundClass=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'
     FireSoundVolume=70.000000
     FireForce="Laser01"
     ProjectileClass=Class'CSAPVerIV.PROJ_PredatorMissle'
     AIInfo(0)=(bLeadTarget=True,aimerror=400.000000,RefireRate=0.500000)
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
