class CSMegaSpankerWeapon extends ONSWeapon;


var class<ShockBeamEffect> BeamEffectClass;
var float   AltFireCountdown;
var float   DamageRadius;
var int PawnMomentumTransfer;

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



//override this so we can use electrogun for altfire
simulated function CalcWeaponFire()
{
    local coords WeaponBoneCoords;
    local vector CurrentFireOffset;

    // Calculate fire offset in world space
    WeaponBoneCoords = GetBoneCoords(WeaponFireAttachmentBone);
    if(bIsAltFire)
        WeaponBoneCoords = GetBoneCoords('ElectroGun');

    CurrentFireOffset = (WeaponFireOffset * vect(1,0,0)) + (DualFireOffset * vect(0,1,0));

    // Calculate rotation of the gun
    WeaponFireRotation = rotator(vector(CurrentAim) >> Rotation);

    // Calculate exact fire location
    WeaponFireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> WeaponFireRotation);

    // Adjust fire rotation taking dual offset into account
    if (bDualIndependantTargeting)
        WeaponFireRotation = rotator(CurrentHitLocation - WeaponFireLocation);
}


function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local ShockBeamEffect Beam;

    Beam = Spawn(BeamEffectClass,,, Start, Dir);
    Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.AimAt(HitLocation, HitNormal);

}

function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    local ONSWeaponPawn WeaponPawn;
    local Vehicle VehicleInstigator;
    local int Damage;
    local bool bDoReflect;
    local int ReflectNum;

    MaxRange();

    if ( bDoOffsetTrace )
    {
    	WeaponPawn = ONSWeaponPawn(Owner);
	    if ( WeaponPawn != None && WeaponPawn.VehicleBase != None )
    	{
    		if ( !WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
				Start = HitLocation;
		}
		else
			if ( !Owner.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (Owner.CollisionRadius * 1.5)))
				Start = HitLocation;
    }

    ReflectNum = 0;
    while ( true )
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;

        //skip past vehicle driver
        VehicleInstigator = Vehicle(Instigator);
        if ( ReflectNum == 0 && VehicleInstigator != None && VehicleInstigator.Driver != None )
        {
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = false;
        	Other = Trace(HitLocation, HitNormal, End, Start, true);
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = true;
        }
        else
        	Other = Trace(HitLocation, HitNormal, End, Start, True);


        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = True;
                HitNormal = vect(0,0,0);
            }
            else if (!Other.bWorldGeometry)
            {
                Damage = (DamageMin + Rand(DamageMax - DamageMin));
 				if ( Vehicle(Other) != None || Pawn(Other) == None )
 				{
 					HitCount++;
 					LastHitLocation = HitLocation;
					SpawnHitEffects(Other, HitLocation, HitNormal);
				}
               	//Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
               	Other.TakeDamage(0, Instigator, HitLocation, Momentum*X, DamageType);
				HitNormal = vect(0,0,0);
            }
            else
            {
                HitCount++;
                LastHitLocation = HitLocation;
                SpawnHitEffects(Other, HitLocation, HitNormal);
	    }
        }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
            HitCount++;
            LastHitLocation = HitLocation;
        }

        HurtRadius(DamageMax, DamageRadius, DamageType, Momentum, HitLocation );
        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

        if ( bDoReflect && ++ReflectNum < 4 )
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start	= HitLocation;
            Dir		= Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }

    NetUpdateTime = Level.TimeSeconds - 1;
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
                //Victims.KAddImpulse(Normal(dir)*MomentumTransfer, HitLocation);
                Victims.KAddImpulse(Normal(dir)*Momentum, HitLocation);
            }
		}
	}
    /*
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;
		LastTouched = None;
		dir = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;

        Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
			vect(0,0,0),
			DamageType
		);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, 0, HitLocation);

        dir.Z = Abs(dir.Z);
        if(XPawn(Victims) != None)
        {
            XPawn(Victims).SetPhysics(PHYS_Falling);
            XPawn(Victims).AddVelocity(Normal(dir)*PawnMomentumTransfer);
        }
        else
        {
            //Victims.KAddImpulse(Normal(dir)*MomentumTransfer, HitLocation);
            Victims.KAddImpulse(Normal(dir)*Momentum, HitLocation);
        }
	}
    */

	bHurtEntry = false;
}


state ProjectileFireMode
{
    function Fire(Controller C)
    {
        FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        // Play firing noise
        if (bAmbientFireSound)
            AmbientSound = FireSoundClass;
        else
            PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);

        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }

    function AltFire(Controller C)
    {
        SpawnProjectile(AltFireProjectileClass, True);
    }
}

defaultproperties
{
    NetPriority=3.0
    BeamEffectClass=class'CSMegaSpankerBeamEffect'
    RedSkin=Material'CSSpankBadger.Badger.SpankBadgerWeaponRed'
    BlueSkin=Material'CSSpankBadger.Badger.SpankBadgerWeaponBlue'
    //DrawScale3D=(X=0.35,Y=0.35,Z=0.45)
    DrawScale3D=(X=0.70,Y=0.70,Z=1.25)
    ProjectileClass=class'CSSpankBadger.CSSpankBadgerProjSmall'
    AltFireProjectileClass=class'CSMegaSpanker.CSMegaSpankerProjectile'
    //RotationsPerSecond=1.0
    RotationsPerSecond=0.07000
    FireInterval=0.75
    AltFireInterval=0.75
    Mesh=Mesh'ONSBPAnimations.ShockTankCannonMesh'
    YawBone=8WheelerTop
    PitchBone=TurretAttach
    WeaponFireAttachmentBone=FirePoint
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchUpLimit=18000
    PitchDownLimit=58000
    FireSoundClass=sound'CSSpankBadger.beamfiresound'
    FireSoundRadius=250
    FireSoundPitch=0.82
    AltFireSoundClass=sound'CSSpankBadger.projshoot'
    RotateSound=None
    bAimable=True
    bForceSkelUpdate=True
    EffectEmitterClass=class'CSSpankBadger.CSSpankBadgerMuzzleFlash'
    AIInfo(0)=(bLeadTarget=true,bTrySplash=true,WarnTargetPct=0.75,RefireRate=0.8)
    AIInfo(1)=(bInstantHit=true,RefireRate=0.99)

    DamageType=class'CSSpankBadgerDamTypeProjSmall'
    //DamageMin=55
    //DamageMax=55
    DamageMin=110
    DamageMax=110
    TraceRange=20000
    //Momentum=60000
    //PawnMomentumTransfer=10000    
    Momentum=120000
    PawnMomentumTransfer=20000    
    DamageRadius=280.0
}
