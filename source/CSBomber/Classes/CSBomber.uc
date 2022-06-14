
//////////////////////////////////////////
// CSBomber - CaptainSnarf
//////////////////////////////////////////
class CSBomber extends ONSChopperCraft
    placeable;

#exec obj load file="textures\CSBomber_Tex.utx" package=CSBomber
#exec obj load file="Animations\Bomber_Anim.ukx" package=CSBomber
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx
#exec AUDIO IMPORT FILE=Sounds\BoostSound.wav

var()   float							MaxPitchSpeed;

var()   array<vector>					TrailEffectPositions;
var     class<ONSAttackCraftExhaust>	TrailEffectClass;
var     array<ONSAttackCraftExhaust>	TrailEffects;

var()	array<vector>					StreamerEffectOffset;
var     class<ONSAttackCraftStreamer>	StreamerEffectClass;
var		array<ONSAttackCraftStreamer>	StreamerEffect;

var()	range							StreamerOpacityRamp;
var()	float							StreamerOpacityChangeRate;
var()	float							StreamerOpacityMax;
var		float							StreamerCurrentOpacity;
var		bool							StreamerActive;

var float lastAForward;
var float lastForwardPress, SecondForwardPress;

var () class<Emitter>	AfterburnerClass[2];
var Emitter				Afterburner[2];
var array<Emitter>				Afterburners;
var () Vector			AfterburnerOffset[2];
var () Rotator		AfterburnerRotOffset[2];
var bool				  bAfterburnersOn;

var bool  bBoost;         //Boost functionality
var float BoostForce;
var float BoostTime;
var Sound BoostSound, BoostReadySound;
var float BoostRechargeTime;
var float BoostRechargeCounter;
var float BoostFOV;
var float BoostDoubleTapThreshold;

replication
{
  reliable if (Role==ROLE_Authority)
     bBoost,  BoostRechargeCounter;
  reliable if (Role<ROLE_Authority)
    ServerBoost;
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    BoostRechargeCounter=BoostRechargeTime;
}

function bool FastVehicle()
{
	return true;
}

/*
Function RawInput(float DeltaTime,
                            float aBaseX, float aBaseY, float aBaseZ, float aMouseX, float aMouseY,
                            float aForward, float aTurn, float aStrafe, float aUp, float aLookUp)
{
    //if (aForward != lastAForward)
    if (aForward > 0 && lastAForward <= 0)
    {
        if(aForward > 0)
        {
            SecondForwardPress=lastForwardPress;
            lastForwardPress=Level.TimeSeconds;
        }

        if(aForward > 0 && (lastForwardPress - SecondForwardPress) < BoostDoubleTapThreshold)
        {
            //double forward press
            if(BoostRechargeCounter>=BoostRechargeTime)
            {
                Boost();
            }
        }
    }
    lastAForward=aForward;
    super.RawInput(DeltaTime, aBaseX, aBaseY, aBaseZ, aMouseX, aMouseY, aForward, aTurn, aStrafe, aUp, aLookUp);
}
*/

function KDriverEnter(Pawn P)
{
	bHeadingInitialized = False;

	Super.KDriverEnter(P);
}

function Boost()
{
	if (bBoost)
	{
	  PlaySound(BoostReadySound, SLOT_Misc, 128,,,160);
	}

	if (!bBoost)
	{
        BoostRechargeCounter=0;
        PlaySound(BoostSound, SLOT_Misc, 128,,,1.0); //Boost sound Pitch 160
		ServerBoost();
	}
}

simulated function ServerBoost()
{
    BoostRechargeCounter=0;
    bBoost=true;
}


simulated function SwitchWeapon(byte F)
{
    super.SwitchWeapon(F);
    if(F == 10)
    {
        Boost();
    }
}

//
simulated function EnableAfterburners(bool bEnable)
{
    local int i;
	// Don't bother on dedicated server, this controls graphics only
	if (Level.NetMode != NM_DedicatedServer)
	{
		//Because we want the trail emitters to look right (proper team color and not strangely angled at startup) we need to create our emitters every time we boost
        if (bEnable)
        {
            Afterburners.Length = TrailEffectPositions.Length;
        	for(i=0;i<Afterburners.Length;i++)
            {
            	if (Afterburners[i] == None)
            	{
                	Afterburners[i] = spawn(AfterburnerClass[Team], self,, Location + (TrailEffectPositions[i] >> Rotation) );
                	Afterburners[i].SetBase(self);
                    Afterburners[i].SetRelativeRotation( rot(0,32768,0) );
                }
            }
        }
        else
        {
            for(i=0; i<Afterburners.Length; i++)
            {
                if(Afterburners[i] != None)
                    Afterburners[i].Destroy();
            }

            Afterburners.Length = 0;
        }
	}

	bAfterburnersOn = bEnable; // update state of afterburners
}

