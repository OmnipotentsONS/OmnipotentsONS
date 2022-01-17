//=============================================================================
//  Link Tank
//=============================================================================
// )o(Nodrak - 13/11/05
//     Custom Tank Pack
//
//
//=============================================================================
class LinkTankHospV3Omni  extends ONSTreadCraft;

#exec OBJ LOAD FILE=..\Animations\ANIM_TTanks1b.ukx
#exec OBJ LOAD FILE=..\Sounds\ONSVehicleSounds-S.uax
#exec OBJ LOAD FILE=InterfaceContent.utx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

var class<LinkTWeapon> linkweaponcheck;

var vector AttachOffset;
var()	string	DefaultWeaponClassName;
var() name		CameraBone;
var bool bIsShooting;

var()   float   MaxPitchSpeed;
var VariableTexPanner LeftTreadPanner, RightTreadPanner;
var float TreadVelocityScale;
var float MaxGroundSpeed, MaxAirSpeed;

simulated function UpdateLinkColor( LinkAttachment.ELinkColor color )
{
	if ( Weapons[0] != none && Weapons[0].Class == linkweaponcheck)
	LinkTWeapon(Weapons[0]).UpdateLinkColor( color );
}

function AltFire(optional float F)
{
	super.AltFire( F );
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	super.ClientVehicleCeaseFire( bWasAltFire );
}

simulated function SetupTreads()
{
    LeftTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
    RightTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
    LeftTreadPanner.Material = Skins[1];
 	RightTreadPanner.Material = Skins[2];
 	LeftTreadPanner.PanRate = 0;
 	RightTreadPanner.PanRate = 0;
 	//LeftTreadPanner.PanDirection = rot(0, 16384, 0);
 	//RightTreadPanner.PanDirection = rot(0, 16384, 0);
 	Skins[1] = LeftTreadPanner;
 	Skins[2] = RightTreadPanner;
}

simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local vector x, y, z;
	local vector VehicleZ, CamViewOffsetWorld;
	local float CamViewOffsetZAmount;
	local coords CamBoneCoords;

    GetAxes(CameraRotation, x, y, z);
	ViewActor = self;

	CamViewOffsetWorld = FPCamViewOffset >> CameraRotation;

	if(CameraBone != '' && Weapons[0] != None)
	{
		CamBoneCoords = Weapons[0].GetBoneCoords(CameraBone);
		CameraLocation = CamBoneCoords.Origin + (FPCamPos >> Rotation) + CamViewOffsetWorld;

		if(bFPNoZFromCameraPitch)
		{
			VehicleZ = vect(0,0,1) >> Rotation;
			CamViewOffsetZAmount = CamViewOffsetWorld Dot VehicleZ;
			CameraLocation -= CamViewOffsetZAmount * VehicleZ;
		}
	}
	else
	{
		CameraLocation = GetCameraLocationStart() + (FPCamPos >> Rotation) + CamViewOffsetWorld;

		if(bFPNoZFromCameraPitch)
		{
			VehicleZ = vect(0,0,1) >> Rotation;
			CamViewOffsetZAmount = CamViewOffsetWorld Dot VehicleZ;
			CameraLocation -= CamViewOffsetZAmount * VehicleZ;
		}
	}

    CameraRotation = Normalize(CameraRotation + PC.ShakeRot);
    CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}

