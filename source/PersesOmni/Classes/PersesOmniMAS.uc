/******************************************************************************
PersesOmniMAS

Creation date: 2011-08-18 21:35
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.

Updated for )o( by pooty
******************************************************************************/

//exec obj load file=PersesOmni_Anim.ukx 

class PersesOmniMAS extends ONSWheeledCraft;


var() const editconst string Build;

var array<vector> GunnerTurretAttachOffsets;
var vector GunMountOffset;
var float GunMountScale;
var array<name> HiddenBones;
var array<Material> DestroyedSkins;
var float ThrottleFixTime, FixedThrottle, FixedSteering, BotEnterTime;


// Not sure we need Reduce Shake
/*replication
{
	reliable if (Role == ROLE_Authority)
		ReduceShake;
}


simulated function ReduceShake()
{
	local float ShakeScaling;
	local PlayerController Player;

	if (Controller == None || PlayerController(Controller) == None)
		return;

	Player = PlayerController(Controller);
	ShakeScaling = VSize(Player.ShakeRotMax) / 7500;

	if (ShakeScaling > 1)
	{
		Player.ShakeRotMax /= ShakeScaling;
		Player.ShakeRotTime /= ShakeScaling;
		Player.ShakeOffsetMax /= ShakeScaling;
	}
}
*/

// Bio Shake fix
simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    // no stupid roll
    if(Abs(PC.ShakeRot.Pitch) >= 16384)
    {
        PC.bEnableAmbientShake = false;
        PC.StopViewShaking();
        PC.ShakeOffset = vect(0,0,0);
        PC.ShakeRot = rot(0,0,0);
    }

    super.SpecialCalcBehindView(PC, ViewActor, CameraLocation, CameraRotation);
}




simulated function String GetDebugName()
{
	return Name$" (build "$Build$")";
}

simulated function PostNetBeginPlay()
{
	local int i;

	for (i = 0; i < HiddenBones.Length; ++i) {
		SetBoneScale(i, 0.0, HiddenBones[i]);
	}

	SetBoneLocation('LeftFrontGunMount',  GunMountOffset);
	SetBoneLocation('RightFrontGunMount', GunMountOffset * vect(1,-1,1));
	SetBoneLocation('LeftRearGunMount',   GunMountOffset * vect(-1,1,1));
	SetBoneLocation('RightRearGunMount',  GunMountOffset * vect(-1,-1,1));
	SetBoneScale(i++, GunMountScale, 'LeftFrontGunMount');
	SetBoneScale(i++, GunMountScale, 'RightFrontGunMount');
	SetBoneScale(i++, GunMountScale, 'LeftRearGunMount');
	SetBoneScale(i++, GunMountScale, 'RightRearGunMount');

	SetBoneScale(i++, 0.001, 'RocketArm');
	SetBoneScale(i++, 1100.0, 'RocketPost');

	for (i = 0; i < PassengerWeapons.Length; i++) {
		SetBoneLocation(PassengerWeapons[i].WeaponBone, GunnerTurretAttachOffsets[i]);
	}


	//AnimBlendParams(1, 1.0, 0.0, 0.0, 'MainGunPowerBase');
	//AnimBlendParams(1, 1.0, 0.0, 0.0, 'MainGunPost');
	//PlayAnim('MASMainGunHide',,, 1);
	//FreezeAnimAt(0.0, 1);
	//PlayAnim('MASMainGunDeploy',,, 2);
	//FreezeAnimAt(0.0, 2);

	Super.PostNetBeginPlay();

	//if (WeaponPawns.Length > 1 && WeaponPawns[1] != None && PersesTankTurret(WeaponPawns[1].Gun) != None)
	//	PersesTankTurret(WeaponPawns[1].Gun).SetLeftTurret(); // invert aim yaw constraints
}


function bool ImportantVehicle()
{
	return true;
}


function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{

    //buffs
//   if (class'BioHandler'.static.IsBioDamage(DamageType)) Damage *= 3.0;
// just do gobs not lasers.

   if (DamageType == class'DamTypeBioGlob')  Damage *= 3.00;
    
    // nerfs
    // None it has 7500 health.
    
    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
   // ReduceShake();
}


function bool NeedToTurn(vector targ)
{
	// rocket pack turns quickly enough to allow approximately spamming in the desired direction
	return (ActiveWeapon >= Weapons.Length || Weapons[ActiveWeapon].bCorrectAim
		|| vector(Weapons[ActiveWeapon].CurrentAim) dot Normal(targ - Weapons[ActiveWeapon].Location) > 0.9);
}

