class Weapon_PredatorWeapon extends ONSWeapon;

var class<Projectile> TeamProjectileClasses[2];
var float MinAim;
var float MaxLockRange, LockAim;


function byte BestMode()
{
	local bot B;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return 0;

	if ( (Vehicle(B.Enemy) != None)
	     && (B.Enemy.bCanFly || B.Enemy.IsA('ONSHoverCraft')) && (FRand() < 0.3 + 0.1 * B.Skill) )
		return 1;
	else
		return 0;
}
state ProjectileFireMode
{
	function Fire(Controller C)
	{
		if (Vehicle(Owner) != None && Vehicle(Owner).Team < 2)
			ProjectileClass = TeamProjectileClasses[Vehicle(Owner).Team];
		else
			ProjectileClass = TeamProjectileClasses[0];

		Super.Fire(C);
	}

	function AltFire(Controller C)
	{
		local PROJ_PredatorMissle M;
		local float BestAim, BestDist;

		M = PROJ_PredatorMissle(SpawnProjectile(AltFireProjectileClass, True));
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
     TeamProjectileClasses(0)=Class'CSAPVerIV.PROJ_Falcon_Laser_Red'
     TeamProjectileClasses(1)=Class'CSAPVerIV.PROJ_Falcon_Laser'
     MinAim=0.900000
     //MaxLockRange=30000.000000
     MaxLockRange=0.000000
     LockAim=0.975000
     YawBone="PlasmaGunBarrel"
     PitchBone="PlasmaGunBarrel"
     PitchUpLimit=18000
     PitchDownLimit=49153
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     WeaponFireOffset=85.000000
     DualFireOffset=75.000000
     RotationsPerSecond=0.200000
     bInstantRotation=True
     bDualIndependantTargeting=True
     //FireInterval=0.140000
     FireInterval=0.210000
     AltFireInterval=1.500000
     FireSoundClass=SoundGroup'WeaponSounds.AssaultRifle.AssaultRifleFire'
     AltFireSoundClass=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'
     FireForce="Laser01"
     ProjectileClass=Class'CSAPVerIV.PROJ_Falcon_Laser_Red'
     AltFireProjectileClass=Class'CSAPVerIV.PROJ_PredatorMissle'
     AIInfo(0)=(bLeadTarget=True,aimerror=400.000000,RefireRate=0.500000)
     AIInfo(1)=(bLeadTarget=True,aimerror=400.000000,RefireRate=0.500000)
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
