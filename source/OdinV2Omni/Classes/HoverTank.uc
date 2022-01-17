/******************************************************************************
HoverTank

Creation date: 2011-08-03 18:12
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class HoverTank extends ONSHoverCraft abstract;


//=============================================================================
// Imports
//=============================================================================

#exec audio import file=Sounds\HoverEngine.wav group=HovertankSounds
#exec audio import file=Sounds\HoverStart.wav group=HovertankSounds
#exec audio import file=Sounds\HoverStop.wav group=HovertankSounds


//=============================================================================
// Properties
//=============================================================================

var() const editconst string Build;

var() array<vector> HoverDustOffset;
var() float HoverDustTraceDistance;
var() byte EnginePitchRange;

var() float CrouchedHoverPenScale, RaisedHoverCheckDist;
var() class<HoverTankDustEmitter> DustEmitterClass;

var() float MinVehicleDistance;
var() float ResetDelay;

var float MaxGroundSpeed, MaxAirSpeed;
var array<name> HiddenBones, ThrusterBones;
var float StartupSoundAlpha, SmoothSoundPitch;

var class<TurretSocket> TurretSocketClass;

var float DrivenBuoyancy, UndrivenBuoyancy;


//=============================================================================
// Variables
//=============================================================================

var TurretSocket Socket;
var array<HoverTankDustEmitter> HoverDust;
var array<vector> HoverDustLastNormal;

var bool bWasInWater, bOnGround;
var float AccumulatedWaterDamage;
var bool bTurnedOff;


simulated function UpdatePrecacheMaterials()
{
	Super.UpdatePrecacheMaterials();

	Level.AddPrecacheMaterial(Texture'AW-2004Particles.Weapons.SmokePanels2');
	Level.AddPrecacheMaterial(Texture'AW-2004Particles.Energy.AirBlast');
}

static function StaticPrecache(LevelInfo L)
{
	Super.StaticPrecache(L);

	if (default.TurretSocketClass != None)
		L.AddPrecacheStaticMesh(default.TurretSocketClass.default.StaticMesh);

	L.AddPrecacheMaterial(Texture'AW-2004Particles.Weapons.SmokePanels2');
	L.AddPrecacheMaterial(Texture'AW-2004Particles.Energy.AirBlast');
}


simulated function PostBeginPlay()
{
	local int i, ChannelIndex;

	if (Role == ROLE_Authority && PassengerWeapons.Length > 0)
	{
		// endsure dummy controller exists (must not be spawned during UpdateVehicle!)
		class'DummyController'.static.GetDummy(Level);
	}

	for (i = 0; i < HiddenBones.Length; ++i)
	{
		SetBoneScale(ChannelIndex++, 0.0, HiddenBones[i]);
	}

	for (i = 0; i < ThrusterBones.Length; ++i)
	{
		SetBoneRotation(ThrusterBones[i], rot(0,-8900,16384));
	}

	for (i = 0; i < ThrusterOffsets.Length; i++)
	{
		ThrusterOffsets[i] *= DrawScale3D * DrawScale;
	}
	for (i = 0; i < ExitPositions.Length; i++)
	{
		ExitPositions[i] *= DrawScale3D * DrawScale;
	}
	DamagedEffectOffset *= DrawScale3D * DrawScale;
	DamagedEffectScale *= DrawScale;

	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (Level.NetMode != NM_DedicatedServer && !bDestroyAppearance && TurretSocketClass != None)
	{
		Socket = Spawn(TurretSocketClass);
		AttachToBone(Socket, DriverWeapons[0].WeaponBone);
		Socket.SetTeam(Team);
	}
}

function bool ImportantVehicle()
{
	return true;
}

simulated function DestroyAppearance()
{
	local int i;

	if (Level.NetMode != NM_DedicatedServer) {
		for (i = 0; i < HoverDust.Length; i++) {
			HoverDust[i].Destroy();
		}
		HoverDust.Length = 0;
	}

	if (Socket != None)
	{
		Socket.Destroy();
	}
	Socket = None;

	Super.DestroyAppearance();
}

simulated function Destroyed()
{
	local int i;

	if (Level.NetMode != NM_DedicatedServer) {
		for (i = 0; i < HoverDust.Length; i++) {
			HoverDust[i].Destroy();
		}
		HoverDust.Length = 0;
	}

	if (Socket != None)
	{
		Socket.Destroy();
	}
	Socket = None;

	Super.Destroyed();
}

simulated event TeamChanged()
{
	Super.TeamChanged();

	if (Socket != None)
	{
		Socket.SetTeam(Team);
	}
}

/*
simulated function SetOverlayMaterial(Material mat, float time, bool bOverride)
{
	Super.SetOverlayMaterial(mat, time, bOverride);

	if (Socket != None)
	{
		Socket.SetOverlayMaterial(mat, time, bOverride);
	}
}
*/

