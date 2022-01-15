//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CSPallasVehicle extends ONSWheeledCraft
	placeable;


// begin levi
#exec OBJ LOAD FILE=..\Sounds\MenuSounds.uax
#exec OBJ LOAD FILE=..\Textures\ONSFullTextures.utx
//#exec TEXTURE IMPORT DXT=1 FORMAT=DXT1 FILE=Textures\CSPallasRed.dds
//#exec TEXTURE IMPORT DXT=1 FORMAT=DXT1 FILE=Textures\CSPallasBlue.dds
#exec OBJ LOAD FILE=Textures\CSPallasTex.utx PACKAGE=CSPallasV2
#exec AUDIO IMPORT FILE=Sounds\deploy.wav
#exec AUDIO IMPORT FILE=Sounds\PallasEngine01.wav
#exec AUDIO IMPORT FILE=Sounds\PallasEngineStart01.wav
#exec AUDIO IMPORT FILE=Sounds\PallasEngineStop01.wav

var()       sound   DeploySound;
var()       sound   HideSound;
var()		string	DeployForce;
var()		string	HideForce;
var         EPhysics    ServerPhysics;

var         string  Build;
var			bool	bDeployed;
var			bool	bOldDeployed;
var			bool 	bShouldDeploy;
var			bool 	bOldShouldDeploy;

var			vector  UnDeployedTPCamLookat;
var			vector  UnDeployedTPCamWorldOffset;
var			vector  DeployedTPCamLookat;
var			vector  DeployedTPCamWorldOffset;

var			vector  UnDeployedFPCamPos;
var			vector  DeployedFPCamPos;
// end levi

// begin spma
var float   ClientUpdateTime;
var float	StartDrivingTime;	// AI Hint
var Rotator LastAim;
var CSPallasMortarCamera MortarCamera;
var float LastLocalMsgTime;
var string ArtiLockOnClassString;
// end spma
var PlayerController shakenPlayer;
var bool fixShaking;

replication
{
	//begin levi
	unreliable if(Role==ROLE_Authority)
        ServerPhysics, bDeployed, bShouldDeploy;
	//end levi

	//begin spma
	//reliable if (Role == ROLE_Authority)
	reliable if (True)
        MortarCamera;

	reliable if (Role < ROLE_Authority)
        ServerAim;		
	//end spma
}




simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetBoneLocation('RightFrontGunAttach', (vect(0,0,4)));
	SetBoneLocation('LeftFrontGunAttach', (vect(0,0,4)));
	SetBoneLocation('RightRearGunAttach', (vect(0,0,4)));
	SetBoneLocation('LeftRearGunAttach', (vect(0,0,4)));
}

function KDriverEnter(Pawn p)
{
	p.ReceiveLocalizedMessage(class'CSPallasV2.CSPallasDeployMessage', 0);
	Super.KDriverEnter(p);
}

simulated event PostNetReceive()
{
    Super.PostNetReceive();

    if (ServerPhysics != Physics)
    {
        bMovable = (ServerPhysics == PHYS_Karma);
        SetPhysics(ServerPhysics);
    }

	if( bDeployed != bOldDeployed )
	{
		if(bDeployed)
		{
			TPCamLookat = DeployedTPCamLookat;
			TPCamWorldOffset = DeployedTPCamWorldOffset;
			FPCamPos = DeployedFPCamPos;
			//bEnableProximityViewShake = False;
		}
		else
		{
			TPCamLookat = UnDeployedTPCamLookat;
			TPCamWorldOffset = UnDeployedTPCamWorldOffset;
			FPCamPos = UnDeployedFPCamPos;
			//bEnableProximityViewShake = True;
		}

		bOldDeployed = bDeployed;
	}
}


// deploy via spacebar
simulated function CheckShouldDeploy()
{
	if (PlayerController(Controller) != None && Rise > 0.0)
	{
		if(bDeployed)
		{
			bShouldDeploy = false;
		}
		else if(VSize(Velocity) <= 15) 
		{
			bShouldDeploy = true;
		}
	}
}

