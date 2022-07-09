class CSDarkLeviFlakTurret extends ONSWeapon;

var int FlakSpread;


function Projectile SpawnShard()
{
    local Projectile P;
    local ONSWeaponPawn WeaponPawn;
    local vector StartLocation, HitLocation, HitNormal, Extent, X;
    local rotator R;

    Extent = ProjectileClass.default.CollisionRadius * vect(1,1,0);
    Extent.Z = ProjectileClass.default.CollisionHeight;
    WeaponPawn = ONSWeaponPawn(Owner);
    if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
    {
        if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5), Extent))
            StartLocation = HitLocation;
        else
            StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjectileClass.default.CollisionRadius * 1.1);
    }
    else
    {
        if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
            StartLocation = HitLocation;
        else
            StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjectileClass.default.CollisionRadius * 1.1);
    }

    R.Yaw = FlakSpread * (FRand()-0.5);
    R.Pitch = FlakSpread * (FRand()-0.5);
    R.Roll = FlakSpread * (FRand()-0.5);
    X = vector(WeaponFireRotation);
    P = spawn(ProjectileClass, self, , StartLocation, rotator(X >> R));

    return P;
}

state ProjectileFireMode
{
	function Fire(Controller C)
	{
        local int i;
        for(i=0;i<20;i++)
        {
            SpawnShard();
        }

        FlashMuzzleFlash();
        PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
	}

    function AltFire(Controller C)
    {
		//Super.AltFire(C);
        SpawnProjectile(AltFireProjectileClass, true);
    }
}


defaultproperties
{
    Mesh=Mesh'ONSWeapons-A.PRVsideGUN'
    YawBone=SIDEgunBASE
    PitchBone=SIDEgunBARREL
    DrawScale=2.0
    //Mesh=Mesh'ONSFullAnimations.MASRocketPack'
    //YawBone=RocketPivot
    YawStartConstraint=0
    YawEndConstraint=65535
    //PitchBone=RocketPacks
    PitchUpLimit=18000
    PitchDownLimit=60000
    FireSoundClass=Sound'WeaponSounds.FlakCannon.FlakCannonFire'

    FireForce="RocketLauncherFire"
    ProjectileClass=class'CSDarkLeviFlakChunk'
    FireInterval=1.07364
    AltFireProjectileClass=class'CSDarkLeviFlakShell'
    AltFireInterval=1.11
    WeaponFireAttachmentBone=Firepoint
    WeaponFireOffset=0.0
    bDoOffsetTrace=true
    bAimable=True
    CollisionRadius=+60.0

    FlakSpread=1400
}