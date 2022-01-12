//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CSSpankBadger extends ONSWheeledCraft;

//#exec OBJ LOAD FILE=..\Animations\Badger_Ani.ukx
#exec OBJ LOAD FILE=Animations\Badger_Ani_Fixed.ukx PACKAGE=CSSpankBadger
#exec OBJ LOAD FILE=Sounds\Badger_Sound.uax PACKAGE=CSSpankBadger
#exec OBJ LOAD FILE=..\textures\EpicParticles.utx
#exec OBJ LOAD FILE=textures\Badger_Tex.utx PACKAGE=CSSpankBadger
#exec OBJ LOAD FILE=StaticMeshes\Badger_SM.usx PACKAGE=CSSpankBadger

simulated function PostBeginPlay()
{
    SetBoneLocation('TurretSpawn', (vect(0,0,10)));
    super.PostBeginPlay();
}


function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	local Bot B;
	local SquadAI Squad;
	local int Num;

	Squad = SquadAI(S);

	if (Squad.Size == 1)
	{
		if ( (Squad.Team != None) && (Squad.Team.Size == 1) && Level.Game.IsA('ASGameInfo') )
			return Super.BotDesireability(S, TeamIndex, Objective);
		return 0;
	}

	for (B = Squad.SquadMembers; B != None; B = B.NextSquadMember)
		if (Vehicle(B.Pawn) == None && (B.RouteGoal == self || B.Pawn == None || VSize(B.Pawn.Location - Location) < Squad.MaxVehicleDist(B.Pawn)))
			Num++;

	if ( Num < 2 )
		return 0;

	return Super.BotDesireability(S, TeamIndex, Objective);
}

