class Alligator extends ONSTreadCraft;

#exec OBJ LOAD FILE=..\Animations\ONSVehicles-A.ukx
#exec OBJ LOAD FILE=..\Sounds\ONSVehicleSounds-S.uax
#exec OBJ LOAD FILE=InterfaceContent.utx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx
#exec OBJ LOAD FILE=..\textures\Reptiles_Tex.utx
#exec OBJ LOAD FILE=..\Sounds\CuddlyArmor_Sound.uax
#exec AUDIO IMPORT FILE="Sounds\quack.wav"

var()   float   MaxPitchSpeed;
var VariableTexPanner LeftTreadPanner, RightTreadPanner;
var float TreadVelocityScale;
var float MaxGroundSpeed, MaxAirSpeed;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer )
		SetupTreads();
}

simulated function Destroyed()
{
	DestroyTreads();
	super.Destroyed();
}

function bool ImportantVehicle()
{
	return true;
}

simulated function SetupTreads()
{
	LeftTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
	if ( LeftTreadPanner != None )
	{
		LeftTreadPanner.Material = Skins[1];
		LeftTreadPanner.PanDirection = rot(0, 16384, 0);
		LeftTreadPanner.PanRate = 0.0;
		Skins[1] = LeftTreadPanner;
	}
	RightTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
	if ( RightTreadPanner != None )
	{
		RightTreadPanner.Material = Skins[2];
		RightTreadPanner.PanDirection = rot(0, 16384, 0);
		RightTreadPanner.PanRate = 0.0;
		Skins[2] = RightTreadPanner;
	}
}

simulated function DestroyTreads()
{
	if ( LeftTreadPanner != None )
	{
		Level.ObjectPool.FreeObject(LeftTreadPanner);
		LeftTreadPanner = None;
	}
	if ( RightTreadPanner != None )
	{
		Level.ObjectPool.FreeObject(RightTreadPanner);
		RightTreadPanner = None;
	}
}

simulated event DrivingStatusChanged()
{
    Super.DrivingStatusChanged();

    if (!bDriving)
    {
        if ( LeftTreadPanner != None )
            LeftTreadPanner.PanRate = 0.0;

        if ( RightTreadPanner != None )
            RightTreadPanner.PanRate = 0.0;
    }
}

simulated function Tick(float DeltaTime)
{
    local float EnginePitch;
	local float LinTurnSpeed;
    local KRigidBodyState BodyState;
    local KarmaParams KP;
    local bool bOnGround;
    local int i;

    KGetRigidBodyState(BodyState);

	KP = KarmaParams(KParams);
	bOnGround = false;
	for(i=0; i<KP.Repulsors.Length; i++)
	{
		if( KP.Repulsors[i] != None && KP.Repulsors[i].bRepulsorInContact )
			bOnGround = true;
	}

	if (bOnGround)
    {
        if(PhysicsVolume.bWaterVolume)
        {
            KP.kMaxSpeed=MaxGroundSpeed;
            KP.KLinearDamping=-2.5;
            KP.KAngularDamping=-0.4;

        }
        else
        {
            KP.kMaxSpeed=MaxGroundSpeed;
            KP.KLinearDamping=0;
            KP.KAngularDamping=0;

        }
    }
	else
    {
	   KP.kMaxSpeed = MaxAirSpeed;
    }

    if(Rise > 0)
    {
        KP.KBuoyancy = FClamp(KP.KBuoyancy+0.1, 0.0, 1.0);
    }
    else if(Rise < 0)
    {
        KP.KBuoyancy = FClamp(KP.KBuoyancy-0.1, 0.0, 1.0);
    }

	if ( Level.NetMode != NM_DedicatedServer )
	{
		LinTurnSpeed = 0.5 * BodyState.AngVel.Z;
		EnginePitch = 64.0 + VSize(Velocity)/MaxPitchSpeed * 64.0;
		SoundPitch = FClamp(EnginePitch, 64, 128);

		if ( LeftTreadPanner != None )
		{
			LeftTreadPanner.PanRate = VSize(Velocity) / TreadVelocityScale;
			if (Velocity Dot Vector(Rotation) > 0)
				LeftTreadPanner.PanRate = -1 * LeftTreadPanner.PanRate;
			LeftTreadPanner.PanRate += LinTurnSpeed;
		}

		if ( RightTreadPanner != None )
		{
			RightTreadPanner.PanRate = VSize(Velocity) / TreadVelocityScale;
			if (Velocity Dot Vector(Rotation) > 0)
				RightTreadPanner.PanRate = -1 * RightTreadPanner.PanRate;
			RightTreadPanner.PanRate -= LinTurnSpeed;
		}
	}

    Super.Tick( DeltaTime );
}


