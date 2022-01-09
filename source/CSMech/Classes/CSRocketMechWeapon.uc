class CSRocketMechWeapon extends ONSWeapon;

#exec AUDIO IMPORT FILE=Sounds\RocketLauncherFire.wav


var float MinAim;
var class<xEmitter>     MuzFlashClass;
var xEmitter            MuzFlash;
var byte                flockIndex;
var float               AltFireCountdown;

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
}


simulated event FlashMuzzleFlash()
{
    local rotator r;

    super.FlashMuzzleFlash();

    if ( Level.NetMode != NM_DedicatedServer && FlashCount > 0 )
	{
        if (MuzFlash == None)
        {
            MuzFlash = Spawn(MuzFlashClass);
            if ( MuzFlash != None )
				AttachToBone(MuzFlash, 'tip');
        }
        if (MuzFlash != None)
        {
            MuzFlash.mStartParticles++;
            r.Roll = Rand(65536);
            SetBoneRotation('Bone_Flash', r, 0, 1.f);
        }
    }
}


simulated function GetViewAxes( out vector xaxis, out vector yaxis, out vector zaxis )
{
    if ( Instigator.Controller == None )
        GetAxes( Instigator.Rotation, xaxis, yaxis, zaxis );
    else
        GetAxes( Instigator.Controller.Rotation, xaxis, yaxis, zaxis );
}

state ProjectileFireMode
{
	function Fire(Controller C)
	{
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

		Super.Fire(C);
	}

    function AltFire(Controller C)
    {
        local int i,p,q,count;
        local vector FireLocation, StartProj,X,Y,Z;
        local CSRocketMechRocketProjectile FiredRockets[4];
        local bool bCurl;

        /*
        if (AltFireProjectileClass == None)
            Fire(C);
        else
            SpawnProjectile(AltFireProjectileClass, True);
            */

        StartProj = WeaponFireLocation;
        count = 3;
        GetViewAxes(X,Y,Z);

         for ( p=0; p<count; p++ )
        {
            Firelocation = StartProj - 2*((Sin(p*2*PI/count)*8 - 7)*Y - (Cos(p*2*PI/count)*8 - 7)*Z) - X * 8 * FRand();
            FiredRockets[p] = CSRocketMechRocketProjectile(spawn(AltFireProjectileClass,,,FireLocation, WeaponFireRotation));
            PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
        }

        FlashMuzzleFlash();

        FlockIndex++;
        if ( FlockIndex == 0 )
            FlockIndex = 1;

            
        // To get crazy flying, we tell each projectile in the flock about the others.
        for ( p = 0; p < count; p++ )
        {
            if ( FiredRockets[p] != None )
            {
                FiredRockets[p].bCurl = bCurl;
                FiredRockets[p].FlockIndex = FlockIndex;
                i = 0;
                for ( q=0; q<count; q++ )
                    if ( (p != q) && (FiredRockets[q] != None) )
                    {
                        FiredRockets[p].Flock[i] = FiredRockets[q];
                        i++;
                    }	
                bCurl = !bCurl;
                if ( Level.NetMode != NM_DedicatedServer )
                    FiredRockets[p].SetTimer(0.1, true);
            }
        }


    }
}

simulated function Tick(float DT)
{
    local ONSVehicle V;
    super.Tick(DT);

    V = ONSVehicle(Owner);
    if(AltFireCountdown > 0)
    {
        AltFireCountdown -= DT;
        if(AltFireCountdown <= 0 && Level.NetMode != NM_DedicatedServer)
        {
            if(V != None && V.IsLocallyControlled() && V.IsHumanControlled() && V.bWeaponIsAltFiring)
            {
                OwnerEffects();
            }
        }
    }

    if(Instigator != None && Instigator.Controller != None)
    {
        if (Role == ROLE_Authority && AltFireCountdown <= 0)
        {
            if (V != None && V.bWeaponisAltFiring)
            {
                if (AttemptFire(Instigator.Controller, true))
                    V.ApplyFireImpulse(true);
            }
        }
    }
}

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;

	if (FireCountdown <= 0 && !bAltFire)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
        FireCountdown = FireInterval;
        Fire(C);
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

	    return True;
	}

	if (AltFireCountdown <= 0 && bAltFire)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
        AltFireCountdown = AltFireInterval;
        AltFire(C);
		AimLockReleaseTime = Level.TimeSeconds + AltFireCountdown * FireIntervalAimLock;

	    return True;
	}

	return False;
}

defaultproperties
{
    Mesh=mesh'Weapons.RocketLauncher_3rd'
    YawBone='Bone_weapon'
    PitchBone='Bone_weapon'
    DrawScale=2.5
    MuzFlashClass=class'CSRocketMechRocketMuzFlash'

    YawStartConstraint=0
    YawEndConstraint=65535
    PitchUpLimit=18000
    PitchDownLimit=49153

    ProjectileClass=class'CSRocketMechRocketProjectile'
    FireSoundClass=Sound'CSMech.RocketLauncherFire'
    FireSoundVolume=255
    FireSoundRadius=500
    FireInterval=1.25

    AltFireProjectileClass=class'CSRocketMechRocketProjectile'
    AltFireSoundClass=Sound'CSMech.RocketLauncherFire'
    AltFireSoundRadius=500
    AltFireInterval=3.25

    RotateSound=sound'CSMech.turretturn'
    RotateSoundThreshold=50.0

    WeaponFireAttachmentBone=Bone_Flash
    WeaponFireOffset=0.0
    bAimable=True
    bInstantRotation=true
    DualFireOffset=0
    AIInfo(0)=(bLeadTarget=true,RefireRate=0.95)
    AIInfo(1)=(bLeadTarget=true,AimError=400,RefireRate=0.50)
    MinAim=0.900
}