function Vehicle FindEntryVehicle(Pawn P)
{
	local Bot B;
	local int i;

	B = Bot(P.Controller);
	if (B == None || WeaponPawns.length == 0 || !IsVehicleEmpty() || ((B.PlayerReplicationInfo.Team != None) && (B.PlayerReplicationInfo.Team.Size == 1) && Level.Game.IsA('ASGameInfo')) )
		return Super.FindEntryVehicle(P);

	for (i = WeaponPawns.length - 1; i >= 0; i--)
		if (WeaponPawns[i].Driver == None)
			return WeaponPawns[i];

	return Super.FindEntryVehicle(P);
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'CSSpankBadger.BadgerWreck_Turret');
	L.AddPrecacheStaticMesh(StaticMesh'CSSpankBadger.BadgerWreck_Minigun');
	L.AddPrecacheStaticMesh(StaticMesh'CSSpankBadger.BadgerWreck_Wheel');
      L.AddPrecacheStaticMesh(StaticMesh'CSSpankBadger.BadgerWreck_Hull');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'CSSpankBadger.BadgerRed');
    L.AddPrecacheMaterial(Material'CSSpankBadger.BadgerBlue');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.PowerSwirl');
    L.AddPrecacheMaterial(Material'VMWeaponsTX.ManualBaseGun.baseGunEffectcopy');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'CSSpankBadger.BadgerWreck_Turret');
	Level.AddPrecacheStaticMesh(StaticMesh'CSSpankBadger.BadgerWreck_Minigun');
	Level.AddPrecacheStaticMesh(StaticMesh'CSSpankBadger.BadgerWreck_Wheel');
	Level.AddPrecacheStaticMesh(StaticMesh'CSSpankBadger.BadgerWreck_Hull');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'CSSpankBadger.BadgerRed');
    Level.AddPrecacheMaterial(Material'CSSpankBadger.BadgerBlue');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.PowerSwirl');
    Level.AddPrecacheMaterial(Material'VMWeaponsTX.ManualBaseGun.baseGunEffectcopy');
    Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     WheelSoftness=0.010000
     WheelPenScale=1.000000
     WheelInertia=0.050000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=150.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=2.500000
     WheelLatFrictionScale=2.700000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=6.200000
     WheelSuspensionOffset=-7.000000
     WheelSuspensionMaxRenderTravel=11.000000
     FTScale=0.030000
     ChassisTorqueScale=1.100000
     MinBrakeFriction=5.000000
     MaxSteerAngleCurve=(Points=((OutVal=25.000000),(InVal=1500.000000,OutVal=8.000000),(InVal=1000000000.000000,OutVal=8.000000)))
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=2500.000000)))
     GearRatios(0)=-0.800000
     GearRatios(1)=0.600000
     GearRatios(2)=0.900000
     GearRatios(3)=1.100000
     GearRatios(4)=1.400000
     TransRatio=0.190000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=17.000000
     SteerSpeed=90.000000
     TurnDamping=35.000000
     StopThreshold=100.000000
     HandbrakeThresh=120.000000
     EngineInertia=0.050000
     IdleRPM=500.000000
     EngineRPMSoundRange=10000.000000
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=50.000000
     DustSlipRate=12.000000
     DustSlipThresh=0.800000
     RevMeterScale=4000.000000
     bMakeBrakeLights=True
     //BrakeLightOffset(0)=(X=-58.000000,Y=-50.000000,Z=76.000000)
     //BrakeLightOffset(1)=(X=-58.000000,Y=50.000000,Z=76.000000)
     BrakeLightOffset(0)=(X=-58.000000,Y=-50.000000,Z=31.000000)
     BrakeLightOffset(1)=(X=-58.000000,Y=50.000000,Z=31.000000)
     BrakeLightMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     DaredevilThreshInAirSpin=75.000000
     bDoStuntInfo=True
     bAllowAirControl=True
     bAllowBigWheels=True
     MaxJumpForce=400000.000000
     AirTurnTorque=55.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     //DriverWeapons(0)=(WeaponClass=Class'CSSpankBadger.BadgerMinigun',WeaponBone="MinigunSpawn")
     //PassengerWeapons(0)=(WeaponPawnClass=Class'CSSpankBadger.BadgerTurretPawn',WeaponBone="TurretSpawn")
     DriverWeapons(0)=(WeaponClass=Class'CSSpankBadger.CSSpankBadgerWeapon',WeaponBone="TurretSpawn")
     //RedSkin=Texture'Badger_Tex.Badger.BadgerRed'
     //BlueSkin=Texture'Badger_Tex.Badger.BadgerBlue'
     RedSkin=Shader'CSSpankBadger.Badger.SpankBadgerRedShader'
     BlueSkin=Shader'CSSpankBadger.Badger.SpankBadgerBlueShader'
     IdleSound=Sound'CSSpankBadger.BadgerEngine'
     StartUpSound=Sound'CSSpankBadger.BadgerStart'
     ShutDownSound=Sound'CSSpankBadger.BadgerStop'
     StartUpForce="PRVStartUp"
     ShutDownForce="PRVShutDown"
     DestroyedVehicleMesh=StaticMesh'CSSpankBadger.BadgerWreck_Hull'
     DestructionEffectClass=Class'CSSpankBadger.CSBadgerDeath'
     DisintegrationEffectClass=Class'CSSpankBadger.ONSVehDeathBadger'
     DisintegrationHealth=-100.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectScale=1.200000
     DamagedEffectOffset=(X=55.000000,Y=-10.000000,Z=60.000000)
     ImpactDamageMult=0.000500
     //HeadlightCoronaOffset(0)=(X=81.000000,Y=-15.000000,Z=58.000000)
     //HeadlightCoronaOffset(1)=(X=81.000000,Y=15.000000,Z=58.000000)
     HeadlightCoronaOffset(0)=(X=81.000000,Y=-15.000000,Z=13.000000)
     HeadlightCoronaOffset(1)=(X=81.000000,Y=15.000000,Z=13.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=90.000000
     HeadlightProjectorMaterial=Texture'VMVehicles-TX.NEWprvGroup.PRVprojector'
     HeadlightProjectorOffset=(X=130.000000,Z=15.000000)
     HeadlightProjectorRotation=(Pitch=-1000)
     HeadlightProjectorScale=0.650000
     Begin Object Class=SVehicleWheel Name=RRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightRearSTRUT"
     End Object
     Wheels(0)=SVehicleWheel'CSSpankBadger.CSSpankBadger.RRWheel'

     Begin Object Class=SVehicleWheel Name=LRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftRearSTRUT"
     End Object
     Wheels(1)=SVehicleWheel'CSSpankBadger.CSSpankBadger.LRWheel'

     Begin Object Class=SVehicleWheel Name=RFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightFrontSTRUT"
     End Object
     Wheels(2)=SVehicleWheel'CSSpankBadger.CSSpankBadger.RFWheel'

     Begin Object Class=SVehicleWheel Name=LFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftFrontSTRUT"
     End Object
     Wheels(3)=SVehicleWheel'CSSpankBadger.CSSpankBadger.LFWheel'

     VehicleMass=6.200000
     bCanDoTrickJumps=True
     bHasHandbrake=True
     bDriverHoldsFlag=False
     DrivePos=(X=-10.000000,Z=10.000000)
     ExitPositions(0)=(X=-180.000000,Z=100.000000)
     ExitPositions(1)=(X=-180.000000,Y=-100.000000,Z=100.000000)
     ExitPositions(2)=(X=-180.000000,Y=100.000000,Z=100.000000)
     EntryRadius=180.000000
     FPCamPos=(X=-20.000000,Z=160.000000)
     TPCamDistance=365.000000
     TPCamLookat=(X=0.000000)
     TPCamWorldOffset=(Z=100.000000)
     MomentumMult=2.000000
     DriverDamageMult=0.000000
     VehiclePositionString="in a Spanker"
     VehicleNameString="Spanker"
     RanOverDamageType=Class'CSSpankBadger.CSBadgerRoadkill'
     CrushedDamageType=Class'CSSpankBadger.CSBadgerPancake'
     ObjectiveGetOutDist=1500.000000
     FlagBone="MinigunSpawn"
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.La_Cucharacha_Horn'
     VehicleIcon=(Material=Texture'AS_FX_TX.Icons.OBJ_HellBender',bIsGreyScale=True)
     GroundSpeed=850.000000
     HealthMax=700.000000
     Health=700
     Mesh=SkeletalMesh'CSSpankBadger.BadgerChassis'
     SoundVolume=250
     CollisionRadius=175.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=500.000000
         KCOMOffset=(X=0.0,Y=0.0,Z=-1.0)
     End Object
     KParams=KarmaParamsRBFull'CSSpankBadger.CSSpankBadger.KParams0'

     bSelected=True
}