simulated event DrivingStatusChanged()
{
	local int i;

	Super.DrivingStatusChanged();

	StartupSoundAlpha = 0;

	if (bDriving)
		KarmaParams(KParams).KBuoyancy = DrivenBuoyancy;
	else
		KarmaParams(KParams).KBuoyancy = UndrivenBuoyancy;

	if (bDriving && Level.NetMode != NM_DedicatedServer && HoverDust.Length == 0) {
		HoverDust.Length = HoverDustOffset.Length;
		HoverDustLastNormal.Length = HoverDustOffset.Length;

		for (i = 0; i < HoverDust.Length; i++) {
			if (HoverDust[i] == None) {
				HoverDust[i] = Spawn(DustEmitterClass, self,, Location + (DrawScale * (DrawScale3D * HoverDustOffset[i]) >> Rotation));
				HoverDust[i].SetDrawScale(DrawScale);
				HoverDust[i].SetDrawScale3D(DrawSCale3D);
				HoverDust[i].SetDustColor(Level.DustColor);
				HoverDustLastNormal[i] = vect(0,0,1);
			}
		}
	}
	else if (!bDriving && Level.NetMode != NM_DedicatedServer) {
		for(i = 0; i < HoverDust.Length; i++) {
			HoverDust[i].Destroy();
		}
		HoverDust.Length = 0;
	}

	if (!bDriving && bWasInWater) {
		// without the repulsors, this is taken care of by buoyancy
		KSetStayUprightParams(UprightStiffness, UprightDamping);
		bWasInWater = False;
	}
}

function UpdateVehicle(float DeltaTime)
{
	if (Controller == None && !IsVehicleEmpty() && !Level.Game.bGameEnded)
	{
		// set a controller just for the native UpdateVehicle call to enable damping etc.
		Controller = class'DummyController'.static.GetDummy(Level);
		OutputThrust = 0;
		OutputStrafe = 0;
		Super.UpdateVehicle(DeltaTime);
		Controller = None;
	}
	else
	{
		Super.UpdateVehicle(DeltaTime);
	}
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	bHeadingInitialized = False;

	Super.ClientKDriverEnter(PC);
}

function KDriverEnter(Pawn P)
{
	local Sound ActualStartupSound;

	bHeadingInitialized = False;

	ActualStartupSound = StartupSound;
	StartupSound = None;
	Super.KDriverEnter(P);

	StartupSound = ActualStartupSound;
	if (StartupSound != None)
		PlaySound(StartupSound, SLOT_None, 1.0, False, SoundRadius, default.SoundPitch / 64.0);
}

function Vehicle FindEntryVehicle(Pawn P)
{
	local Vehicle EntryVehicle;

	EntryVehicle = Super.FindEntryVehicle(P);
	if (EntryVehicle == None && Driver != None)
	{
		// If a player is trying to drive and we're full of bots, kick out the bot driver so the player can drive
		if (PlayerController(P.Controller) != None && Bot(Controller) != None && Controller.SameTeamAs(P.Controller)) {
			KDriverLeave(true);
			return self;
		}
	}
	else return EntryVehicle;
}