simulated function Tick(float DT)
{
    Super.Tick(DT);
    CheckShouldDeploy();
    if(bOldShouldDeploy != bShouldDeploy)
    {
        if(bShouldDeploy)
        {
            GotoState('Deploying');
        }
        else
        {
            GotoState('UnDeploying');
        }

        bOldShouldDeploy = bShouldDeploy;
    }

    TickArtillery(DT);
}

simulated function TickArtillery(float DT)
{
    local CSPallasArtilleryCannon ArtilleryCannon;

    if(Weapons.length>0 && Weapons[ActiveWeapon] != None)
        ArtilleryCannon = CSPallasArtilleryCannon(Weapons[ActiveWeapon]);

    if (MortarCamera != None)
    {
	    bCustomAiming = True;
		if(ArtilleryCannon != None && IslocallyControlled())
		{
			CustomAim = ArtilleryCannon.TargetRotation;
		}

        if ( IsLocallyControlled() && IsHumanControlled() )
        {
            /*
            if ( PlayerController(Controller) != None && PlayerController(Controller).ViewTarget != MortarCamera )
			{
                log("setviewtarget4");
                PlayerController(Controller).SetViewTarget(MortarCamera);
                //PlayerController(Controller).bBehindView = false;
			}
            */

            if ((Level.TimeSeconds - ClientUpdateTime > 0.0222) && CustomAim != LastAim)
            {
                ClientUpdateTime = Level.TimeSeconds;
                ServerAim(CustomAim.Yaw & 0xffff | CustomAim.Pitch << 16);
				LastAim = CustomAim;
            }
        }

        // OMG HACK! (what's wrong with implementing all ONSVehicle aiming methods in ONSWeaponPawn?)
        if (AIController(Controller) != None && ArtilleryCannon != None)
		{
			ArtilleryCannon.bAimable = False; // prevent rotation in the ONSWeaponPawn's native Tick (it does The Wrong Thing)
			ArtilleryCannon.CurrentHitLocation = ArtilleryCannon.WeaponFireLocation + vector(CustomAim) * ArtilleryCannon.AimTraceRange;
		}
    }
	else if ( AIController(Controller) != None && ArtilleryCannon != None)
	{
        bCustomAiming = True;
        CustomAim = ArtilleryCannon.TargetRotation;
        SetRotation(CustomAim);

        ArtilleryCannon.bAimable = False; // prevent rotation in the ONSWeaponPawn's native Tick (it does The Wrong Thing)
        ArtilleryCannon.CurrentHitLocation = ArtilleryCannon.WeaponFireLocation + vector(CustomAim) * ArtilleryCannon.AimTraceRange;
	}
    else
    {
        bCustomAiming = False;
        if (IsLocallyControlled() && Weapons.length>0 && Weapons[ActiveWeapon] != None)
		{
            CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
		}
    }
}

simulated function PrevWeapon()
{
    if (MortarCamera != None && Weapons[ActiveWeapon] != None && CSPallasArtilleryCannon(Weapons[ActiveWeapon]) != None)
    {
        CSPallasArtilleryCannon(Weapons[ActiveWeapon]).SetWeaponCharge(FMin(CSPallasArtilleryCannon(Weapons[ActiveWeapon]).WeaponCharge + 0.025, 0.999));

    }
    //else
        Super.PrevWeapon();
}

simulated function NextWeapon()
{
    if (MortarCamera != None && Weapons[ActiveWeapon] != None && CSPallasArtilleryCannon(Weapons[ActiveWeapon]) != None)
    {
        CSPallasArtilleryCannon(Weapons[ActiveWeapon]).SetWeaponCharge(FMax(CSPallasArtilleryCannon(Weapons[ActiveWeapon]).WeaponCharge - 0.025, 0.0));
    }
    //else
        Super.NextWeapon();
}

simulated function actor AlternateTarget()
{
    return MortarCamera;
}

event bool VerifyLock(actor Aggressor, out actor NewTarget)
{
	local	class<LocalMessage>	LockOnClass;

	if (MortarCamera != None && !FastTrace(Location, Aggressor.Location))
	{
        NewTarget = MortarCamera;
        return False;
    }

	// Lock has switched from the Camera to the SPMA, notify the Avril Controller

	if (Aggressor.Instigator!=None && Aggressor.Instigator.Controller !=None &&
			PlayerController(Aggressor.Instigator.Controller) != none)
	{
	 	if (Level.TimeSeconds > LastLocalMsgTime + LockWarningInterval)
	 	{
			LockOnClass = class<LocalMessage>(DynamicLoadObject(ArtiLockOnClassString, class'class'));
			PlayerController(Aggressor.Instigator.Controller).ReceiveLocalizedMessage(LockOnClass, 32);
		}
	}

    return True;
}

