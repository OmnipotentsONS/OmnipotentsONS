
class CSPlasmaFighterWeapon extends ONSWeapon;
var int GunOffset, BombFireOffset, ZFireOffset;
var float primaryInterval, secondaryInterval,MaxLockRange, LockAim;
var Controller CurrentController;

var class<Projectile> TeamProj[2];

simulated function CalcWeaponFire()
{
    local coords WeaponBoneCoords;
    local vector CurrentFireOffset;

    // Calculate fire offset in world space
    WeaponBoneCoords = GetBoneCoords(WeaponFireAttachmentBone);
    //CurrentFireOffset = (WeaponFireOffset * vect(1,0,0)) + (DualFireOffset * vect(0,1,0));
    CurrentFireOffset = (WeaponFireOffset * vect(1,0,0)) + (DualFireOffset * vect(0,1,0)) + (ZFireOffset * vect(0,0,1));

    // Calculate rotation of the gun
    WeaponFireRotation = rotator(vector(CurrentAim) >> Rotation);

    // Calculate exact fire location
    WeaponFireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> WeaponFireRotation);

    // Adjust fire rotation taking dual offset into account
    if (bDualIndependantTargeting)
        WeaponFireRotation = rotator(CurrentHitLocation - WeaponFireLocation);
}

function HomeProjectile(CSPlasmaFighterSecondaryProjectile R, Controller C, rotator FireRotation, vector FireLocation)
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

        if(R.HomingTarget != None && Vehicle(R.HomingTarget) != None)
        {
            Vehicle(R.HomingTarget).NotifyEnemyLockedOn();
        }
    }
}


function SpawnVolley(Controller C)
{
    local CSPlasmaFighterSecondaryProjectile R;
    DualFireOffset=GunOffset;
    CalcWeaponFire();
    R = spawn(class'CSPlasmaFighterSecondaryProjectile',self,,WeaponFireLocation, WeaponFireRotation);
    HomeProjectile(R, C, WeaponFireRotation, WeaponFireLocation);
    DualFireOffset*=-1;
    CalcWeaponFire();
    R = spawn(class'CSPlasmaFighterSecondaryProjectile',self,,WeaponFireLocation, WeaponFireRotation);
    HomeProjectile(R, C, WeaponFireRotation, WeaponFireLocation);
}

state ProjectileFireMode
{
    function Fire(Controller C)
    {
        ProjectileClass = TeamProj[Team];
        GotoState('PrimaryVolley');
    }

    function AltFire(Controller C)
    {
        CurrentController=C;
        GotoState('SecondaryVolley');
    }
}

state PrimaryVolley
{
Begin:
    DualFireOffset=GunOffset;
    CalcWeaponFire();
    SpawnProjectile(ProjectileClass, False);
    DualFireOffset*=-1;
    CalcWeaponFire();
    SpawnProjectile(ProjectileClass, False);
    //PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
    sleep(primaryInterval);

    DualFireOffset=GunOffset;
    CalcWeaponFire();
    SpawnProjectile(ProjectileClass, False);
    DualFireOffset*=-1;
    CalcWeaponFire();
    SpawnProjectile(ProjectileClass, False);
    //PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
    sleep(primaryInterval);
    
    DualFireOffset=GunOffset;
    CalcWeaponFire();
    SpawnProjectile(ProjectileClass, False);
    DualFireOffset*=-1;
    CalcWeaponFire();
    SpawnProjectile(ProjectileClass, False);
    //PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
    sleep(primaryInterval);

    GotoState('ProjectileFireMode');
}

state SecondaryVolley
{
Begin:
    SpawnVolley(CurrentController);
    PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
    sleep(secondaryInterval);

    SpawnVolley(CurrentController);
    PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
    sleep(secondaryInterval);

    SpawnVolley(CurrentController);
    PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
    sleep(secondaryInterval);

    GotoState('ProjectileFireMode');
}

function byte BestMode()
{
    local Bot B;
    B = Bot(Instigator.Controller);
    if(B != None)
    {
        if(B.Enemy != None)
        {
            if(VSize(Location - B.Enemy.Location) > 12000)
                return 1;
            else
                return 0;
        }
    }

    return 0;
}

defaultproperties
{
    Mesh=Mesh'ONSWeapons-A.PlasmaGun'
    YawBone=PlasmaGunBarrel
    PitchBone=PlasmaGunBarrel
    WeaponFireAttachmentBone=PlasmaGunBarrel
    MaxLockRange=15000
    LockAim=0.975
    ZFireOffset=40
    GunOffset=55
    BombFireOffset=5
    FireInterval=0.4
    PrimaryInterval=0.05
    AltFireInterval=2.0
    SecondaryInterval=0.2
    PitchUpLimit=18000
    PitchDownLimit=49153
    ProjectileClass=class'CSPlasmaFighterPrimaryProjectile'
    FireSoundClass=sound'ONSVehicleSounds-S.LaserSounds.Laser01'
    FireSoundVolume=80

    TeamProj(0)=class'CSPlasmaFighterPrimaryProjectile'
    TeamProj(1)=class'CSPlasmaFighterPrimaryProjectileBlue'
    AltFireProjectileClass=class'CSPlasmaFighterSecondaryProjectile'
    AltFireSoundClass=Sound'CSBomber.orangeprojectile'
    AltFireSoundVolume=128

    bInstantRotation=True
}