/** Pick most efficient projectile type for the target to attack. */
function ChooseFireAt(Actor A)
{
	local byte BestType;
	local float Dist;
	local Pawn P;
	local int AdditionalTargets;
	
	if (A != None)
	{
		if (ActiveWeapon < Weapons.Length && !Weapons[ActiveWeapon].bCorrectAim)
			BestType = 1; // homing missiles, because not aiming correctly yet
		else
			BestType = 0; // mercury missile
		Dist = VSize(Location - A.Location);
		if (Dist > 3000 && Dist < 15000 && (Pawn(A) == None || Pawn(A).GroundSpeed < 500))
		{
			foreach RadiusActors(class'Pawn', P, 2000, A.Location)
			{
				if (P.Health > 0 && P.bCollideActors && (P.GetTeamNum() == 255 || P.GetTeamNum() != Instigator.GetTeamNum()) && (Vehicle(P) == None || Vehicle(P).IndependentVehicle()))
				{
					AdditionalTargets++;
				}
			}
		}
		if (AdditionalTargets > 1)
		{
			BestType = 2; // frag missiles
		}
		if (AdditionalTargets < 4)
		{
			if (Pawn(A) != None && Pawn(A).bCanFly || ONSVehicle(A) != None && ONSVehicle(A).FastVehicle())
			{
				BestType = 1; // homing missiles
			}
			else if (DestroyableObjective(A) != None || DestroyableObjective(A.Owner) != None || Pawn(A) != None && (Pawn(A).GroundSpeed < 700 && A.CollisionRadius > 200 || Pawn(A).bStationary))
			{
				BestType = 3; // napalm rockets
			}
		}
	}
	else
		log(Self@"firing without target"@A);
	
	if (ActiveWeapon < Weapons.Length && PersesOmniRocketPack(Weapons[ActiveWeapon]) != None)
		PersesOmniRocketPack(Weapons[ActiveWeapon]).ChangeProjectile(BestType);
	
	Super.ChooseFireAt(A);
}

function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	local SquadAI Squad;

	Squad = SquadAI(S);

	if (Squad.GetOrders() == 'Defend')
		return 0;

	return super.BotDesireability(S,TeamIndex, Objective);
}

function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoom();
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if (!bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	PC.StopZoom();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}

