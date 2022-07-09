class CSDarkLeviRailTurret extends ONSWeapon;

#exec audio import file=Sounds\RailgunTankFire.wav group=RailgunTank


var float OuterTraceOffset;
var float TraceThickness;
var class<ShockBeamEffect> BeamEffectClass[2];


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


simulated function float ChargeBar()
{
	return FMin(1 - FireCountdown / FireInterval, 0.999);
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


static function StaticPrecache(LevelInfo L)
{
	Super.StaticPrecache(L);
	StaticPrecacheStaticMeshes(L);
	StaticPrecacheMaterials(L);
}
simulated function UpdatePrecacheStaticMeshes()
{
	Super.UpdatePrecacheStaticMeshes();
	StaticPrecacheStaticMeshes(Level);
}
simulated function UpdatePrecacheMaterials()
{
	Super.UpdatePrecacheMaterials();
	StaticPrecacheMaterials(Level);
}


static function StaticPrecacheStaticMeshes(LevelInfo L)
{
	// FX
	L.AddPrecacheStaticMesh(default.BeamEffectClass[0].default.CoilClass.default.mMeshNodes[0]);
}

static function StaticPrecacheMaterials(LevelInfo L)
{
	L.AddPrecacheMaterial(default.RedSkin);
	L.AddPrecacheMaterial(default.BlueSkin);

	// FX
	L.AddPrecacheMaterial(default.BeamEffectClass[0].default.Skins[0]);
	L.AddPrecacheMaterial(default.BeamEffectClass[1].default.Skins[0]);
	L.AddPrecacheMaterial(default.BeamEffectClass[0].default.CoilClass.default.Texture);
	L.AddPrecacheMaterial(default.BeamEffectClass[1].default.CoilClass.default.Texture);
}


DefaultProperties
{
    //Mesh=Mesh'ONSFullAnimations.MASPassengerGun'
    //YawBone=Object83
    //YawStartConstraint=0
    //YawEndConstraint=65535
    //PitchBone=Object83
    //PitchUpLimit=15000
    //PitchDownLimit=60000
    //bInstantFire=False
    //FireInterval=0.15
    //AltFireInterval=0.15
    //bAmbientFireSound=False
    //WeaponFireAttachmentBone=Object85
    //GunnerAttachmentBone=Object83
    //WeaponFireOffset=20.0
    //bAimable=True
    //DamageType=class'DamTypePRVLaser'
    //DamageMin=25
    //DamageMax=25
    //DualFireOffset=10
    //FireSoundClass=sound'ONSVehicleSounds-S.LaserSounds.Laser17'
    //AltFireSoundClass=sound'ONSVehicleSounds-S.LaserSounds.Laser17'
    FireForce="Laser01"
    AltFireForce="Laser01"
    ProjectileClass=class'OnslaughtFull.ONSMASPlasmaProjectile'
    bDoOffsetTrace=True

    FireInterval=2.5

    ShakeRotMag=(Z=250)
    ShakeRotRate=(Z=2500)
    ShakeRotTime=6
    ShakeOffsetMag=(Z=10)
    ShakeOffsetRate=(Z=200)
    ShakeOffsetTime=10
    WeaponFireAttachmentBone=TankBarrel
    WeaponFireOffset=200.0
    bAimable=True

    OuterTraceOffset=15.000000
    TraceThickness=30.000000
    BeamEffectClass(0)=Class'CSDarkLeviRailBeamEffectRed'
    BeamEffectClass(1)=Class'CSDarkLeviRailBeamEffect'
    RotationsPerSecond=0.250000
    bInstantFire=True
    Spread=0.005000
    //RedSkin=Texture'ONS-Dria-TankMeUp-V6.RailgunTankTurret0'
    //BlueSkin=Texture'ONS-Dria-TankMeUp-V6.RailgunTankTurret1'
    EffectEmitterClass=None
    FireSoundClass=Sound'CSDarkLeviathan.RailgunTankFire'
    DamageType=Class'DamTypeRailTurret'
    DamageMin=350
    DamageMax=350
    TraceRange=20000.000000
    Momentum=50000.000000
    AIInfo(0)=(bTrySplash=False,bLeadTarget=False,bInstantHit=True,WarnTargetPct=1.000000,RefireRate=0.850000)
    DrawScale=0.5
    Mesh=SkeletalMesh'AS_VehiclesFull_M.IonTankTurretSimple'
    YawBone=TankTurret
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchBone=TankBarrel
    PitchUpLimit=6000
    PitchDownLimit=61500

    SoundRadius=512.000000
}