simulated event Timer()
{
	// when boost time exceeds time limit, turn it off and disable the primed detonator
	bBoost = false;
	EnableAfterburners(bBoost);
}

simulated function BoostTick(float DT)
{
    //If bAfterburnersOn and boost state don't agree
    if (bBoost != bAfterburnersOn)
    {
        // it means we need to change the state of the vehicle (bAfterburnersOn)
        // to match the desired state (bBoost)
        EnableAfterburners(bBoost); // show/hide afterburner smoke

        // if we just enabled afterburners, set the timer
        // to turn them off after set time has expired
        if (bBoost)
        {
            SetTimer(BoostTime, false);
        }
    }

    if (Role == ROLE_Authority)
    {
        // Afterburners recharge after the change in time exceeds the specified charge duration
        if(BoostRechargeCounter<BoostRechargeTime)
        {
            BoostRechargeCounter+=DT;
        }

        if (BoostRechargeCounter > BoostRechargeTime)
        {
            BoostRechargeCounter = BoostRechargeTime;
            if( PlayerController(Controller) != None)
            {
                PlayerController(Controller).ClientPlaySound(BoostReadySound,,,SLOT_Misc);
            }
        }
    }
}

simulated event KApplyForce(out vector Force, out vector Torque)
{
	Super.KApplyForce(Force, Torque); // apply other forces first
	if (bBoost)
	{
        Force += vector(Rotation) + vect(0,0,0.25);
		Force += Normal(Force) * BoostForce; // apply force in that direction
	}
}


simulated function float ChargeBar()
{
    return FClamp(BoostRechargeCounter/BoostRechargeTime, 0.0, 0.999);
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	bHeadingInitialized = False;

	Super.ClientKDriverEnter(PC);
}

simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector CamLookAt, HitLocation, HitNormal, OffsetVector;
	local Actor HitActor;
    local vector x, y, z;

	if (DesiredTPCamDistance < TPCamDistance)
		TPCamDistance = FMax(DesiredTPCamDistance, TPCamDistance - CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));
	else if (DesiredTPCamDistance > TPCamDistance)
		TPCamDistance = FMin(DesiredTPCamDistance, TPCamDistance + CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));

    GetAxes(PC.Rotation, x, y, z);
	ViewActor = self;
	CamLookAt = GetCameraLocationStart() + (TPCamLookat >> Rotation) + TPCamWorldOffset;

	OffsetVector = vect(0, 0, 0);
	OffsetVector.X = -1.0 * TPCamDistance;

	CameraLocation = CamLookAt + (OffsetVector >> PC.Rotation);

	HitActor = Trace(HitLocation, HitNormal, CameraLocation, Location, true, vect(40, 40, 40));
	if ( HitActor != None
	     && (HitActor.bWorldGeometry || HitActor == GetVehicleBase() || Trace(HitLocation, HitNormal, CameraLocation, Location, false, vect(40, 40, 40)) != None) )
			CameraLocation = HitLocation;

    CameraRotation = Normalize(PC.Rotation + PC.ShakeRot);
    CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local int i;

    if(Level.NetMode != NM_DedicatedServer)
	{
    	for(i=0;i<TrailEffects.Length;i++)
        	TrailEffects[i].Destroy();

        TrailEffects.Length = 0;

		for(i=0; i<StreamerEffect.Length; i++)
			StreamerEffect[i].Destroy();

		StreamerEffect.Length = 0;

		for(i=0; i<Afterburners.Length; i++)
			Afterburners[i].Destroy();
        
        Afterburners.Length=0;
    }

	Super.Died(Killer, damageType, HitLocation);
}

simulated function Destroyed()
{
    local int i;

    if(Level.NetMode != NM_DedicatedServer)
	{
    	for(i=0;i<TrailEffects.Length;i++)
        	TrailEffects[i].Destroy();
        TrailEffects.Length = 0;

		for(i=0; i<StreamerEffect.Length; i++)
			StreamerEffect[i].Destroy();
		StreamerEffect.Length = 0;

		for(i=0; i<Afterburners.Length; i++)
			Afterburners[i].Destroy();
        Afterburners.Length=0;
    }

    Super.Destroyed();
}