function KDriverEnter(Pawn p)
{
    local PlayerController PC;
    PC = PlayerController(P.Controller);


    Super.KDriverEnter(p);

    if(PC != None)
        PC.GotoState('PlayerDriving');


    SVehicleUpdateParams();
}

function DriverLeft()
{
    Super.DriverLeft();

    SVehicleUpdateParams();
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
	if (DamageType == class'Drowned')
		Damage = 0;

	//if (DamageType == class'MinotaurTurretkill')
	if (DamageType.Name == 'MinotaurTurretkill')
		Damage *= 0.30;

	//if (DamageType == class'MinotaurSecondaryTurretKill')
	if (DamageType.Name == 'MinotaurSecondaryTurretKill')
		Damage *= 0.30;

	if (DamageType == class'DamTypeAlligatorBeam')
		Damage *= 0.70;

	//if (DamageType == class'HeatRay')
	if (DamageType.Name == 'HeatRay')
		Damage *= 0.30;

	//if (DamageType == class'FireKill')
	if (DamageType.Name == 'FireKill')
		Damage *= 0.30;

	//if (ClassIsChildOf(DamageType,class'DamTypeAirPower'))
	if (DamageType.name == 'AuroraLaser' || DamageType.name == 'WaspFlak')
		Damage *= 0.70;

	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.70;

	if (DamageType == class'DamTypeONSCicadaRocket')
		Damage *= 0.70;

	if (DamageType == class'DamTypeAttackCraftPlasma')
		Damage *= 0.70;

	if (DamageType == class'DamTypeShockBeam')
		Damage *= 0.60;

        Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.TANKexploded.TankTurret');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.SmokeReOrdered');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'VMParticleTextures.EJECTA.Tex');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlur');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    L.AddPrecacheMaterial(Material'AW-2004Explosions.Fire.Fireball3');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.TANKexploded.TankTurret');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.SmokeReOrdered');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'Reptiles_Tex.Alligator.AlligatorRed');
    Level.AddPrecacheMaterial(Material'Reptiles_Tex.Alligator.AlligatorBlue');
    Level.AddPrecacheMaterial(Material'Reptiles_Tex.Alligator.AlligatorTankTread');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.EJECTA.Tex');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlur');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    Level.AddPrecacheMaterial(Material'AW-2004Explosions.Fire.Fireball3');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
    WaterDamage=0
     MaxPitchSpeed=900.000000
     TreadVelocityScale=450.000000
     MaxGroundSpeed=976.000000
     //MaxAirSpeed=11000.000000
     MaxAirSpeed=5000.0
     ThrusterOffsets(0)=(X=190.000000,Y=145.000000,Z=10.000000)
     ThrusterOffsets(1)=(X=65.000000,Y=145.000000,Z=10.000000)
     ThrusterOffsets(2)=(X=-20.000000,Y=145.000000,Z=10.000000)
     ThrusterOffsets(3)=(X=-200.000000,Y=145.000000,Z=10.000000)
     ThrusterOffsets(4)=(X=190.000000,Y=-145.000000,Z=10.000000)
     ThrusterOffsets(5)=(X=65.000000,Y=-145.000000,Z=10.000000)
     ThrusterOffsets(6)=(X=-20.000000,Y=-145.000000,Z=10.000000)
     ThrusterOffsets(7)=(X=-200.000000,Y=-145.000000,Z=10.000000)
     HoverSoftness=0.050000
     HoverPenScale=1.500000
     HoverCheckDist=65.000000
     UprightStiffness=500.000000
     UprightDamping=300.000000
     MaxThrust=110.000000
     MaxSteerTorque=205.000000
     ForwardDampFactor=0.100000
     LateralDampFactor=1.000000
     ParkingDampFactor=0.800000
     SteerDampFactor=350.000000
     InvertSteeringThrottleThreshold=-0.100000
     DriverWeapons(0)=(WeaponClass=Class'CSAlligator.AlligatorCannon',WeaponBone="TankCannonWeapon")
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSAlligator.AlligatorSecondaryTurretPawn',WeaponBone="MachineGunTurret")
     RedSkin=Texture'Reptiles_Tex.Alligator.AlligatorRed'
     BlueSkin=Texture'Reptiles_Tex.Alligator.AlligatorBlue'
     IdleSound=Sound'CuddlyArmor_Sound.Alligator.AlligatorEngine'
     StartUpSound=Sound'ONSVehicleSounds-S.Tank.TankStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.Tank.TankStop01'
     StartUpForce="TankStartUp"
     ShutDownForce="TankShutDown"
     ViewShakeRadius=600.000000
     ViewShakeOffsetMag=(X=0.500000,Z=2.000000)
     ViewShakeOffsetFreq=7.000000
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.TankDead'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathHoverTank'
     DisintegrationHealth=-125.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     DamagedEffectScale=1.500000
     DamagedEffectOffset=(X=100.000000,Y=20.000000,Z=26.000000)
     bEnableProximityViewShake=True
     HeadlightCoronaOffset(0)=(X=212.000000,Y=110.000000,Z=10.000000)
     HeadlightCoronaOffset(1)=(X=212.000000,Y=-110.000000,Z=10.000000)
     HeadlightCoronaMaterial=Texture'Reptiles_Tex.Alligator.AlligatorFlare'
     HeadlightCoronaMaxSize=115.000000
     HeadlightProjectorMaterial=Texture'Reptiles_Tex.Alligator.AlligatorProjector'
     HeadlightProjectorOffset=(X=212.000000,Z=10.000000)
     HeadlightProjectorRotation=(Pitch=-555)
     HeadlightProjectorScale=1.150000
     VehicleMass=18.000000
     bTurnInPlace=True
     bDrawMeshInFP=True
     bPCRelativeFPRotation=False
     bSeparateTurretFocus=True
     bDriverHoldsFlag=False
     bFPNoZFromCameraPitch=True
     DrivePos=(Z=130.000000)
     ExitPositions(0)=(Y=-200.000000,Z=100.000000)
     ExitPositions(1)=(Y=200.000000,Z=100.000000)
     EntryRadius=375.000000
     FPCamPos=(X=-70.000000,Z=130.000000)
     FPCamViewOffset=(X=90.000000)
     TPCamLookat=(X=-50.000000,Z=0.000000)
     TPCamWorldOffset=(Z=250.000000)
     MomentumMult=0.300000
     DriverDamageMult=0.000000
     VehiclePositionString="in an Alligator"
     VehicleNameString="Alligator"
     RanOverDamageType=Class'CSAlligator.AlligatorDamTypeRoadkill'
     CrushedDamageType=Class'CSAlligator.AlligatorDamTypePancake'
     MaxDesireability=0.800000
     FlagBone="MachineGunTurret"
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'CSAlligator.quack'
     HornSounds(1)=Sound'CuddlyArmor_Sound.Horns.Horn5'
     bCanStrafe=True
     GroundSpeed=640.000000
     WaterSpeed=640.000000
     HealthMax=1200.000000
     Health=1200
     Mesh=SkeletalMesh'ONSNewTank-A.HoverTank'
     Skins(1)=Texture'Reptiles_Tex.Alligator.AlligatorTankTread'
     Skins(2)=Texture'Reptiles_Tex.Alligator.AlligatorTankTread'
     SoundVolume=200
     CollisionRadius=260.000000
     CollisionHeight=60.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.300000
         KInertiaTensor(3)=4.000000
         KInertiaTensor(5)=4.500000
         KLinearDamping=0.000000
         KAngularDamping=0.000000
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
     End Object
     KParams=KarmaParamsRBFull'CSAlligator.Alligator.KParams0'

}
