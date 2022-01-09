class CSSpankBomberWeapon extends ONSWeapon;

#exec AUDIO IMPORT FILE=Sounds\smallprojshoot.wav
#exec AUDIO IMPORT FILE=Sounds\projshoot.wav
#exec AUDIO IMPORT FILE=Sounds\beamfiresound.wav

var int GunOffset, BombFireOffset, ZFireOffset;
var class<ShockBeamEffect> BeamEffectClass;
var float   DamageRadius;
var int PawnMomentumTransfer;


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


simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float dist, damageScale;
	local vector dir;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		//if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

			//if ( Instigator == None || Instigator.Controller == None )
			//	Victims.SetDelayedDamageInstigatorController( InstigatorController );

			//if ( Victims == LastTouched )
				//LastTouched = None;

            Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				vect(0,0,0),
				DamageType
			);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				//Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, 0, HitLocation);                
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, 0, HitLocation);                

            dir.Z = Abs(dir.Z);
            if(XPawn(Victims) != None)
            {
                XPawn(Victims).SetPhysics(PHYS_Falling);
                XPawn(Victims).AddVelocity(Normal(dir)*PawnMomentumTransfer);
            }
            else
            {
                Victims.KAddImpulse(Normal(dir)*Momentum, HitLocation);
            }
		}
	}

	bHurtEntry = false;
}



function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
    //local int Damage; //damage is via hurtradius
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
            //Damage = (DamageMin + Rand(DamageMax - DamageMin));
            //Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
            Other.TakeDamage(0, Instigator, HitLocation, Momentum*X, DamageType);
            HitNormal = vect(0,0,0);
        }
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

    HurtRadius(DamageMax, DamageRadius, DamageType, Momentum, HitLocation );
    SpawnBeamEffect(LStart, Dir, HitLocation, HitNormal, 0);

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
            //Damage = (DamageMin + Rand(DamageMax - DamageMin));
            //Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
            Other.TakeDamage(0, Instigator, HitLocation, Momentum*X, DamageType);
            HitNormal = vect(0,0,0);
        }
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

    HurtRadius(DamageMax, DamageRadius, DamageType, Momentum, HitLocation );
    SpawnBeamEffect(RStart, Dir, HitLocation, HitNormal, 0);

    HitCount++;
    //LastHitLocation = HitLocation;
    //LastHitNormal = HitNormal;
    //LastHitActor = Other;

    End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, True);
    DualFireOffset=0;

    NetUpdateTime = Level.TimeSeconds - 1;
    SpawnHitEffects(Other, HitLocation, HitNormal);
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local ShockBeamEffect Beam;

    Beam = Spawn(BeamEffectClass,,, Start, Dir);
    Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.AimAt(HitLocation, HitNormal);

}

state InstantFireMode
{
    function Fire(Controller C)
    {
        FlashMuzzleFlash();
        PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);
        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }

    function AltFire(Controller C)
    {
        local coords boneCoords;
        local vector loc;

        boneCoords = CSSpankBomber(Owner).GetBoneCoords('FrontGunMount');
        loc = boneCoords.Origin;
        loc = loc + ((-50 * vect(1,0,0) + (-80 * vect(0,0,1))) >> Rotation);
        spawn(AltFireProjectileClass,,,loc,rotator(vector(rotation)+vrand()*frand()));
        //PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);

    }
}

function byte BestMode()
{
    return 0;
}

defaultproperties
{
    Mesh=Mesh'ONSWeapons-A.PlasmaGun'
    YawBone=PlasmaGunBarrel
    PitchBone=PlasmaGunBarrel
    WeaponFireAttachmentBone=PlasmaGunBarrel
    ZFireOffset=40
    GunOffset=55
    BombFireOffset=55
    //FireInterval=0.5
    FireInterval=0.75
    //AltFireInterval=1.5
    AltFireInterval=1.0
    PitchUpLimit=18000
    PitchDownLimit=49153
    //ProjectileClass=class'CSSpankBomberProjectile'
    FireSoundClass=sound'CSBomber.beamfiresound'
    AltFireSoundClass=sound'CSBomber.projshoot'

    AltFireProjectileClass=class'CSSpankBomberBomb'
    YawStartConstraint=0
    YawEndConstraint=65535
    bInstantRotation=True
    bInstantFire=True

    BeamEffectClass=class'CSSpankBomberBeamEffect'
    DamageType=class'CSSpankBomberDamTypeProjectile'
    //DamageMin=55
    //DamageMax=55
    DamageMin=45
    DamageMax=45
    DamageRadius=280
    TraceRange=20000
    Momentum=60000    
    PawnMomentumTransfer=10000    
}