simulated event DrivingStatusChanged()
{
	local vector RotX, RotY, RotZ;
	local int i;

	Super.DrivingStatusChanged();

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{
        GetAxes(Rotation,RotX,RotY,RotZ);

        if (TrailEffects.Length == 0)
        {
            TrailEffects.Length = TrailEffectPositions.Length;

        	for(i=0;i<TrailEffects.Length;i++)
            	if (TrailEffects[i] == None)
            	{
                	TrailEffects[i] = spawn(TrailEffectClass, self,, Location + (TrailEffectPositions[i] >> Rotation) );
                	TrailEffects[i].SetBase(self);
                    TrailEffects[i].SetRelativeRotation( rot(0,32768,0) );
                }
        }

        if (StreamerEffect.Length == 0)
        {
    		StreamerEffect.Length = StreamerEffectOffset.Length;

    		for(i=0; i<StreamerEffect.Length; i++)
        		if (StreamerEffect[i] == None)
        		{
        			StreamerEffect[i] = spawn(StreamerEffectClass, self,, Location + (StreamerEffectOffset[i] >> Rotation) );
        			StreamerEffect[i].SetBase(self);
        		}
    	}
    }
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
    	{
        	for(i=0;i<TrailEffects.Length;i++)
        	   TrailEffects[i].Destroy();

        	TrailEffects.Length = 0;

    		for(i=0; i<StreamerEffect.Length; i++)
                StreamerEffect[i].Destroy();

            StreamerEffect.Length = 0;
        }
    }
}

simulated function Tick(float DeltaTime)
{
    local float EnginePitch, DesiredOpacity, DeltaOpacity, MaxOpacityChange, ThrustAmount;
	local TrailEmitter T;
	local int i;
	local vector RelVel;
	local bool NewStreamerActive, bIsBehindView;
	local PlayerController PC;

    if(Level.NetMode != NM_DedicatedServer)
	{
        EnginePitch = 64.0 + VSize(Velocity)/MaxPitchSpeed * 32.0;
        SoundPitch = FClamp(EnginePitch, 64, 96);

        RelVel = Velocity << Rotation;

        PC = Level.GetLocalPlayerController();
		if (PC != None && PC.ViewTarget == self)
			bIsBehindView = PC.bBehindView;
		else
            bIsBehindView = True;

    	// Adjust Engine FX depending on being drive/velocity
		if (!bIsBehindView)
		{
			for(i=0; i<TrailEffects.Length; i++)
				TrailEffects[i].SetThrustEnabled(false);
		}
        else
        {
			ThrustAmount = FClamp(OutputThrust, 0.0, 1.0);

			for(i=0; i<TrailEffects.Length; i++)
			{
				TrailEffects[i].SetThrustEnabled(true);
				TrailEffects[i].SetThrust(ThrustAmount);
			}
		}

		// Update streamer opacity (limit max change speed)
		DesiredOpacity = (RelVel.X - StreamerOpacityRamp.Min)/(StreamerOpacityRamp.Max - StreamerOpacityRamp.Min);
		DesiredOpacity = FClamp(DesiredOpacity, 0.0, StreamerOpacityMax);

		MaxOpacityChange = DeltaTime * StreamerOpacityChangeRate;

		DeltaOpacity = DesiredOpacity - StreamerCurrentOpacity;
		DeltaOpacity = FClamp(DeltaOpacity, -MaxOpacityChange, MaxOpacityChange);

		if(!bIsBehindView)
            StreamerCurrentOpacity = 0.0;
        else
    		StreamerCurrentOpacity += DeltaOpacity;

		if(StreamerCurrentOpacity < 0.01)
			NewStreamerActive = false;
		else
			NewStreamerActive = true;

		for(i=0; i<StreamerEffect.Length; i++)
		{
			if(NewStreamerActive)
			{
				if(!StreamerActive)
				{
					T = TrailEmitter(StreamerEffect[i].Emitters[0]);
					T.ResetTrail();
				}

				StreamerEffect[i].Emitters[0].Disabled = false;
				StreamerEffect[i].Emitters[0].Opacity = StreamerCurrentOpacity;
			}
			else
			{
				StreamerEffect[i].Emitters[0].Disabled = true;
				StreamerEffect[i].Emitters[0].Opacity = 0.0;
			}
		}

		StreamerActive = NewStreamerActive;
    }

    BoostTick(DeltaTime);

    Super.Tick(DeltaTime);
}