simulated event Destroyed()
{
    if (MortarCamera != None)
        MortarCamera.TakeDamage(1, None, vect(0,0,0), vect(0,0,0), class'DamageType');

    Super.Destroyed();
}

function DriverLeft()
{
    if (MortarCamera != None)
        MortarCamera.TakeDamage(1, None, vect(0,0,0), vect(0,0,0), class'DamageType');

    Super.DriverLeft();
}

event ApplyFireImpulse(bool bAlt)
{
	if ( AIController(Instigator.Controller) != None )
	{
		if ( Controller.Target != None && !bAlt)
		{
			Weapons[ActiveWeapon].CalcWeaponFire();
			Weapons[ActiveWeapon].WeaponFireRotation = Rotator(Controller.Target.Location - Weapons[ActiveWeapon].WeaponFireLocation);
			Weapons[ActiveWeapon].WeaponFireRotation.Pitch = 10000;
			Weapons[ActiveWeapon].WeaponFireLocation.Z = Location.Z + 500;
		}
	}
	Super.ApplyFireImpulse(bAlt);
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function bool ImportantVehicle()
{
	return true;
}

function bool IsArtillery()
{
	return true;
}

function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	local SquadAI Squad;

	Squad = SquadAI(S);

	if ( Squad.GetOrders() == 'Defend' )
		return 0;

	return super.BotDesireability(S,TeamIndex,Objective);
}

function VehicleFire(bool bWasAltFire)
{
	local vector TargetDir;
	local rotator AimRot;

	if ( bWasAltFire )
	{
		if (  MortarCamera != None )
		{
			if ( !MortarCamera.bDeployed )
			{
				if ( AIController(Instigator.Controller) != None )
				{
					return;
				}
				MortarCamera.Deploy();
				CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
				StopWeaponFiring();
				return;
			}
			else
			{
				if ( AIController(Instigator.Controller) != None )
					bWasAltFire = false;
				else
					MortarCamera.Destroy();
			}
			return;
		}
		else if ( (AIController(Instigator.Controller) != None) && (Controller.Target != None) )
		{
			TargetDir = Controller.Target.Location - Location;
			TargetDir.Z = 0;
			AimRot = Weapons[ActiveWeapon].CurrentAim;
			AimRot.Pitch = 0;
			if ( (Normal(TargetDir) Dot Vector(AimRot)) < 0.9 )
			{
				return;
			}
		}
	}

	Super.VehicleFire(bWasAltFire);
}

function AltFire( optional float F )
{
	local bool bHasCamera;
	bHasCamera = ( MortarCamera != None );

	Super.AltFire(F);
    if ( MortarCamera != None )
    {
		if ( Role < ROLE_Authority  && !MortarCamera.bDeployed )
		{
			MortarCamera.Deploy();
			CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
		}
	}
	if ( bHasCamera )
	{
		bWeaponIsAltFiring = false;
	}
}

function ServerAim(int NewYaw)
{
    CustomAim.Yaw = NewYaw & 0xffff;
    CustomAim.Pitch = NewYaw >>> 16;
    CustomAim.Roll = 0;
}

function int LimitPitch(int pitch)
{
	if (ActiveWeapon >= Weapons.length)
		return Super.LimitPitch(pitch);

	if (CSPallasArtilleryCannon(Weapons[ActiveWeapon]) != None 
    && CSPallasArtilleryCannon(Weapons[ActiveWeapon]).MortarCamera != None 
    && !CSPallasArtilleryCannon(Weapons[ActiveWeapon]).MortarCamera.bShotDown)
	{
    	pitch = pitch & 65535;

        if (pitch > 2500 && pitch < 49153)
        {
            if (pitch - 2500 < 49153 - pitch)
                pitch = 2500;
            else
                pitch = 49153;
        }
        return pitch;		
    }

	return Weapons[ActiveWeapon].LimitPitch(pitch, Rotation);
}

