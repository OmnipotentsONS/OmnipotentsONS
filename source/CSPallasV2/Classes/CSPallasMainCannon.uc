class CSPallasMainCannon extends ONSMASRocketPack;

#exec AUDIO IMPORT FILE=Sounds\pinkprojectile.wav
#exec AUDIO IMPORT FILE=Sounds\orangeprojectile.wav

function HomeProjectile(CSPallasMainCannonProjectile R, Controller C, rotator FireRotation, vector FireLocation)
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
    }
}


function SpawnVolley(Controller C)
{
    local coords WeaponBoneCoords;
    local vector CurrentFireOffset;
    local vector FireLocation;
    local rotator FireRotation;
    local CSPallasMainCannonVolleyProjectile R;

    // Calculate fire offset in world space
    WeaponBoneCoords = GetBoneCoords(WeaponFireAttachmentBone);

    // Calculate rotation of the gun
    FireRotation = rotator(vector(CurrentAim) >> Rotation);

    // Calculate exact fire location (x12)
    CurrentFireOffset = vect(150,50,50);
    FireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> FireRotation);
    R = spawn(class'CSPallasMainCannonVolleyProjectile',self,,FireLocation, FireRotation);
    HomeProjectile(R, C, FireRotation, FireLocation);

    CurrentFireOffset = vect(150,100,50);
    FireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> FireRotation);
    R = spawn(class'CSPallasMainCannonVolleyProjectile',self,,FireLocation, FireRotation);
    HomeProjectile(R, C, FireRotation, FireLocation);

    CurrentFireOffset = vect(150,50,0);
    FireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> FireRotation);
    R = spawn(class'CSPallasMainCannonVolleyProjectile',self,,FireLocation, FireRotation);
    HomeProjectile(R, C, FireRotation, FireLocation);

    CurrentFireOffset = vect(150,100,0);
    FireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> FireRotation);
    R = spawn(class'CSPallasMainCannonVolleyProjectile',self,,FireLocation, FireRotation);
    HomeProjectile(R, C, FireRotation, FireLocation);

    CurrentFireOffset = vect(150,50,-50);
    FireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> FireRotation);
    R = spawn(class'CSPallasMainCannonVolleyProjectile',self,,FireLocation, FireRotation);
    HomeProjectile(R, C, FireRotation, FireLocation);

    CurrentFireOffset = vect(150,100,-50);
    FireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> FireRotation);
    R = spawn(class'CSPallasMainCannonVolleyProjectile',self,,FireLocation, FireRotation);
    HomeProjectile(R, C, FireRotation, FireLocation);

    //
    CurrentFireOffset = vect(150,-50,-50);
    FireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> FireRotation);
    R = spawn(class'CSPallasMainCannonVolleyProjectile',self,,FireLocation, FireRotation);
    HomeProjectile(R, C, FireRotation, FireLocation);

    CurrentFireOffset = vect(150,-100,-50);
    FireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> FireRotation);
    R = spawn(class'CSPallasMainCannonVolleyProjectile',self,,FireLocation, FireRotation);
    HomeProjectile(R, C, FireRotation, FireLocation);

    CurrentFireOffset = vect(150,-50,0);
    FireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> FireRotation);
    R = spawn(class'CSPallasMainCannonVolleyProjectile',self,,FireLocation, FireRotation);
    HomeProjectile(R, C, FireRotation, FireLocation);

    CurrentFireOffset = vect(150,-100,0);
    FireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> FireRotation);
    R = spawn(class'CSPallasMainCannonVolleyProjectile',self,,FireLocation, FireRotation);
    HomeProjectile(R, C, FireRotation, FireLocation);

    CurrentFireOffset = vect(150,-50,50);
    FireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> FireRotation);
    R = spawn(class'CSPallasMainCannonVolleyProjectile',self,,FireLocation, FireRotation);
    HomeProjectile(R, C, FireRotation, FireLocation);

    CurrentFireOffset = vect(150,-100,50);
    FireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> FireRotation);
    R = spawn(class'CSPallasMainCannonVolleyProjectile',self,,FireLocation, FireRotation);
    HomeProjectile(R, C, FireRotation, FireLocation);
}

state ProjectileFireMode
{
	function Fire(Controller C)
	{
		local CSPallasMainCannonProjectile R;
		local float BestAim, BestDist;

		R = CSPallasMainCannonProjectile(SpawnProjectile(ProjectileClass, False));
        HomeProjectile(R, C, WeaponFireRotation, WeaponFireLocation);
	}

	function AltFire(Controller C)
	{
        SpawnVolley(C);
        PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);

	}
}

defaultproperties
{
    RedSkin=Shader'CSPallasV2.CSPallasRedShader'
    BlueSkin=Shader'CSPallasV2.CSPallasBlueShader'
    WeaponFireOffset=30.000000
    FireInterval=0.33
    AltFireInterval=1.75
    MaxLockRange=20000
    FireSoundClass=Sound'CSPallasV2.pinkprojectile'
    ProjectileClass=Class'CSPallasV2.CSPallasMainCannonProjectile'
    AltFireProjectileClass=Class'CSPallasV2.CSPallasMainCannonProjectile'
    AltFireSoundClass=Sound'CSPallasV2.orangeprojectile'
}