function float ImpactDamageModifier()
{
    local float Multiplier;
    local vector X, Y, Z;

    GetAxes(Rotation, X, Y, Z);
    if (ImpactInfo.ImpactNorm Dot Z > 0)
        Multiplier = 1-(ImpactInfo.ImpactNorm Dot Z);
    else
        Multiplier = 1.0;

    return Super.ImpactDamageModifier() * Multiplier;
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function bool PlaceExitingDriver()
{
	local int		i;
	local vector	tryPlace, Extent, HitLocation, HitNormal, ZOffset;

	if ( Driver == None )
		return false;

	Extent = Driver.default.CollisionRadius * vect(1,1,0);
	Extent.Z = Driver.default.CollisionHeight;
	ZOffset = Driver.default.CollisionHeight * vect(0,0,1);

    if(Steering < 0)
    {
        ZOffset = Driver.default.CollisionHeight * vect(0,0,2);
        tryPlace = Location + ( (ExitPositions[0]-ZOffset) >> Rotation) + ZOffset;
        if ( Driver.SetLocation(tryPlace) )
            return true;
    }
    else if(Steering > 0)
    {
        ZOffset = Driver.default.CollisionHeight * vect(0,0,2);
        tryPlace = Location + ( (ExitPositions[1]-ZOffset) >> Rotation) + ZOffset;
        if ( Driver.SetLocation(tryPlace) )
            return true;
    }
    else
    {
        ZOffset = Driver.default.CollisionHeight * vect(0,0,2);
        tryPlace = Location + ( (ExitPositions[2]-ZOffset) >> Rotation) + ZOffset;
        if ( Driver.SetLocation(tryPlace) )
            return true;
    }

	for( i=0; i<ExitPositions.Length; i++)
	{
		if ( ExitPositions[0].Z != 0 )
			ZOffset = Vect(0,0,1) * ExitPositions[0].Z;
		else
			ZOffset = Driver.default.CollisionHeight * vect(0,0,2);

		tryPlace = Location + ( (ExitPositions[i]-ZOffset) >> Rotation) + ZOffset;

		// First, do a line check (stops us passing through things on exit).
		if ( Trace(HitLocation, HitNormal, tryPlace, Location + ZOffset, false, Extent) != None )
			continue;

		// Then see if we can place the player there.
		if ( !Driver.SetLocation(tryPlace) )
			continue;

		return true;
	}
	return false;
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlura');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
}

simulated function UpdatePrecacheStaticMeshes()
{
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
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlura');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
    bCanBeBaseForPawns=true

    //Mesh=Mesh'ONSFullAnimations.Bomber'
    Mesh=Mesh'CSBomber.Bomber'
    VehicleNameString="Guppy Bomber 1.2"
	VehiclePositionString="in a Guppy Bomber"
    RedSkin=Shader'CSBomber.CSBomberRedShader'
    BlueSkin=Shader'CSBomber.CSBomberBlueShader'
    DriverWeapons(0)=(WeaponClass=class'CSBomber.CSBomberWeapon',WeaponBone=FrontGunMount);

	EntryPosition=(X=-40,Y=0,Z=0)
	EntryRadius=510.0
    DrawScale=0.5

    DestroyedVehicleMesh=None
    DestructionEffectClass=Class'UT2k4Assault.FX_SpaceFighter_Explosion_Directional'
	DisintegrationEffectClass=None

    DestructionLinearMomentum=(Min=50000,Max=150000)
    DestructionAngularMomentum=(Min=100,Max=300)

	Health=300
	HealthMax=300
	DriverDamageMult=0.0
	CollisionHeight=+70.0
	CollisionRadius=150.0
	ImpactDamageMult=0.0010
	RanOverDamageType=class'CSBomber.CSBomberDamTypeRoadkill'
	CrushedDamageType=class'CSBomber.CSBomberDamTypePancake'

	IdleSound=sound'ONSVehicleSounds-S.AttackCraft.AttackCraftIdle'
	StartUpSound=sound'ONSVehicleSounds-S.AttackCraft.AttackCraftStartUp'
	ShutDownSound=sound'ONSVehicleSounds-S.AttackCraft.AttackCraftShutDown'
	MaxPitchSpeed=2000
	SoundVolume=160
	SoundRadius=200

	StartUpForce="AttackCraftStartUp"
	ShutDownForce="AttackCraftShutDown"

	TrailEffectPositions(0)=(X=-192,Y=-38,Z=20);
   	TrailEffectPositions(1)=(X=-192,Y=38,Z=20);
	TrailEffectPositions(2)=(X=-58,Y=-61,Z=30);
   	TrailEffectPositions(3)=(X=-58,Y=61,Z=30);
	TrailEffectPositions(4)=(X=-76,Y=-81,Z=-30);
   	TrailEffectPositions(5)=(X=-76,Y=81,Z=-30);
	TrailEffectClass=class'Onslaught.ONSAttackCraftExhaust'

	StreamerEffectOffset(0)=(X=-192,Y=-73,Z=83);
   	StreamerEffectOffset(1)=(X=-192,Y=73,Z=83);
	StreamerEffectOffset(2)=(X=-58,Y=-201,Z=70);
   	StreamerEffectOffset(3)=(X=-58,Y=201,Z=70);
	StreamerEffectOffset(4)=(X=-76,Y=-221,Z=-10);
   	StreamerEffectOffset(5)=(X=-76,Y=221,Z=-10);
	StreamerEffectClass=class'Onslaught.ONSAttackCraftStreamer'
	StreamerOpacityRamp=(Min=1200.000000,Max=1600.000000)
	StreamerOpacityChangeRate=1.0
	StreamerOpacityMax=0.7

	bShowDamageOverlay=True

	TPCamDistance=500
	TPCamLookAt=(X=0.0,Y=0.0,Z=0)
	TPCamWorldOffset=(X=0,Y=0,Z=200)

	bDrawDriverInTP=False
	bDrawMeshInFP=False
	bTurnInPlace=true
	bCanStrafe=true

    UprightStiffness=500.000000
    UprightDamping=300.000000
    MaxThrustForce=180.000000
    LongDamping=0.050000
    MaxStrafeForce=120.000000
    LatDamping=0.050000
    MaxRiseForce=75.000000
    UpDamping=0.050000
    TurnTorqueFactor=650.000000
    TurnTorqueMax=250.000000
    TurnDamping=50.000000
    MaxYawRate=2.500000
    PitchTorqueFactor=200.000000
    PitchTorqueMax=35.000000
    PitchDamping=20.000000
    RollTorqueTurnFactor=550.000000
    RollTorqueStrafeFactor=90.000000
    RollTorqueMax=90.000000
    RollDamping=40.000000
    MaxRandForce=3.000000
    RandForceInterval=0.750000

	StopThreshold=100
	VehicleMass=4.0

	//ExitPositions(0)=(X=180,Y=0,Z=10)
	//ExitPositions(1)=(X=-180,Y=0,Z=10)
	ExitPositions(0)=(X=-180,Y=220,Z=10)
	ExitPositions(1)=(X=-180,Y=-220,Z=10)
	ExitPositions(2)=(X=-260,Y=0,Z=10)

	HeadlightCoronaOffset(0)=(X=76,Y=14,Z=-24)
	HeadlightCoronaOffset(1)=(X=76,Y=-14,Z=-24)
	HeadlightCoronaMaterial=Material'EpicParticles.flashflare1'
	HeadlightCoronaMaxSize=60

	//DamagedEffectOffset=(X=-120,Y=10,Z=65)
	//DamagedEffectScale=1.0
	DamagedEffectOffset=(X=-50,Y=0,Z=0)
	DamagedEffectScale=1.7

    Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.250000)
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KActorGravScale=0.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=300.000000
     End Object
     KParams=KarmaParamsRBFull'KParams0'    
	GroundSpeed=2000
	bDriverHoldsFlag=false
	FlagOffset=(Z=80.0)
	FlagBone=Bomber
	FlagRotation=(Yaw=32768)
	bCanCarryFlag=false

	HornSounds(0)=sound'ONSVehicleSounds-S.Horn06'
	HornSounds(1)=sound'ONSVehicleSounds-S.La_Cucharacha_Horn'
	MaxDesireability=0.6

    AfterburnerClass(0)=class'CSBomberSmokeTrail'
    AfterburnerClass(1)=class'CSBomberSmokeTrail'

    BoostForce=16000.000000
    BoostTime=2.000000
    BoostSound=Sound'CSBomber.BoostSound'
    BoostReadySound=Sound'WeaponSounds.TAGRifle.TAGTargetAquired'
    BoostRechargeTime=4.000000
    BoostDoubleTapThreshold=0.25
    bShowChargingBar=True

}