function ChooseFireAt(Actor A)
{
	Fire(0);
}

auto state UnDeployed
{
	function Deploy()
	{
		AltFire(0);
	}

	function ChooseFireAt(Actor A)
	{
		local Bot B;

		B = Bot(Controller);
		if ( B == None || B.Squad == None || ONSPowerCore(B.Squad.SquadObjective) == None )
		{
			Fire(0);
			return;
		}

		if ( ONSPowerCore(B.Squad.SquadObjective).LegitimateTargetOf(B) && CanAttack(B.Squad.SquadObjective) )
			AltFire(0);
		else
			Fire(0);
	}
}

state Deployed
{
	function MayUndeploy()
	{
		bShouldDeploy = false;
	}

	function bool IsDeployed()
	{
		return true;
	}
}

state UnDeploying
{
Begin:
    if (Controller != None)
    {
    	if (PlayerController(Controller) != None)
    	{
	        PlayerController(Controller).ClientPlaySound(HideSound);
        	if (PlayerController(Controller).bEnableGUIForceFeedback)
			PlayerController(Controller).ClientPlayForceFeedback(HideForce);
		}

		if(MortarCamera != None)
		{
			MortarCamera.Destroy();
		}


        PlayAnim('MASMainGunHide');
        sleep(4.03);
        bMovable = True;
    	SetPhysics(PHYS_Karma);
    	ServerPhysics = PHYS_Karma;
    	bStationary = False;
    	SetActiveWeapon(0);
    	TPCamLookat = UnDeployedTPCamLookat;
    	TPCamWorldOffset = UnDeployedTPCamWorldOffset;
    	FPCamPos = UnDeployedFPCamPos;
		bShowChargingBar=false;
    	//bEnableProximityViewShake = True;
        Weapons[1].bForceCenterAim = True;
    	bDeployed = False;
        GotoState('UnDeployed');
    }
}

state Deploying
{
Begin:
    if (Controller != None)
    {
    	SetPhysics(PHYS_None);
    	ServerPhysics = PHYS_None;
    	bMovable = False;
    	bStationary = True;
    	if (PlayerController(Controller) != None)
    	{
	        PlayerController(Controller).ClientPlaySound(DeploySound);
        	if (PlayerController(Controller).bEnableGUIForceFeedback)
			PlayerController(Controller).ClientPlayForceFeedback(DeployForce);
	}
        PlayAnim('MASMainGunDeploy');
        sleep(3.46);
        Weapons[1].bForceCenterAim = False;

        SetActiveWeapon(1);
    	bWeaponisFiring = false; 
    	TPCamLookat = DeployedTPCamLookat;
    	TPCamWorldOffset = DeployedTPCamWorldOffset;
    	FPCamPos = DeployedFPCamPos;
    	//bEnableProximityViewShake = False;
		bShowChargingBar=true;
    	bDeployed = True;
        GotoState('Deployed');
    }
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    bMovable = True;
    SetPhysics(PHYS_Karma);

    Super.Died(Killer, damageType, HitLocation);
}

simulated event ClientVehicleExplosion(bool bFinal)
{
	local int SoundNum;
    local Actor DestructionEffect;

    // Explosion effect
	if(ExplosionSounds.Length > 0)
	{
		SoundNum = Rand(ExplosionSounds.Length);
		PlaySound(ExplosionSounds[SoundNum], SLOT_None, ExplosionSoundVolume*TransientSoundVolume,, ExplosionSoundRadius);
	}

	if (bFinal)
    {
        if (Level.NetMode != NM_DedicatedServer)
            DestructionEffect = spawn(DisintegrationEffectClass,,, Location, Rotation);

        GotoState('VehicleDisintegrated');
    }
}