function Vehicle FindEntryVehicle(Pawn P)
{
	local Bot B;
	local int i;
	local Vehicle EntryVehicle;

	B = Bot(P.Controller);
	if (B == None || WeaponPawns.Length == 0 || !IsVehicleEmpty() && Driver == None)
	{
		EntryVehicle = Super.FindEntryVehicle(P);
	}
	else
	{
		i = Rand(WeaponPawns.Length);
		if (WeaponPawns[i].Driver == None)
			EntryVehicle =  WeaponPawns[i];
		else
			EntryVehicle =  Super.FindEntryVehicle(P);
	}
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

function KDriverEnter(Pawn P)
{
	Super.KDriverEnter(P);

	BotEnterTime = Level.TimeSeconds;
}

simulated event DestroyAppearance()
{
	local int i;

	// For replication
	bDestroyAppearance = True;

	// Put brakes on
	Throttle	= 0;
	Steering	= 0;
	Rise		= 0;

	// Destroy the weapons
	if (Role == ROLE_Authority) {
		for (i = 0; i < Weapons.Length; i++) {
			if (Weapons[i] != None)
				Weapons[i].Destroy();
		}
		for(i = 0; i < WeaponPawns.Length; i++)
			WeaponPawns[i].Destroy();
	}
	Weapons.Length = 0;
	WeaponPawns.Length = 0;

	// Destroy the effects
	if (Level.NetMode != NM_DedicatedServer) {
		bNoTeamBeacon = true;

		for (i = 0; i < HeadlightCorona.Length; i++)
			HeadlightCorona[i].Destroy();
		HeadlightCorona.Length = 0;

		if (HeadlightProjector != None)
			HeadlightProjector.Destroy();
	}

	// Become the dead vehicle mesh
	Skins = DestroyedSkins;
	RepSkin = Skins[0];
	NetPriority = 2;
}


simulated event ClientVehicleExplosion(bool bFinal)
{
	local int SoundNum;
	local Actor DestructionEffect;

	// Explosion effect
	if (ExplosionSounds.Length > 0) {
		SoundNum = Rand(ExplosionSounds.Length);
		PlaySound(ExplosionSounds[SoundNum], SLOT_None, ExplosionSoundVolume*TransientSoundVolume,, ExplosionSoundRadius);
	}

	if (bFinal) {
		if (Level.NetMode != NM_DedicatedServer)
			DestructionEffect = Spawn(DisintegrationEffectClass,,, Location, Rotation);

		GotoState('VehicleDisintegrated');
	}
}

state VehicleDisintegrated
{
	ignores Died;

Begin:
	Sleep(0.75);
	Destroy();
}

function ServerChangeDriverPosition(byte F)
{
	if ((F == 0 || F > WeaponPawns.Length + 1) && ActiveWeapon < Weapons.Length && PersesOmniRocketPack(Weapons[ActiveWeapon]) != None)
		PersesOmniRocketPack(Weapons[ActiveWeapon]).ChangeProjectile(F - WeaponPawns.Length - 2);
	else
		Super.ServerChangeDriverPosition(F);
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
		
	if (Bot(Controller) != None)
	{
		if (Level.TimeSeconds - BotEnterTime < 1.0)
		{
			// wait for potential passengers
			Throttle = 0.0;
			Steering = 0.0;
		}
		else if (VSize(Velocity) < 10 && EngineRPM > 700 || Level.TimeSeconds - ThrottleFixTime < 1.5)
		{
			// bot got stuck somewhere and doesn't notice
			if (Level.TimeSeconds - ThrottleFixTime > 1.5)
			{
				ThrottleFixTime = Level.TimeSeconds;
				if (Gear == 0)
					FixedThrottle = 1.0; // stuck in reverse, try forward instead
				else
					FixedThrottle = -1.0; // stuck in forward, try reverse instead
				FixedSteering = -Steering * Rand(2); // randomly back up straight (in case bot managed to get stuck in narrow passage)
			}
			//if (Level.TimeSeconds - ThrottleFixTime < 1.0)
			//	Steering = 0.0; // bots usually get stuck trying to turn, so backing up straight shouldn't break anything
			Throttle = FixedThrottle;
			Steering = FixedSteering;
		}
		// TODO: slow down to allow additional passengers to catch up
	}
}

simulated function DrawHud(Canvas C)
{
	local Hud H;
	
	Super.DrawHud(C);
	
	H = C.Viewport.Actor.MyHud;
	if (H == None || H.bShowDebugInfo || H.bHideHud || H.bShowLocalStats || H.bShowScoreBoard || H.PlayerOwner == None || H.PawnOwner == None || H.PawnOwnerPRI == None || H.PlayerOwner.IsSpectating() && H.PlayerOwner.bBehindView)
		return; // don't draw weapon bar on spectator HUD
	
	if (ActiveWeapon < Weapons.Length && PersesOmniRocketPack(Weapons[ActiveWeapon]) != None)
		PersesOmniRocketPack(Weapons[ActiveWeapon]).DrawWeaponBar(C);
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     
     GunnerTurretAttachOffsets(0)=(Z=2.500000)
     GunnerTurretAttachOffsets(1)=(Z=2.500000)
     GunnerTurretAttachOffsets(2)=(X=-2.000000,Z=3.000000)
     GunnerTurretAttachOffsets(3)=(X=-2.000000,Z=3.000000)
     GunMountOffset=(X=32.000000,Z=3.000000)
     GunMountScale=1.400000
     HiddenBones(0)="LeftFrontArm1"
     HiddenBones(1)="RightFrontArm1"
     HiddenBones(2)="LeftRearArm1"
     HiddenBones(3)="RightRearArm1"
     DestroyedSkins(0)=Texture'ONSFullTextures.DeadTextures.MASdeadTEX'
     WheelSoftness=0.040000
     WheelPenScale=1.000000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.010000
     WheelLongFrictionFunc=(Points=(,(InVal=50.000000,OutVal=1.000000),(InVal=100.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=0.900000
     WheelLatFrictionScale=1.500000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=40.000000
     WheelSuspensionMaxRenderTravel=40.000000
     FTScale=0.010000
     ChassisTorqueScale=0.100000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=40.000000),(InVal=700.000000,OutVal=20.000000),(InVal=1000000000.000000,OutVal=10.000000)))
     TorqueCurve=(Points=((OutVal=32.000000),(InVal=200.000000,OutVal=4.000000),(InVal=1500.000000,OutVal=5.000000),(InVal=3000.000000)))
     GearRatios(0)=-0.200000
     GearRatios(1)=0.200000
     NumForwardGears=1
     TransRatio=0.110000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.002000
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=30.000000
     SteerSpeed=120.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.500000
     IdleRPM=1000.000000
     EngineRPMSoundRange=8000.000000
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=90.000000
     RevMeterScale=4000.000000
     bAllowBigWheels=True
     AirPitchDamping=45.000000
     DriverWeapons(0)=(WeaponClass=Class'PersesOmni.PersesOmniRocketPack',WeaponBone="RocketPackAttach")
     PassengerWeapons(0)=(WeaponPawnClass=Class'PersesOmni.PersesOmniTankTurretPawn',WeaponBone="RightFrontgunAttach")
     PassengerWeapons(1)=(WeaponPawnClass=Class'PersesOmni.PersesOmniTankTurretPawn',WeaponBone="LeftFrontGunAttach")
     PassengerWeapons(2)=(WeaponPawnClass=Class'PersesOmni.PersesOmniArtilleryTurretPawn',WeaponBone="RightRearGunAttach")
     PassengerWeapons(3)=(WeaponPawnClass=Class'PersesOmni.PersesOmniArtilleryTurretPawn',WeaponBone="LeftRearGunAttach")
     bHasAltFire=False
     RedSkin=Shader'PersesOmni_Tex.MAS.PersesOmniRedSHAD'
     BlueSkin=Shader'PersesOmni_Tex.MAS.PersesOmniBlueSHAD'
     IdleSound=Sound'ONSVehicleSounds-S.MAS.MASEng01'
     StartUpSound=Sound'ONSVehicleSounds-S.MAS.MASStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.MAS.MASStop01'
     StartUpForce="MASStartUp"
     ShutDownForce="MASShutDown"
     ViewShakeRadius=1000.000000
     ViewShakeOffsetMag=(X=0.700000,Z=2.700000)
     ViewShakeOffsetFreq=7.000000
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'PersesOmni.PersesOmniDeathExplosion'
     DisintegrationHealth=0.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     UpsideDownDamage=500.000000
     ExplosionDamage=250.000000
     ExplosionRadius=500.000000
     DamagedEffectScale=2.500000
     DamagedEffectOffset=(X=300.000000,Z=185.000000)
     bEnableProximityViewShake=True
     bNeverReset=True
     HeadlightCoronaOffset(0)=(X=365.000000,Y=-87.000000,Z=130.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=120.000000
     Begin Object Class=SVehicleWheel Name=RightRearTIRe
         bPoweredWheel=True
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(0)=SVehicleWheel'PersesOmni.PersesOmniMAS.RightRearTIRe'

     Begin Object Class=SVehicleWheel Name=LeftRearTIRE
         bPoweredWheel=True
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(1)=SVehicleWheel'PersesOmni.PersesOmniMAS.LeftRearTIRE'

     Begin Object Class=SVehicleWheel Name=RightFrontTIRE
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(2)=SVehicleWheel'PersesOmni.PersesOmniMAS.RightFrontTIRE'

     Begin Object Class=SVehicleWheel Name=LeftFrontTIRE
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(3)=SVehicleWheel'PersesOmni.PersesOmniMAS.LeftFrontTIRE'

     VehicleMass=12.000000
     bDrawMeshInFP=True
     bKeyVehicle=True
     bSeparateTurretFocus=True
     bDriverHoldsFlag=False
     DrivePos=(X=16.921000,Y=-40.284000,Z=65.793999)
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryRadius=500.000000
     FPCamPos=(X=-350.000000,Z=350.000000)
     TPCamDistance=780.000000
     TPCamLookat=(X=-350.000000,Z=300.000000)
     TPCamWorldOffset=(Z=200.000000)
     TPCamDistRange=(Min=0.000000,Max=2500.000000)
     ShadowCullDistance=2000.000000
     MomentumMult=0.010000
     DriverDamageMult=0.000000
     VehiclePositionString="in a Perses"
     VehicleNameString="Perses Omni 2.04"
     Build="2025-03-09 00:00"
     VehicleDescription="Perses, the ancient Greek Titan god of destruction. And destruction is what the Perses Mobile Assault Station is all about."
     RanOverDamageType=Class'PersesOmni.DamTypePersesOmniRoadkill'
     CrushedDamageType=Class'PersesOmni.DamTypePersesOmniPancake'
     MaxDesireability=2.000000
     ObjectiveGetOutDist=3000.000000
     FlagBone="LeftFrontGunAttach"
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.LevHorn01'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.LevHorn02'
     bSuperSize=True
     NavigationPointRange=190.000000
     HealthMax=7500.000000
     Health=7500
//     Mesh=SkeletalMesh'PersesOmni_Anim.PersesChassis'
// this is loading a bunch of other bs, and is unneeded.  Base MAS is fine.
     Mesh=SkeletalMesh'ONSFullAnimations.MASchassis'
     SoundRadius=255.000000
     CollisionRadius=260.000000
     CollisionHeight=60.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.260000
         KInertiaTensor(3)=3.099998
         KInertiaTensor(5)=4.499996
         KLinearDamping=0.010000
         KAngularDamping=0.010000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KMaxSpeed=1250.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=500.000000
     End Object
     KParams=KarmaParamsRBFull'PersesOmni.PersesOmniMAS.KParams0'

}
