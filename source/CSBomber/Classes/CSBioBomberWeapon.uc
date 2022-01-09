
class CSBioBomberWeapon extends ONSWeapon;

#exec OBJ LOAD FILE=..\Textures\TurretParticles.utx
#exec AUDIO IMPORT FILE=Sounds\BioBeam.wav

var class<CSBioBomberBeamEffect> BeamEffectClass[2];
var coords boneCoords;
var vector loc;
var float BombInterval, BombSpread;
var actor LastHitActor;
var vector LastHitNormal;
var int GunOffset, BombFireOffset, ZFireOffset, BombZOffset;


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


event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;

	if (FireCountdown <= 0)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
		if (bAltFire)
		{
			FireCountdown = AltFireInterval;
			AltFire(C);
		}
		else
		{
		    FireCountdown = FireInterval;
		    Fire(C);
		}
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

	    return True;
	}

	return False;
}
function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
    local int Damage;
    local vector LStart, RStart;

    DualFireOffset=GunOffset;
    CalcWeaponFire();
    LStart = WeaponFireLocation;

    X = Vector(Dir);
    End = LStart + TraceRange * X;

    //skip past vehicle driver
    if (ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
    {
      	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
       	Other = Trace(HitLocation, HitNormal, End, LStart, True);
       	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
    }
    else
       	Other = Trace(HitLocation, HitNormal, End, LStart, True);

    if (Other != None)
    {
        if (!Other.bWorldGeometry)
        {
            Damage = (DamageMin + Rand(DamageMax - DamageMin));
            Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
            HitNormal = vect(0,0,0);
        }
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

    DualFireOffset *= -1;
    CalcWeaponFire();
    RStart = WeaponFireLocation;
    X = Vector(Dir);
    End = RStart + TraceRange * X;

    //skip past vehicle driver
    if (ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
    {
      	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
       	Other = Trace(HitLocation, HitNormal, End, RStart, True);
       	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
    }
    else
       	Other = Trace(HitLocation, HitNormal, End, RStart, True);

    if (Other != None)
    {
        if (!Other.bWorldGeometry)
        {
            Damage = (DamageMin + Rand(DamageMax - DamageMin));
            Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
            HitNormal = vect(0,0,0);
        }
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }


    HitCount++;
    LastHitLocation = HitLocation;
    LastHitNormal = HitNormal;
    LastHitActor = Other;

    End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, True);
    DualFireOffset=0;

    NetUpdateTime = Level.TimeSeconds - 1;
    SpawnHitEffects(Other, HitLocation, HitNormal);
}

state InstantFireMode
{
    function Fire(Controller C)
    {
        FlashMuzzleFlash();

        PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,false, FireSoundRadius,, false);

        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }

	simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
	{
		local CSBioBomberBeamEffect Beam;
        local vector X, End;

		if (Level.NetMode != NM_DedicatedServer)
		{
            DualFireOffset=GunOffset;
            CalcWeaponFire();
            X = Vector(WeaponFireRotation);
            End = WeaponFireLocation + TraceRange * X;
            if(ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
                ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
            HitActor = Trace(HitLocation, HitNormal, End, WeaponFireLocation, True);
            if(ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
                ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
            if(HitActor == None)
            {
                HitLocation = End;
                HitNormal = vect(0,0,0);
            }

			Beam = Spawn(BeamEffectClass[Team],,, WeaponFireLocation, rotator(HitLocation - WeaponFireLocation));
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);

            if(HitActor != None && HitActor.bWorldGeometry)
            {
                //Spawn(class'CSBomberBulletHit',,, HitLocation, rotator(HitNormal));
                //Spawn(class'CSBulletScorchMark',,,HitLocation, rotator(-HitNormal));

                //Spawn(class'BioBigGoopSmoke',,, HitLocation, rotator(HitNormal));
                Spawn(class'CSBioBomberBigGoopSparks',,,HitLocation, rotator(HitNormal));
            }

            DualFireOffset*=-1;
            CalcWeaponFire();
            X = Vector(WeaponFireRotation);
            End = WeaponFireLocation + TraceRange * X;
            if(ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
                ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
            HitActor = Trace(HitLocation, HitNormal, End, WeaponFireLocation, True);
            if(ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
                ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
            if(HitActor == None)
            {
                HitLocation = End;
                HitNormal = vect(0,0,0);
            }

			Beam = Spawn(BeamEffectClass[Team],,, WeaponFireLocation, rotator(HitLocation - WeaponFireLocation));
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);

            if(HitActor != None && HitActor.bWorldGeometry)
            {
                //Spawn(class'CSBomberBulletHit',,, HitLocation, rotator(HitNormal));
                //Spawn(class'CSBulletScorchMark',,,HitLocation, rotator(-HitNormal));

                //Spawn(class'BioBigGoopSmoke',,, HitLocation, rotator(HitNormal));
                Spawn(class'CSBioBomberBigGoopSparks',,,HitLocation, rotator(HitNormal));
            }

            DualFireOffset=0;
		}

        NetUpdateTime = Level.TimeSeconds - 1;
	}

    function AltFire(Controller C)
    {
        GotoState('BombDropping');
    }
}

state BombDropping
{
Begin:
    boneCoords = Owner.GetBoneCoords('FrontGunMount');
    loc = boneCoords.Origin;
    loc = loc + ((0 * vect(1,0,0) + (BombFireOffset * vect(0,1,0)) + (BombZOffset * vect(0,0,1)) >> Rotation));
    spawn(AltFireProjectileClass,,,loc,rotator(vector(rotation)+vrand()*frand()*BombSpread));

    boneCoords = Owner.GetBoneCoords('FrontGunMount');
    loc = boneCoords.Origin;
    loc = loc + ((0 * vect(1,0,0) + (-BombFireOffset * vect(0,1,0)) + (BombZOffset * vect(0,0,1)) >> Rotation));
    spawn(AltFireProjectileClass,,,loc, rotator(vector(rotation)+vrand()*frand()*BombSpread));
    sleep(bombInterval);

    //
    boneCoords = Owner.GetBoneCoords('FrontGunMount');
    loc = boneCoords.Origin;
    loc = loc + ((0 * vect(1,0,0) + (BombFireOffset * vect(0,1,0)) + (BombZOffset * vect(0,0,1)) >> Rotation));
    spawn(AltFireProjectileClass,,,loc,rotator(vector(rotation)+vrand()*frand()*BombSpread));

    boneCoords = Owner.GetBoneCoords('FrontGunMount');
    loc = boneCoords.Origin;
    loc = loc + ((0 * vect(1,0,0) + (-BombFireOffset * vect(0,1,0)) + (BombZOffset * vect(0,0,1)) >> Rotation));
    spawn(AltFireProjectileClass,,,loc, rotator(vector(rotation)+vrand()*frand()*BombSpread));
    sleep(bombInterval);

    //
    boneCoords = Owner.GetBoneCoords('FrontGunMount');
    loc = boneCoords.Origin;
    loc = loc + ((0 * vect(1,0,0) + (BombFireOffset * vect(0,1,0)) + (BombZOffset * vect(0,0,1)) >> Rotation));
    spawn(AltFireProjectileClass,,,loc,rotator(vector(rotation)+vrand()*frand()*BombSpread));

    boneCoords = Owner.GetBoneCoords('FrontGunMount');
    loc = boneCoords.Origin;
    loc = loc + ((0 * vect(1,0,0) + (-BombFireOffset * vect(0,1,0)) + (BombZOffset * vect(0,0,1)) >> Rotation));
    spawn(AltFireProjectileClass,,,loc, rotator(vector(rotation)+vrand()*frand()*BombSpread));
    sleep(bombInterval);

    //
    boneCoords = Owner.GetBoneCoords('FrontGunMount');
    loc = boneCoords.Origin;
    loc = loc + ((0 * vect(1,0,0) + (BombFireOffset * vect(0,1,0)) + (BombZOffset * vect(0,0,1)) >> Rotation));
    spawn(AltFireProjectileClass,,,loc,rotator(vector(rotation)+vrand()*frand()*BombSpread));

    boneCoords = Owner.GetBoneCoords('FrontGunMount');
    loc = boneCoords.Origin;
    loc = loc + ((0 * vect(1,0,0) + (-BombFireOffset * vect(0,1,0)) + (BombZOffset * vect(0,0,1)) >> Rotation));
    spawn(AltFireProjectileClass,,,loc, rotator(vector(rotation)+vrand()*frand()*BombSpread));
    sleep(bombInterval);

    //
    boneCoords = Owner.GetBoneCoords('FrontGunMount');
    loc = boneCoords.Origin;
    loc = loc + ((0 * vect(1,0,0) + (BombFireOffset * vect(0,1,0)) + (BombZOffset * vect(0,0,1)) >> Rotation));
    spawn(AltFireProjectileClass,,,loc,rotator(vector(rotation)+vrand()*frand()*BombSpread));

    boneCoords = Owner.GetBoneCoords('FrontGunMount');
    loc = boneCoords.Origin;
    loc = loc + ((0 * vect(1,0,0) + (-BombFireOffset * vect(0,1,0)) + (BombZOffset * vect(0,0,1)) >> Rotation));
    spawn(AltFireProjectileClass,,,loc, rotator(vector(rotation)+vrand()*frand()*BombSpread));
    sleep(bombInterval);

    //


    GotoState('InstantFireMode');
}

function byte BestMode()
{
    return 0;
}


DefaultProperties
{
    NetPriority=3
    //Mesh=Mesh'ONSBPAnimations.DualAttackCraftGatlingGunMesh'
    //YawBone=GatlingGun
    //PitchBone=GatlingGun
    //WeaponFireAttachmentBone=GatlingGunFirePoint

    //this is an empty mesh
    Mesh=Mesh'ONSWeapons-A.PlasmaGun'
    YawBone=PlasmaGunBarrel
    PitchBone=PlasmaGunBarrel
    WeaponFireAttachmentBone=PlasmaGunBarrel

    AltFireProjectileClass=class'CSBioBomberBioGlob'
    //FireInterval=0.25
    FireInterval=0.35
    BombInterval=0.06
    BombSpread=0.25
    DamageMin=20
    DamageMax=20
    YawStartConstraint=0
    YawEndConstraint=65535
    //PitchUpLimit=0
    //PitchDownLimit=50000

    //FireSoundClass=Sound'WeaponSounds.Misc.instagib_rifleshot'
     FireSoundClass=Sound'CSBomber.BioBeam'

    PitchUpLimit=18000
    PitchDownLimit=49153
    //FireSoundClass=none
    FireSoundVolume=720
    FireForce="Laser01"
    BeamEffectClass(0)=class'CSBioBomberBeamEffect'
    BeamEffectClass(1)=class'CSBioBomberBeamEffectBlue'
    bAimable=True
    bInstantFire=True
    bInstantRotation=True
    DualFireOffset=0
    WeaponFireOffset=40
    ZFireOffset=40
    GunOffset=55
    BombFireOffset=55
    BombZOffset=-70
    TraceRange=20000
    AltFireInterval=4.0
    FireSoundPitch=2.0
    bAmbientFireSound=true
    DamageType=class'CSBioBomberBioBeam'
	CullDistance=+15000.0
}