state VehicleDisintegrated
{
    function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
    {
    }

Begin:
    sleep(0.75);
    Destroy();
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

    L.AddPrecacheMaterial(Material'CSPallasV2.CSPallasRed');
    L.AddPrecacheMaterial(Material'CSPallasV2.CSPallasBlue');

	L.AddPrecacheStaticMesh(StaticMesh'ParticleMeshes.Complex.ExplosionRing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.BayDoor');
	L.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.MainGun');
	L.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.SideFlap');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVcolorRED');
    L.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVnoColor');
    L.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVcolorBlue');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ParticleMeshes.Complex.ExplosionRing');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.BayDoor');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.MainGun');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.SideFlap');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'CSPallasV2.CSPallasRed');
    Level.AddPrecacheMaterial(Material'CSPallasV2.CSPallasBlue');

    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVcolorRED');
    Level.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVnoColor');
    Level.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVcolorBlue');
    Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

	Super.UpdatePrecacheMaterials();
}

function ShouldTargetMissile(Projectile P)
{
    local AIController C;

	C = AIController(Controller);
	if (C != None && C.Skill >= 3.0 && (C.Enemy == None || !C.LineOfSightTo(C.Enemy)))
		ShootMissile(P);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{

    //buffs
    if (DamageType == class'DamTypeBioGlob')
        Damage *= 3.0;

	if (DamageType == class'DamTypeLinkShaft')
		Damage *= 3.0;

	if (DamageType == class'DamTypeFlakChunk')
		Damage *= 2.0;

	if (DamageType == class'DamTypeFlakShell')
		Damage *= 2.0;

    //nerfs
	if (DamageType == class'DamTypeTankShell')
		Damage *= 0.7;

	if (DamageType.name == 'MinotaurKill')
		Damage *= 0.5;

	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.5;

	if (DamageType == class'DamTypeONSCicadaRocket')
		Damage *= 0.5;

	if (DamageType == class'DamTypeAttackCraftPlasma')
		Damage *= 0.5;

	if (DamageType == class'DamTypeShockBeam')
		Damage *= 0.5;

    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

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

defaultproperties
{
     DeploySound=Sound'CSPallasV2.deploy'
     HideSound=Sound'CSPallasV2.deploy'
     DeployForce="MASDeploy"
     HideForce="MASDeploy"
     ServerPhysics=PHYS_Karma
     UnDeployedTPCamLookat=(X=-200.000000,Z=300.000000)
     UnDeployedTPCamWorldOffset=(Z=200.000000)
     DeployedTPCamLookat=(X=100.000000)
     DeployedTPCamWorldOffset=(Z=800.000000)
     UnDeployedFPCamPos=(X=-240.000000,Z=350.000000)
     DeployedFPCamPos=(Z=600.000000)
     WheelSoftness=0.040000
     WheelPenScale=1.000000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.010000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
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
     MaxSteerAngleCurve=(Points=((OutVal=55.000000),(InVal=1500.000000,OutVal=35.000000),(InVal=1000000000.000000,OutVal=30.000000)))
     TorqueCurve=(Points=((OutVal=8.000000),(InVal=200.000000,OutVal=2.000000),(InVal=3000.000000,OutVal=1.500000),(InVal=4000.000000)))
     GearRatios(0)=-0.200000
     GearRatios(1)=0.200000
     NumForwardGears=1
     TransRatio=0.110000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000200
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=40.000000
     SteerSpeed=110.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.500000
     IdleRPM=700.000000
     EngineRPMSoundRange=4000.000000
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=90.000000
     RevMeterScale=6000.000000
     bAllowBigWheels=True
     AirPitchDamping=45.000000
     DriverWeapons(0)=(WeaponClass=Class'CSPallasV2.CSPallasMainCannon',WeaponBone="RocketPackAttach")
     DriverWeapons(1)=(WeaponClass=Class'CSPallasV2.CSPallasArtilleryCannon',WeaponBone="maingunpostBase")
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSPallasV2.CSPallasTurretCannonPawn',WeaponBone="RightFrontgunAttach")
     PassengerWeapons(1)=(WeaponPawnClass=Class'CSPallasV2.CSPallasTurretCannonPawn',WeaponBone="LeftFrontGunAttach")
     PassengerWeapons(2)=(WeaponPawnClass=Class'CSPallasV2.CSPallasTurretCannonPawn',WeaponBone="RightRearGunAttach")
     PassengerWeapons(3)=(WeaponPawnClass=Class'CSPallasV2.CSPallasTurretCannonPawn',WeaponBone="LeftRearGunAttach")
     CustomAim=(Pitch=12000)
     RedSkin=Shader'CSPallasV2.CSPallasRedShader'
     BlueSkin=Shader'CSPallasV2.CSPallasBlueShader'
     //IdleSound=Sound'ONSVehicleSounds-S.MAS.MASEng01'
     //StartUpSound=Sound'ONSVehicleSounds-S.MAS.MASStart01'
     //ShutDownSound=Sound'ONSVehicleSounds-S.MAS.MASStop01'
     IdleSound=Sound'CSPallasV2.PallasEngine01'
     StartUpSound=Sound'ONSVehicleSounds-S.MAS.MASStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.MAS.MASStop01'
     StartUpForce="MASStartUp"
     ShutDownForce="MASShutDown"

     ViewShakeRadius=1000.000000
     ViewShakeOffsetMag=(X=0.700000,Z=2.700000)
     ViewShakeOffsetFreq=7.000000

     DestroyedVehicleMesh=StaticMesh'ONSFullStaticMeshes.leviathanDEAD'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'OnslaughtFull.ONSVehDeathMAS'
     DisintegrationHealth=0.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     UpsideDownDamage=500.000000
     DamagedEffectScale=2.500000
     DamagedEffectOffset=(X=300.000000,Z=185.000000)
     //bEnableProximityViewShake=True
     bEnableProximityViewShake=False
     bOnlyViewShakeIfDriven=true
     bNeverReset=True
     bCannotBeBased=False
     HeadlightCoronaOffset(0)=(X=365.000000,Y=-87.000000,Z=130.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=120.000000
     Begin Object Class=SVehicleWheel Name=RightRearTIRe
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(0)=SVehicleWheel'CSPallasV2.CSPallasVehicle.RightRearTIRe'

     Begin Object Class=SVehicleWheel Name=LeftRearTIRE
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(1)=SVehicleWheel'CSPallasV2.CSPallasVehicle.LeftRearTIRE'

     Begin Object Class=SVehicleWheel Name=RightFrontTIRE
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(2)=SVehicleWheel'CSPallasV2.CSPallasVehicle.RightFrontTIRE'

     Begin Object Class=SVehicleWheel Name=LeftFrontTIRE
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(3)=SVehicleWheel'CSPallasV2.CSPallasVehicle.LeftFrontTIRE'

     VehicleMass=10.000000
     bDrawMeshInFP=True
     bKeyVehicle=True
     bDriverHoldsFlag=False
     DrivePos=(X=16.921000,Y=-40.284000,Z=65.793999)
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryRadius=500.000000
     FPCamPos=(X=-240.000000,Z=350.000000)
     TPCamDistance=300.000000
     TPCamLookat=(X=-200.000000,Z=300.000000)
     TPCamWorldOffset=(Z=200.000000)
     TPCamDistRange=(Min=0.000000,Max=2500.000000)
     MaxViewPitch=30000
     ShadowCullDistance=2000.000000
     MomentumMult=0.010000
     DriverDamageMult=0.000000
     VehiclePositionString="in a Pallas"
     VehicleNameString="Pallas 2.1"
     RanOverDamageType=Class'OnslaughtFull.DamTypeMASRoadkill'
     CrushedDamageType=Class'OnslaughtFull.DamTypeMASPancake'
     MaxDesireability=2.000000
     ObjectiveGetOutDist=2000.000000
     FlagBone="LeftFrontGunAttach"
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.LevHorn01'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.LevHorn02'
     bSuperSize=True
     NavigationPointRange=190.000000
     HealthMax=5000.000000
     Health=5000
     bStasis=False
     bReplicateAnimations=True
     Mesh=SkeletalMesh'ONSFullAnimations.MASchassis'
     SoundRadius=255.000000
     CollisionRadius=260.000000
     CollisionHeight=60.000000
     bNetNotify=True
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.260000
         KInertiaTensor(3)=3.099998
         KInertiaTensor(5)=4.499996
         KLinearDamping=0.010000
         KAngularDamping=0.010000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KMaxSpeed=2000.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=500.000000
     End Object
     KParams=KarmaParamsRBFull'CSPallasV2.CSPallasVehicle.KParams0'

}