function DriverLeft()
{
	if (ActiveWeapon < Weapons.Length)
	{
		Weapons[ActiveWeapon].bActive = False;
		Weapons[ActiveWeapon].AmbientSound = None;
	}

	if (AmbientSound != None)
		AmbientSound = None;

	if (ShutDownSound != None)
		PlaySound(ShutDownSound, SLOT_None, 1.0, False, SoundRadius, default.SoundPitch / 64.0);

	if (!bNeverReset && ParentFactory != None && (VSize(Location - ParentFactory.Location) > 5000.0 || !FastTrace(ParentFactory.Location, Location)))
	{
		if (bKeyVehicle)
			ResetTime = Level.TimeSeconds + ResetDelay / 2;
		else
			ResetTime = Level.TimeSeconds + ResetDelay;
	}

	Super(SVehicle).DriverLeft();
}


simulated function TurnOff()
{
	local int i;

	bTurnedOff = True;

	for (i = 0; i < Weapons.Length; i++)
	{
		if (HoverTankWeapon(Weapons[i]) != None)
			HoverTankWeapon(Weapons[i]).bturnedOff = True;
	}

	Super.TurnOff();
}


simulated function Tick(float DeltaTime)
{
	//local KRigidBodyState BodyState;
	local KarmaParams KP;
	local bool bOnWater;
	local int i;
	local float EnginePitch, EffectiveRise;
	local vector X, Y, Z, TraceStart, TraceEnd, HitLocation, HitNormal;
	local Actor HitActor;
	local Material HitMaterial;
	local rotator DustRotation;

	if (bTurnedOff)
		return;

	if (bDriving && Driver == None)
		KWake(); // keep awake as long as the gunner seat is occupied

	KP = KarmaParams(KParams);
	GetAxes(Rotation, X, Y, Z);

	// hack to allow tank to get out of water again after unfortunate landing
	if (bWasInWater && !PhysicsVolume.bWaterVolume) {
		KSetStayUprightParams(UprightStiffness, UprightDamping);
	}
	else if (!bWasInWater && PhysicsVolume.bWaterVolume) {
		KSetStayUprightParams(20 * UprightStiffness, 0.05 * UprightDamping);
	}
	bWasInWater = PhysicsVolume.bWaterVolume;

	// Increase max karma speed if falling
	bOnGround = false;
	for (i = 0; i < KP.Repulsors.Length; i++) {
		if (KP.Repulsors[i] != None) {
			if (KP.Repulsors[i].bRepulsorInContact) {
				bOnGround = true;
			}
			KP.Repulsors[i].CheckDir = -Z;
			KP.Repulsors[i].CheckDist = Lerp(FClamp(Rise, 0.0, 1.0), HoverCheckDist, RaisedHoverCheckDist);
			KP.Repulsors[i].PenScale  = Lerp(FClamp(Rise + float(Driver != None), 0.0, 1.0), CrouchedHoverPenScale, HoverPenScale);
		}
	}
	EffectiveRise = Rise;
	if (HoverCheckDist == RaisedHoverCheckDist && EffectiveRise > 0)
	{
		EffectiveRise = 0;
	}
	if (CrouchedHoverPenScale == HoverPenScale && EffectiveRise < 0)
	{
		EffectiveRise = 0;
	}
	MaxThrustForce = default.MaxThrustForce * (1.0 - 0.3 * Abs(EffectiveRise));
	MaxStrafeForce = default.MaxStrafeForce * (1.0 - 0.3 * Abs(EffectiveRise));

	if (bOnGround)
	{
		KP.kMaxSpeed = MaxGroundSpeed;
	}
	else
	{
		KP.kMaxSpeed = MaxAirSpeed;
		MaxThrustForce *= AirControl;
		MaxStrafeForce *= AirControl;
	}

	if (Level.NetMode != NM_DedicatedServer) {
		if (StartupSoundAlpha < 1.0) {
			StartupSoundAlpha = FMin(StartupSoundAlpha + 2 * DeltaTime, 1.0);
			SoundVolume = StartupSoundAlpha * default.SoundVolume;
		}
		EnginePitch = (default.SoundPitch + FMax(MaxThrustForce * Abs(OutputThrust), MaxStrafeForce * Abs(OutputStrafe)) * EnginePitchRange / FMax(MaxThrustForce, MaxStrafeForce)) * (1.0 + 0.2 * EffectiveRise);
		SmoothSoundPitch = StartupSoundAlpha * FClamp(0.9 * SmoothSoundPitch + 0.1 * EnginePitch, default.SoundPitch * 0.8, (default.SoundPitch + EnginePitchRange) * 1.2);
		SoundPitch = Round(SmoothSoundPitch);
	}

	for (i = 0; i < HoverDust.Length; i++) {

		TraceStart = Location + (HoverDustOffset[i] >> Rotation);
		TraceEnd = TraceStart - Z * HoverDustTraceDistance;

		HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true,, HitMaterial);

		if (HitActor == None) {
			HoverDust[i].bDustActive = false;
			HoverDust[i].UpdateHoverDust(false, 0);
		}
		else {
			bOnWater = False;
			if (PhysicsVolume(HitActor) != None && PhysicsVolume(HitActor).bWaterVolume)
				bOnWater = True;
			else if (HitMaterial != None)
				bOnWater = HitMaterial.SurfaceType == EST_Water;
			else
				bOnWater = HitActor.SurfaceType == EST_Water;

			if (bOnWater)
				HoverDust[i].SetDustColor(Level.WaterDustColor);
			else
				HoverDust[i].SetDustColor(Level.DustColor);
			HoverDust[i].SetLocation(HitLocation + 10 * HitNormal);

			HoverDustLastNormal[i] = Normal(3 * HoverDustLastNormal[i] + HitNormal);
			Y = Normal(HitLocation - Location);
			X = Normal(HoverDustLastNormal[i] Cross Y);
			Y = X Cross HoverDustLastNormal[i]; // should be normalized already
			DustRotation = OrthoRotation(HoverDustLastNormal[i], Y, X);
			HoverDust[i].SetRotation(DustRotation);

			HoverDust[i].UpdateHoverDust(true, VSize(HitLocation - TraceStart) / HoverDustTraceDistance);

			// If dust is just turning on, set OldLocation to current Location to avoid spawn interpolation.
			if (!HoverDust[i].bDustActive)
				HoverDust[i].OldLocation = HoverDust[i].Location;

			HoverDust[i].bDustActive = true;
		}
	}

	Super.Tick(DeltaTime);
}
/*
function bool RecommendLongRangedAttack()
{
	return xPawn(Controller.Target) == None && ONSPowerNode(Controller.Target) == None;
}

function bool TooCloseToAttack(Actor Other)
{
	local float dist;

	dist = VSize(Other.Location - Location);
	if (ONSPowerNode(Other) != None) {
		if (dist < 500)
			return true;
	}
	else if (xPawn(Other) != None) {
		if (dist > 200 && dist < 400)
			return true;
		return false;
	}
	return super.TooCloseToAttack(Other);
}
*/
function ChooseFireAt(Actor A)
{
	Super.ChooseFireAt(A);

	if (UnrealPawn(A) != None && VSize(A.Location - Location) < 200 && Normal(Velocity) dot Normal(A.Location - Location) > 0.5) {
		Rise = -1;
		SetTimer(1.0, true);
	}
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	if (Rise > 0.5)
		Rise = -1;
	else
		Rise = 1;
	SetTimer(1.0, false);
	return true;
}

