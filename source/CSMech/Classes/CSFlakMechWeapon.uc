class CSFlakMechWeapon extends ONSWeapon;

#exec AUDIO IMPORT FILE=Sounds\FlakCannonFire.wav
#exec AUDIO IMPORT FILE=Sounds\FlakCannonAltFire.wav

var float MinAim;
var class<xEmitter>     MuzFlashClass;
var xEmitter            MuzFlash;
var int                 FlakSpread;
var float               AltFireCountdown;

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
        local int i;
        local vector X;
        local rotator R;
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

		//Super.Fire(C);
        X = vector(WeaponFireRotation);
        for(i=0;i<20;i++)
        {
            R.Yaw = FlakSpread * (FRand()-0.5);
            R.Pitch = FlakSpread * (FRand()-0.5);
            R.Roll = FlakSpread * (FRand()-0.5);
            spawn(ProjectileClass,,,WeaponFireLocation, rotator(X >> R));
        }

        FlashMuzzleFlash();
        PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
	}

    function AltFire(Controller C)
    {
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

		//Super.AltFire(C);
        SpawnProjectile(AltFireProjectileClass, true);
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
    Mesh=mesh'Weapons.Flak_3rd'
    YawBone='Bone_weapon'
    PitchBone='Bone_weapon'
    DrawScale=2.5
    MuzFlashClass=class'CSRocketMechRocketMuzFlash'

    YawStartConstraint=0
    YawEndConstraint=65535
    PitchUpLimit=18000
    PitchDownLimit=49153
    
    ProjectileClass=class'CSFlakMechFlakChunk'
    FireSoundClass=Sound'CSMech.FlakCannonFire'
    FireSoundVolume=255
    FireSoundRadius=500
    //FireInterval=0.8947
    FireInterval=1.07364
    FlakSpread=1400

    AltFireProjectileClass=class'CSFlakMechFlakShell'
    AltFireSoundClass=Sound'CSMech.FlakCannonAltFire'

    AltFireSoundRadius=500
    //AltFireInterval=1.11
    AltFireInterval=1.32

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