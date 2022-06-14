
class CSPlasmaFighterWeapon extends ONSWeapon;

#exec AUDIO IMPORT FILE=Sounds\RailGunTankFire.wav

var int GunOffset, BombFireOffset, ZFireOffset;
var float primaryInterval, secondaryInterval,MaxLockRange, LockAim;
var Controller CurrentController;

var class<Projectile> TeamProj[2];

/*************/
var float OuterTraceOffset;
var float TraceThickness;
var class<ShockBeamEffect> BeamEffectClass[2];
/*************/

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
        //CurrentController=C;
        //GotoState('SecondaryVolley');
        FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        // Play firing noise
        if (bAmbientFireSound)
            AmbientSound = AltFireSoundClass;
        else
            PlayOwnedSound(AltFireSoundClass, SLOT_None, AltFireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);

        DualFireOffset=0;
        TraceFire(WeaponFireLocation, WeaponFireRotation);

    }

    simulated event ClientSpawnHitEffects()
    {
    	local vector HitLocation, HitNormal, Offset;
    	local actor HitActor;

    	// if standalone, already have valid HitActor and HitNormal
    	if ( Level.NetMode == NM_Standalone )
    		return;
    	Offset = 20 * Normal(WeaponFireLocation - LastHitLocation);
    	HitActor = Trace(HitLocation, HitNormal, LastHitLocation - Offset, LastHitLocation + Offset, False);
    	SpawnHitEffects(HitActor, LastHitLocation, HitNormal);
    }

    simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
    {
		local PlayerController PC;

		PC = Level.GetLocalPlayerController();
		if (PC != None && ((Instigator != None && Instigator.Controller == PC) || VSize(PC.ViewTarget.Location - HitLocation) < 5000))
		{
			Spawn(class'HitEffect'.static.GetHitEffect(HitActor, HitLocation, HitNormal),,, HitLocation, Rotator(HitNormal));
			if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) )
			{
				// check for splash
				if ( Base != None )
				{
					Base.bTraceWater = true;
					HitActor = Base.Trace(HitLocation,HitNormal,HitLocation,Location + 200 * Normal(HitLocation - Location),true);
					Base.bTraceWater = false;
				}
				else
				{
					bTraceWater = true;
					HitActor = Trace(HitLocation,HitNormal,HitLocation,Location + 200 * Normal(HitLocation - Location),true);
					bTraceWater = false;
				}

				if ( (FluidSurfaceInfo(HitActor) != None) || ((PhysicsVolume(HitActor) != None) && PhysicsVolume(HitActor).bWaterVolume) )
					Spawn(class'BulletSplash',,,HitLocation,rot(16384,0,0));
			}
		}
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
            if(VSize(Location - B.Enemy.Location) > 4000)
                return 1;
            else
                return 0;
        }
    }

    return 0;
}

/***************************************/

function TraceFire(Vector Start, Rotator Dir)
{
	local vector X, Y, Z, HitLocation, HitNormal, ImpactNormal, RefNormal;
	local vector TraceStart, TraceEnd;
	local float Dist, TraceDist;
	local Actor Other;
	local ONSWeaponPawn WeaponPawn;
	local int i, j;

	MaxRange();

	if (bDoOffsetTrace) {
		WeaponPawn = ONSWeaponPawn(Owner);
		if (WeaponPawn != None && WeaponPawn.VehicleBase != None) {
			if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
				Start = HitLocation;
		}
		else if (!Owner.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (Owner.CollisionRadius * 1.5)))
			Start = HitLocation;
	}

	GetAxes(Dir + rot(0,0,1000), X, Y, Z);

	for (i = -1; i <= 1 && TraceDist < TraceRange; ++i) {
		for (j = -1; j <= 1; j++) {
			if (Abs(i) + Abs(j) >= 1) {
				TraceStart = Start + OuterTraceOffset * (i * Y + j * Z);
				TraceEnd = TraceStart + TraceRange * X;
				Other = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, false);
				if (Other == None) {
					TraceDist = TraceRange;
					ImpactNormal = vect(0,0,0);
					break;
				}
				Dist = VSize(HitLocation - TraceStart);
				if (Dist > TraceDist) {
					TraceDist = Dist;
					ImpactNormal = HitNormal;
				}
			}
		}
	}

	TraceStart = Start;
	TraceEnd = Start + TraceDist * X;
	LastHitLocation = TraceEnd;
	foreach TraceActors(class'Actor', Other, HitLocation, HitNormal, TraceEnd, TraceStart, vect(1,1,1) * TraceThickness) {
		if (Other == Level || TerrainInfo(Other) != None)
			break; // try to trace further with reduced extent
		if (Other != Self && Other != Instigator && (Other.bWorldGeometry || Other.bProjTarget || Other.bBlockActors)) {
			SpawnHitEffects(Other, HitLocation, HitNormal);
			if (Other.bWorldGeometry) {
				LastHitLocation = HitLocation;
				ImpactNormal = HitNormal;
				HitCount++;
			}
			if (Pawn(Other) != None && Pawn(Other).Weapon != None && Pawn(Other).Weapon.CheckReflect(HitLocation, RefNormal, (DamageMin + DamageMax) / 3)) {
				// successfully blocked by shieldgun, apply reduced damage but increased momentum
				Other.TakeDamage(RandRange(DamageMin, DamageMax) / 3, Instigator, HitLocation, 2 * Momentum * X, DamageType);
				Other = None;
				LastHitLocation = HitLocation;
				ImpactNormal = HitNormal;
				HitCount++;
				break;
			}
			else {
				Other.TakeDamage(RandRange(DamageMin, DamageMax), Instigator, HitLocation, Momentum * X, DamageType);
			}
		}
	}
	if (Other != None) { // continue with zero-width trace after hitting BSP or terrain
		TraceDist = VSize(TraceStart - HitLocation);
		TraceStart += X * TraceDist;
		foreach TraceActors(class'Actor', Other, HitLocation, HitNormal, TraceEnd, TraceStart) {
			if (Other != Self && Other != Instigator && (Other.bWorldGeometry || Other.bProjTarget || Other.bBlockActors)) {
				SpawnHitEffects(Other, HitLocation, HitNormal);
				if (Other.bWorldGeometry) {
					LastHitLocation = HitLocation;
					ImpactNormal = HitNormal;
					HitCount++;
				}
				if (Pawn(Other) != None && Pawn(Other).Weapon != None && Pawn(Other).Weapon.CheckReflect(HitLocation, RefNormal, (DamageMin + DamageMax) / 3)) {
					// successfully blocked by shieldgun, apply reduced damage but increased momentum
					Other.TakeDamage(RandRange(DamageMin, DamageMax) / 3, Instigator, HitLocation, 2 * Momentum * X, DamageType);
					LastHitLocation = HitLocation;
					ImpactNormal = HitNormal;
					HitCount++;
					break;
				}
				else {
					Other.TakeDamage(RandRange(DamageMin, DamageMax), Instigator, HitLocation, Momentum * X, DamageType);
				}
			}
		}
	}
	SpawnBeamEffect(Start, Dir, LastHitLocation, ImpactNormal, 0);

	NetUpdateTime = Level.TimeSeconds - 1;
}