function Timer()
{
	Rise = 0;
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.80;

	Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

event TakeWaterDamage(float DeltaTime)
{
	local vector HitLocation,HitNormal;
	local actor EntryActor;

	AccumulatedWaterDamage += WaterDamage * DeltaTime;

	if (AccumulatedWaterDamage >= 1)
	{
		TakeDamage(int(AccumulatedWaterDamage), Self, vect(0,0,0), vect(0,0,0), VehicleDrowningDamType);
		AccumulatedWaterDamage -= int(AccumulatedWaterDamage);
	}

	if (Level.TimeSeconds - SplashTime > 0.3 && PhysicsVolume.PawnEntryActor != None && !Level.bDropDetail && Level.DetailMode != DM_Low && EffectIsRelevant(Location, false) && VSize(Velocity) > 300)
	{
		SplashTime = Level.TimeSeconds;
		if (!PhysicsVolume.TraceThisActor(HitLocation, HitNormal, Location - CollisionHeight * vect(0,0,1), Location + CollisionHeight * vect(0,0,1)))
		{
			EntryActor = Spawn(PhysicsVolume.PawnEntryActor, self,, HitLocation, rot(16384,0,0));
		}
	}
}

function bool TooCloseToAttack(Actor Other)
{
	if (UnrealPawn(Other) != None)
		return false; // can go for the roadkill

	if (Vehicle(Other) != None && VSize(Other.Location - Location) - Other.CollisionRadius - CollisionRadius < MinVehicleDistance)
		return true;
	return super.TooCloseToAttack(Other);
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Build="2013-05-09 16:45"
     HoverDustOffset(0)=(X=160.000000,Y=-112.000000,Z=10.000000)
     HoverDustOffset(1)=(X=80.000000,Y=-112.000000,Z=10.000000)
     HoverDustOffset(2)=(X=-5.000000,Y=-112.000000,Z=10.000000)
     HoverDustOffset(3)=(X=-80.000000,Y=-112.000000,Z=10.000000)
     HoverDustOffset(4)=(X=-150.000000,Y=-112.000000,Z=10.000000)
     HoverDustOffset(5)=(X=160.000000,Y=112.000000,Z=10.000000)
     HoverDustOffset(6)=(X=80.000000,Y=112.000000,Z=10.000000)
     HoverDustOffset(7)=(X=-5.000000,Y=112.000000,Z=10.000000)
     HoverDustOffset(8)=(X=-80.000000,Y=112.000000,Z=10.000000)
     HoverDustOffset(9)=(X=-150.000000,Y=112.000000,Z=10.000000)
     HoverDustTraceDistance=200.000000
     EnginePitchRange=28
     CrouchedHoverPenScale=1.000000
     RaisedHoverCheckDist=200.000000
     DustEmitterClass=Class'WVHoverTankV2.HoverTankDustEmitter'
     MinVehicleDistance=100.000000
     MaxGroundSpeed=800.000000
     MaxAirSpeed=3000.000000
     HiddenBones(0)="TreadR"
     HiddenBones(1)="TreadR01"
     ThrusterBones(0)="RollerR1"
     ThrusterBones(1)="RollerR2"
     ThrusterBones(2)="RollerR3"
     ThrusterBones(3)="RollerR4"
     ThrusterBones(4)="RollerR5"
     ThrusterBones(5)="RollerL1"
     ThrusterBones(6)="RollerL2"
     ThrusterBones(7)="RollerL3"
     ThrusterBones(8)="RollerL4"
     ThrusterBones(9)="RolleL5"
     DrivenBuoyancy=2.500000
     UndrivenBuoyancy=1.100000
     ThrusterOffsets(0)=(X=192.000000,Y=128.000000,Z=30.000000)
     ThrusterOffsets(1)=(X=192.000000,Z=30.000000)
     ThrusterOffsets(2)=(X=192.000000,Y=-128.000000,Z=30.000000)
     ThrusterOffsets(3)=(X=64.000000,Y=128.000000,Z=30.000000)
     ThrusterOffsets(4)=(X=64.000000,Z=30.000000)
     ThrusterOffsets(5)=(X=64.000000,Y=-128.000000,Z=30.000000)
     ThrusterOffsets(6)=(X=-64.000000,Y=128.000000,Z=30.000000)
     ThrusterOffsets(7)=(X=-64.000000,Z=30.000000)
     ThrusterOffsets(8)=(X=-64.000000,Y=-128.000000,Z=30.000000)
     ThrusterOffsets(9)=(X=-192.000000,Y=128.000000,Z=30.000000)
     ThrusterOffsets(10)=(X=-192.000000,Z=30.000000)
     ThrusterOffsets(11)=(X=-192.000000,Y=-128.000000,Z=30.000000)
     HoverSoftness=0.500000
     HoverPenScale=2.500000
     HoverCheckDist=150.000000
     UprightStiffness=500.000000
     UprightDamping=300.000000
     MaxThrustForce=200.000000
     LongDamping=0.300000
     MaxStrafeForce=150.000000
     LatDamping=0.500000
     TurnTorqueFactor=2000.000000
     TurnTorqueMax=500.000000
     TurnDamping=250.000000
     MaxYawRate=1.500000
     PitchTorqueFactor=200.000000
     PitchTorqueMax=9.000000
     PitchDamping=20.000000
     RollTorqueTurnFactor=450.000000
     RollTorqueStrafeFactor=50.000000
     RollTorqueMax=12.500000
     RollDamping=30.000000
     RedSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalRED'
     BlueSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalBLUE'
     IdleSound=Sound'WVHoverTankV2.HovertankSounds.HoverEngine'
     StartUpSound=Sound'WVHoverTankV2.HovertankSounds.HoverStart'
     ShutDownSound=Sound'WVHoverTankV2.HovertankSounds.HoverStop'
     StartUpForce="TankStartUp"
     ShutDownForce="TankShutDown"
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.TankDead'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathHoverTank'
     DisintegrationHealth=0.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     DamagedEffectScale=1.500000
     DamagedEffectOffset=(X=100.000000,Y=20.000000,Z=26.000000)
     ImpactDamageMult=0.000100
     VehicleMass=12.000000
     bTurnInPlace=True
     bDrawMeshInFP=True
     bDriverHoldsFlag=False
     DrivePos=(Z=130.000000)
     ExitPositions(0)=(Y=-200.000000,Z=100.000000)
     ExitPositions(1)=(Y=200.000000,Z=100.000000)
     EntryRadius=375.000000
     FPCamPos=(X=10.000000,Y=-32.000000,Z=160.000000)
     FPCamViewOffset=(X=90.000000)
     TPCamDistance=375.000000
     TPCamLookat=(X=-50.000000,Z=0.000000)
     TPCamWorldOffset=(Z=300.000000)
     MomentumMult=0.300000
     DriverDamageMult=0.000000
     VehiclePositionString="in a Hovertank"
     VehicleNameString="Hovertank"
     MaxDesireability=0.700000
     FlagBone="MachineGunTurret"
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn09'
     HornSounds(1)=Sound'ONSBPSounds.ShockTank.PaladinHorn'
     WaterDamage=5.000000
     bJumpCapable=False
     bCanJump=False
     bCanStrafe=True
     MeleeRange=-200.000000
     AirControl=0.300000
     HealthMax=800.000000
     Health=800
     Mesh=SkeletalMesh'ONSNewTank-A.HoverTank'
     SoundRadius=500.000000
     CollisionRadius=260.000000
     CollisionHeight=60.000000
     Begin Object Class=KarmaParamsRBFull Name=HovertankKParams
         KInertiaTensor(0)=1.300000
         KInertiaTensor(3)=4.000000
         KInertiaTensor(5)=4.500000
         KLinearDamping=0.150000
         KAngularDamping=0.000000
         KBuoyancy=1.200000
         KStartEnabled=True
         KMaxSpeed=1000.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'WVHoverTankV2.HoverTank.HovertankKParams'

     bTraceWater=True
}