function AddDefaultInventory()
{
	GiveWeapon( DefaultWeaponClassName );
	if ( Controller != None )
		Controller.ClientSwitchToBestWeapon();
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

simulated function Destroyed()
{
	DestroyTreads();
	super.Destroyed();
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

function bool ImportantVehicle()
{
	return true;
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.80;

	Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

simulated function PostNetBeginPlay()
{
    local vector RotX, RotY, RotZ;
	local KarmaParams kp;
	local KRepulsor rep;
	local int i, j;

    super(SVehicle).PostNetBeginPlay();

    GetAxes(Rotation,RotX,RotY,RotZ);

	// Spawn and assign 'repulsors' to hold bike off the ground
	kp = KarmaParams(KParams);
	kp.Repulsors.Length = ThrusterOffsets.Length;

	for(j=0;j<ThrusterOffsets.Length;j++)
	{
    	rep = spawn(class'KRepulsor', self,, Location + ThrusterOffsets[j].X * RotX + ThrusterOffsets[j].Y * RotY + ThrusterOffsets[j].Z * RotZ);
    	rep.SetBase(self);
    	rep.bHidden = true;
    	kp.Repulsors[j] = rep;
    }

       	if ( Level.NetMode != NM_DedicatedServer )
		SetupTreads();

		if (Role == ROLE_Authority)
    {
        // Spawn the Driver Weapons
        for(i=0;i<DriverWeapons.Length;i++)
        {
            // Spawn Weapon
            Weapons[i] = spawn(DriverWeapons[i].WeaponClass, self,, Location+vect(-75,0,1000), rot(0,0,0));
            AttachToBone(Weapons[i], DriverWeapons[i].WeaponBone);
            if (!Weapons[i].bAimable)
                Weapons[i].CurrentAim = rot(0,32768,0);
        }

    	if (ActiveWeapon < Weapons.length)
    	{
            PitchUpLimit = Weapons[ActiveWeapon].PitchUpLimit;
            PitchDownLimit = Weapons[ActiveWeapon].PitchDownLimit;
    	}

        // Spawn the Passenger Weapons
        for(i=0;i<PassengerWeapons.Length;i++)
        {
            // Spawn WeaponPawn
            WeaponPawns[i] = spawn(PassengerWeapons[i].WeaponPawnClass, self,, Location);
            WeaponPawns[i].AttachToVehicle(self, PassengerWeapons[i].WeaponBone);
            if (!WeaponPawns[i].bHasOwnHealth)
            	WeaponPawns[i].HealthMax = HealthMax;
            WeaponPawns[i].ObjectiveGetOutDist = ObjectiveGetOutDist;
        }
    }

	if(Level.NetMode != NM_DedicatedServer && Level.DetailMode > DM_Low && SparkEffectClass != None)
	{
		SparkEffect = spawn( SparkEffectClass, self,, Location);
	}

	if(Level.NetMode != NM_DedicatedServer && Level.bUseHeadlights && !(Level.bDropDetail || (Level.DetailMode == DM_Low)))
	{
		HeadlightCorona.Length = HeadlightCoronaOffset.Length;

		for(i=0; i<HeadlightCoronaOffset.Length; i++)
		{
			HeadlightCorona[i] = spawn( class'ONSHeadlightCorona', self,, Location + (HeadlightCoronaOffset[i] >> Rotation) );
			HeadlightCorona[i].SetBase(self);
			HeadlightCorona[i].SetRelativeRotation(rot(0,0,0));
			HeadlightCorona[i].Skins[0] = HeadlightCoronaMaterial;
			HeadlightCorona[i].ChangeTeamTint(Team);
			HeadlightCorona[i].MaxCoronaSize = HeadlightCoronaMaxSize * Level.HeadlightScaling;
		}

		if(HeadlightProjectorMaterial != None && Level.DetailMode == DM_SuperHigh)
		{
			HeadlightProjector = spawn( class'ONSHeadlightProjector', self,, Location + (HeadlightProjectorOffset >> Rotation) );
			HeadlightProjector.SetBase(self);
			HeadlightProjector.SetRelativeRotation( HeadlightProjectorRotation );
			HeadlightProjector.ProjTexture = HeadlightProjectorMaterial;
			HeadlightProjector.SetDrawScale(HeadlightProjectorScale);
			HeadlightProjector.CullDistance	= ShadowCullDistance;
		}
	}

    SetTeamNum(Team);
	TeamChanged();
}

function PossessedBy(Controller C)
{
	Level.Game.DiscardInventory( Self );

	super.PossessedBy( C );

	NetUpdateTime = Level.TimeSeconds - 1;
	bStasis = false;
	C.Pawn	= Self;
	AddDefaultInventory();
	if ( Weapon != None )
	{
		Weapon.NetUpdateTime = Level.TimeSeconds - 1;
		Weapon.Instigator = Self;
		PendingWeapon = None;
		Weapon.BringUp();
	}
}

function UnPossessed()
{
	if ( Weapon != None )
	{
		Weapon.PawnUnpossessed();
		Weapon.ImmediateStopFire();
		Weapon.ServerStopFire( 0 );
		Weapon.ServerStopFire( 1 );
	}
	NetUpdateTime = Level.TimeSeconds - 1;
	super.UnPossessed();
}

event bool KDriverLeave( bool bForceLeave )
{
	local bool			bLeft;
	local Pawn			ExDriver;
	local Controller	ExController;

	if ( Controller != None )
		Controller.StopFiring();
	ExController	= Controller;
	ExDriver		= Driver;

	bLeft = super.KDriverLeave( bForceLeave );
	if ( bLeft && ExDriver != None && ExDriver.Weapon == None && ExController != None && ExController.Pawn == ExDriver )
		ExController.SwitchToBestWeapon();

	return bLeft;
}

simulated function ClientKDriverEnter( PlayerController PC )
{
	super.ClientKDriverEnter( PC );

	// force controller here, because it's not replicated yet...
	PC.Pawn = Self;
	Controller = PC;
	SetOwner( PC );
	if ( Weapon != None )
	{
		PendingWeapon = None;
		Weapon.BringUp();
	}
	else
		PC.SwitchToBestWeapon();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	if ( PC != None && Weapon != None )
		Weapon.PawnUnpossessed();

	super.ClientKDriverLeave( PC );
}

simulated function bool StopWeaponFiring()
{
	if ( Weapon == None )
		return false;

	Weapon.PawnUnpossessed();

	if ( Weapon.IsFiring() )
	{
		if ( Controller != None )
		{
			if ( !Controller.IsA('PlayerController') )
				Weapon.ServerStopFire( Weapon.BotMode );
			else
			{
				Controller.StopFiring();
				Weapon.ServerStopFire( 0 );
				Weapon.ServerStopFire( 1 );
			}
		}
		else
		{
			Weapon.ServerStopFire( 0 );
			Weapon.ServerStopFire( 1 );
		}
		return true;
	}

	return false;
}

function KDriverEnter(Pawn p)
{
    Super.KDriverEnter(p);

    SVehicleUpdateParams();
}

function DriverLeft()
{
    Super.DriverLeft();

    SVehicleUpdateParams();
}

simulated function setsounds()
{
          if (IdleSound != none)
          {
             AmbientSound = IdleSound;
             SoundVolume = 200;
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

	// Increase max karma speed if falling
	bOnGround = false;
	for(i=0; i<KP.Repulsors.Length; i++)
	{
        //log("Checking Repulsor "$i);
		if( KP.Repulsors[i] != None && KP.Repulsors[i].bRepulsorInContact )
			bOnGround = true;
		//log("bOnGround: "$bOnGround);
	}

	if (bOnGround)
	   KP.kMaxSpeed = MaxGroundSpeed;
	else
	   KP.kMaxSpeed = MaxAirSpeed;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (bIsShooting)
			SoundPitch = 64;
		else
		{
        LinTurnSpeed = 0.5 * BodyState.AngVel.Z;
		EnginePitch = 64.0 + VSize(Velocity)/MaxPitchSpeed * 64.0;
		SoundPitch = FClamp(EnginePitch, 64, 128);
        }

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

    super.Tick( DeltaTime );
}

state VehicleDestroyed
{
    function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
    {
    }

Begin:
    DestroyAppearance();
    VehicleExplosion(vect(0,0,1), 1.0);
    sleep(3.0);
    Destroy();
}


static function StaticPrecache(LevelInfo L)
{
    super(ONSTreadCraft).StaticPrecache(L);

	L.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankBody');
	L.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTread');
	L.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTurret');
	L.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankBodyDead');
	L.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTreadDead');
	L.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTurretDead');

	L.AddPrecacheMaterial(Texture'AS_FX_TX.HUD.AssaultHUD');

	// FX
	L.AddPrecacheMaterial( Material'AW-2004Particles.Weapons.HardSpot' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Energy.AirBlastP' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Energy.PurpleSwell' );
	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp2_framesP' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Flares.SoftFlare' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Beams.WhiteStreak01aw' );
	L.AddPrecacheMaterial( Texture'AW-2004Particles.Energy.EclipseCircle' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Flares.HotSpot' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Weapons.GrenExpl' );
	L.AddPrecacheMaterial( Material'AS_FX_TX.Flares.Laser_Flare' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Weapons.PlasmaStar' );

	L.AddPrecacheStaticMesh( StaticMesh'AW-2004Particles.Weapons.PlasmaSphere' );
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh( StaticMesh'AW-2004Particles.Weapons.PlasmaSphere' );

	super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankBody');
	Level.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTread');
	Level.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTurret');
	Level.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankBodyDead');
	Level.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTreadDead');
	Level.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTurretDead');

	// FX
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Weapons.HardSpot' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Energy.AirBlastP' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Energy.PurpleSwell' );
	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp2_framesP' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Flares.SoftFlare' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Beams.WhiteStreak01aw' );
	Level.AddPrecacheMaterial( Texture'AW-2004Particles.Energy.EclipseCircle' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Flares.HotSpot' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Weapons.GrenExpl' );
	Level.AddPrecacheMaterial( Material'AS_FX_TX.Flares.Laser_Flare' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Weapons.PlasmaStar' );

	super.UpdatePrecacheMaterials();
}

defaultproperties
{
     linkweaponcheck=Class'HospitalerV3Omni.LinkTWeapon'
     DefaultWeaponClassName="HospitalerV3Omni.LinkTW"
     CameraBone="("
     MaxPitchSpeed=700.000000
     TreadVelocityScale=450.000000
     MaxGroundSpeed=800.000000
     MaxAirSpeed=5000.000000
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
     MaxThrust=65.000000
     MaxSteerTorque=100.000000
     ForwardDampFactor=0.100000
     LateralDampFactor=0.500000
     ParkingDampFactor=0.800000
     SteerDampFactor=100.000000
     InvertSteeringThrottleThreshold=-0.100000
     DriverWeapons(0)=(WeaponClass=Class'HospitalerV3Omni.LinkTWeapon',WeaponBone="TankCannonWeapon")
     IdleSound=Sound'ONSVehicleSounds-S.Tank.TankEng01'
     StartUpSound=Sound'ONSVehicleSounds-S.Tank.TankStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.Tank.TankStop01'
     StartUpForce="TankStartUp"
     ShutDownForce="TankShutDown"
     ViewShakeRadius=600.000000
     ViewShakeOffsetMag=(X=0.500000,Z=2.000000)
     ViewShakeOffsetFreq=7.000000
     DestroyedVehicleMesh=StaticMesh'AS_Vehicles_SM.Vehicles.IonTankDestroyed'
     DestructionEffectClass=Class'HospitalerV3Omni.LinkTankExplosion'
     DisintegrationEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationHealth=-125.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     DamagedEffectScale=1.500000
     DamagedEffectOffset=(X=100.000000,Y=20.000000,Z=26.000000)
     bEnableProximityViewShake=True
     VehicleMass=12.000000
     bTurnInPlace=True
     bDrawMeshInFP=True
     bPCRelativeFPRotation=False
     bKeyVehicle=True
     bSeparateTurretFocus=True
     bDriverHoldsFlag=False
     DrivePos=(Z=130.000000)
     ExitPositions(0)=(Y=-200.000000,Z=100.000000)
     ExitPositions(1)=(Y=200.000000,Z=100.000000)
     EntryRadius=375.000000
     FPCamPos=(X=100.000000,Z=150.000000)
     FPCamViewOffset=(X=-25.000000)
     TPCamDistance=250.000000
     TPCamLookat=(X=0.000000,Z=20.000000)
     TPCamWorldOffset=(Z=300.000000)
     MomentumMult=0.300000
     DriverDamageMult=0.000000
     VehiclePositionString="in a Link Tank Hospitaler"
     VehicleNameString="Link Tank (Hospitaler 3.0)"
     RanOverDamageType=Class'HospitalerV3Omni.DamTypeLTRK'
     CrushedDamageType=Class'HospitalerV3Omni.DamTypeLTP'
     MaxDesireability=0.800000
     FlagBone="MachineGunTurret"
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn09'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Horn02'
     VehicleIcon=(Material=Texture'AS_FX_TX.Icons.OBJ_IonTank',bIsGreyScale=True)
     bCanStrafe=True
     GroundSpeed=520.000000
     HealthMax=800.000000
     Health=800
     Mesh=SkeletalMesh'ANIM_TTanks1b.IonTankChassisSimple'
     Skins(0)=Combiner'AS_Vehicles_TX.IonPlasmaTank.IonTankBody_C'
     Skins(1)=Texture'AS_Vehicles_TX.IonPlasmaTank.IonTankTread'
     Skins(2)=Texture'AS_Vehicles_TX.IonPlasmaTank.IonTankTread'
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
         KMaxSpeed=800.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
     End Object
     KParams=KarmaParamsRBFull'HospitalerV3Omni.LinkTankHospV3Omni.KParams0'

}
