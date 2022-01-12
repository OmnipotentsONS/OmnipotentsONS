class CSMarvinLaserWeapon extends ONSWeapon;

#exec AUDIO IMPORT File=Sounds\ProjectileShoot.wav 
#exec AUDIO IMPORT File=Sounds\ProjectileShootLow.wav 

var class<Projectile> TeamProjectileClasses[2];
var int MaxLockRange;
var float LockAim;

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
        local CSMarvinMissileProjectile p;
        P = CSMarvinMissileProjectile(SpawnProjectile(AltFireProjectileClass, True));
        HomeProjectile(P, C, WeaponFireRotation, WeaponFireLocation);
    }
}

function HomeProjectile(CSMarvinMissileProjectile R, Controller C, rotator FireRotation, vector FireLocation)
{
    local float BestAim, BestDist;
    if (R != None)
    {
        if (AIController(C) != None)
            R.HomingTarget = C.Enemy;
        else
        {
            BestAim = LockAim;
            R.HomingTarget = C.PickTarget(BestAim, BestDist, vector(FireRotation), FireLocation, MaxLockRange);
        }

        if(R.HomingTarget != None && Vehicle(R.HomingTarget) == None)
            R.HomingTarget=None;

        if(R.HomingTarget != None && Vehicle(R.HomingTarget) != None)
        {
            Vehicle(R.HomingTarget).NotifyEnemyLockedOn();
        }
    }
}


defaultproperties
{
    Mesh=Mesh'ONSWeapons-A.PlasmaGun'
    YawBone=PlasmaGunBarrel
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchBone=PlasmaGunBarrel
    PitchUpLimit=18000
    PitchDownLimit=49153
    FireSoundClass=sound'CSMarvin.ProjectileShoot'
    AltFireSoundClass=sound'CSMarvin.ProjectileShootLow'
    FireForce="Laser01"
    AltFireForce="Laser01"
    //ProjectileClass=class'CSMarvinProjectileRed'
    ProjectileClass=Class'CSMarvin.CSMarvinLaserProjectile'
    TeamProjectileClasses(0)=Class'CSMarvin.CSMarvinLaserProjectile'
    TeamProjectileClasses(1)=Class'CSMarvin.CSMarvinLaserProjectileBlue'

    FireInterval=0.22
    //AltFireProjectileClass=class'CSMarvinProjectileBlue'
    AltFireProjectileClass=class'CSMarvin.CSMarvinMissileProjectile'
    AltFireInterval=1.2
    WeaponFireAttachmentBone=PlasmaGunAttachment
    WeaponFireOffset=0.0
    bAimable=True
    RotationsPerSecond=1.2
    DualFireOffset=44
    //MinAim=0.900
    //bDoOffsetTrace=true
    MaxLockRange=20000
    LockAim=0.975
}