function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
	local ShockBeamEffect Beam;

	Beam = Spawn(BeamEffectClass[Instigator.GetTeamNum() % ArrayCount(BeamEffectClass)],,, Start, Dir);
	Beam.Instigator = None; // prevents client side repositioning of beam start
	Beam.AimAt(HitLocation, HitNormal);
}


simulated event FlashMuzzleFlash()
{
	Super.FlashMuzzleFlash();

	if (Level.NetMode != NM_DedicatedServer) {
		PlayAnim('Fire', 0.5, 0);
		ShakeView();
	}
}

function bool CanAttack(Actor Other)
{
	local vector X, Y, Z, Dir;
	local float UpperLimit, LowerLimit;
	const RAD_TO_UROT = 10430.37835;
	local float Dist;
	local vector HitLocation, HitNormal, projStart;
	local Actor HitActor;

	if (Instigator == None || Instigator.Controller == None || Other == None)
		return false;

	// check pitch limits
	GetAxes(Instigator.Rotation, X, Y, Z);
	Dir = Normal(Other.Location - Instigator.Location);

	UpperLimit = float(PitchUpLimit) / RAD_TO_UROT;
	if (UpperLimit > PI)
		UpperLimit -= 2 * PI;
	LowerLimit = float(PitchDownLimit) / RAD_TO_UROT;
	if (LowerLimit > PI)
		LowerLimit -= 2 * PI;

	if (Dir dot Z > Sin(FClamp(UpperLimit, -PI, PI)) || Dir dot Z < Sin(FClamp(LowerLimit, -PI, PI)))
		return false;

	// check that target is within range
	Dist = VSize(Instigator.Location - Other.Location);
	if (Dist > MaxRange())
		return false;

	// check that can see target
	if (!Instigator.Controller.LineOfSightTo(Other))
		return false;

	// check that would hit target, and not a friendly
	CalcWeaponFire();
	projStart = WeaponFireLocation;
	HitActor = Trace(HitLocation, HitNormal, Other.Location + Other.CollisionHeight * vect(0,0,0.8), projStart, true);

	if (HitActor == None || HitActor == Other || Pawn(HitActor) == None || Pawn(HitActor).Controller == None || !Instigator.Controller.SameTeamAs(Pawn(HitActor).Controller))
		return true;

	return false;
}

/***************************************/

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

    AltFireInterval=2.5
    SecondaryInterval=0.2
    PitchUpLimit=18000
    PitchDownLimit=49153
    ProjectileClass=class'CSPlasmaFighterPrimaryProjectile'
    FireSoundClass=sound'ONSVehicleSounds-S.LaserSounds.Laser01'
    FireSoundVolume=80

    TeamProj(0)=class'CSPlasmaFighterPrimaryProjectile'
    TeamProj(1)=class'CSPlasmaFighterPrimaryProjectileBlue'
    AltFireProjectileClass=class'CSPlasmaFighterSecondaryProjectile'
    AltFireSoundClass=Sound'CSBomber.RailGunTankFire'
    AltFireSoundVolume=128

    bInstantRotation=True

    OuterTraceOffset=15.000000
    TraceThickness=30.000000
    BeamEffectClass(0)=Class'CSPlasmaFighterBeamEffectRed'
    BeamEffectClass(1)=Class'CSPlasmaFighterBeamEffect'
     EffectEmitterClass=None
    DamageType=Class'CSPlasmaFighterDamTypeRailTurret'
    DamageMin=350
    DamageMax=350
    TraceRange=20000.000000
    Momentum=50000.000000
    AIInfo(0)=(bTrySplash=False,bLeadTarget=False,bInstantHit=True,WarnTargetPct=1.000000,RefireRate=0.850000)
}