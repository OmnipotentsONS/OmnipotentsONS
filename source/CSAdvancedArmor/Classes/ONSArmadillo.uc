//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSArmadillo extends ONSTreadCraft;

#exec OBJ LOAD FILE=..\Animations\AdvancedArmor_anim.ukx
#exec OBJ LOAD FILE=..\Staticmeshes\AdvancedArmor_ST.usx
#exec OBJ LOAD FILE=..\Sounds\ONSVehicleSounds-S.uax
#exec OBJ LOAD FILE=..\textures\AdvancedArmor_Tex.utx
#exec OBJ LOAD FILE=..\textures\PC_ConvoyTextures.utx
var()   float   MaxPitchSpeed;
var VariableTexPanner TreadPanner;
var float TreadVelocityScale;
var FX_ArmorRunningLight LeftRunningLight,RightRunningLight,LRearRunningLight,RRearRunningLight;
var vector LeftRunningLightOffset,RightRunningLightOffset,RearRunningLightOffset;
var FX_ArmorHeadLight LeftHeadLight,RightHeadLight;
var vector LeftHLightOffset,RightHLightOffset;
// Shield effect actors
var	class<Actor>	GenericShieldEffect[2];
var	float			NextShieldTime;
var(Shield) float   ShieldStrengthMax;               // max strength
var float SmallShieldStrength;						 // for preventing shieldstacking


simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer )
		SetupTreads();
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
      AddShieldStrength(ShieldStrength);
}

simulated function Destroyed()
{
	DestroyTreads();
	if(LeftRunningLight!=none)
       LeftRunningLight.Destroy();
    if(RightRunningLight!=none)
       RightRunningLight.Destroy();
    if(LRearRunningLight!=none)
       LRearRunningLight.Destroy();
    if(RRearRunningLight!=none)
       RRearRunningLight.Destroy();
    if(LeftHeadLight!=none)
       LeftHeadLight.Destroy();
    if(RightHeadLight!=none)
       RightHeadLight.Destroy();
	super.Destroyed();
}

simulated function SetupTreads()
{

    TreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
	if ( TreadPanner != None )
	{
		TreadPanner.Material = Skins[0];
		TreadPanner.PanDirection = rot(0, 16384, 0);
		TreadPanner.PanRate = 0.0;
		Skins[0] = TreadPanner;
	}

}

simulated function DestroyTreads()
{
	if ( TreadPanner != None )
	{
		Level.ObjectPool.FreeObject(TreadPanner);
		TreadPanner = None;
	}
}
simulated function SetRunningLightsFX()
{
 if (LeftRunningLight==none && Health>0 && Team != 255 )
          {
           LeftRunningLight = Spawn(class'FX_ArmorRunningLight',self,,Location);
           if( !AttachToBone(LeftRunningLight,'LHLight') )
		     {
			  log( "Couldn't attach LeftRunningLight to LHLight", 'Error' );
		      LeftRunningLight.Destroy();
			  return;
		     }

          RightRunningLight = Spawn(class'FX_ArmorRunningLight',self,,Location);
          if( !AttachToBone(RightRunningLight,'RHLight') )
		    {
			 log( "Couldn't attach RightRunningLight to RHLight", 'Error' );
			 RightRunningLight.Destroy();
			 return;
		    }
		  LRearRunningLight = Spawn(class'FX_ArmorRunningLight',self,,Location);
		  if( !AttachToBone(LRearRunningLight,'LRearLight') )
		    {
			 log( "Couldn't attach LRearRunningLight to LRearLight", 'Error' );
			 LRearRunningLight.Destroy();
			 return;
		    }
		  RRearRunningLight = Spawn(class'FX_ArmorRunningLight',self,,Location);
		  if( !AttachToBone(RRearRunningLight,'RRearLight') )
		    {
			 log( "Couldn't attach LRearRunningLight to LRearLight", 'Error' );
			 RRearRunningLight.Destroy();
			 return;
		    }
		  LeftHeadLight = Spawn(class'FX_ArmorHeadLight',self,,Location);
           if( !AttachToBone(LeftHeadLight,'LHLight') )
		     {
			  log( "Couldn't attach LeftHeadLight to LHLight", 'Error' );
		      LeftHeadLight.Destroy();
			  return;
		     }

          RightHeadLight = Spawn(class'FX_ArmorHeadLight',self,,Location);
          if( !AttachToBone(RightHeadLight,'RHLight') )
		    {
			 log( "Couldn't attach RightHeadLight to RHLight", 'Error' );
			 RightHeadLight.Destroy();
			 return;
		    }

          LeftRunningLight.SetRelativeLocation(LeftRunningLightOffset);
	      RightRunningLight.SetRelativeLocation(RightRunningLightOffset);
		  LRearRunningLight.SetRelativeLocation(RearRunningLightOffset);
          LeftHeadLight.SetRelativeLocation(LeftHLightOffset);
          RightHeadLight.SetRelativeLocation(RightHLightOffset);
         }

       if (LeftRunningLight!=none)
          {
           if ( Team == 1 || (Controller!=none && controller.PlayerReplicationInfo.Team.TeamIndex==1) )	// Blue version
			   {
				LeftRunningLight.SetBlueColor();
                RightRunningLight.SetBlueColor();
                LRearRunningLight.SetBlueColor();
                RRearRunningLight.SetBlueColor();
               }
          }
}
simulated event DrivingStatusChanged()
{
    Super.DrivingStatusChanged();

    if (!bDriving)
    {
        if ( TreadPanner != None )
            TreadPanner.PanRate = 0.0;
    }
    	if ( Level.NetMode != NM_DedicatedServer )
	{
		SetRunningLightsFX();
	}
}

simulated event TeamChanged()
{
    Super.TeamChanged();
	// Add Trail FX
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    if (ShieldStrength>=1)
        {
         ShieldStrength -= Damage;
         if ( Role == Role_Authority )
		 DoShieldEffect(HitLocation, Normal(Location - HitLocation) );

	     PlaySound(sound'WeaponSounds.ArmorHit', SLOT_Pain,2*TransientSoundVolume,,400);
         return;
         }

	super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}


//=============================================================================
// FX
//=============================================================================

function DoShieldEffect(vector HitLocation, vector HitNormal)
{
	local Actor ShieldEffect;

	if ( Team > 1 )
		return;

	if ( EffectIsRelevant(HitLocation, true) && NextShieldTime < Level.TimeSeconds )
	{
		NextShieldTime = Level.TimeSeconds + 0.1;
		ShieldEffect = Spawn(GenericShieldEffect[Team], Self,, HitLocation, rotator(-HitNormal));

		if ( ShieldEffect != None )
			ShieldEffect.SetBase( Self );
	}
}
function int ShieldAbsorb( int damage )
{
	local int Interval;

    if (ShieldStrength == 0)
    {
        return damage;
    }
	if ( ShieldStrength > 100 )
    {
		Interval = ShieldStrength - 100;
		if ( Interval >= damage )
		{
			ShieldStrength -= damage;
			return 0;
		}
		else
		{
			ShieldStrength = 100;
			damage -= Interval;
		}
	}
    if ( ShieldStrength > SmallShieldStrength )
    {
		Interval = ShieldStrength - SmallShieldStrength;

		if ( Interval >= 0.75 * damage )
		{
			ShieldStrength -= 0.75 * damage;
			if ( ShieldStrength < SmallShieldStrength )
				SmallShieldStrength = ShieldStrength;
			return (0.25 * damage);
		}
		else
		{
			ShieldStrength = SmallShieldStrength;
			damage -= 0.75 * Interval;
		}
	}
	if ( ShieldStrength >= 0.5 * damage )
	{
		ShieldStrength -= 0.5 * damage;
		SmallShieldStrength = ShieldStrength;
		return (0.5 * damage);
	}
	else
	{
		damage -= ShieldStrength;
		ShieldStrength = 0;
		SmallShieldStrength = 0;
	}
	return damage;
}
// ----- shield control ----- //
function float GetShieldStrengthMax()
{
    return ShieldStrengthMax;
}

function float GetShieldStrength()
{
    // could return max if it's active right now, which make it unable to be recharged while it's on...
    return ShieldStrength;
}

function int CanUseShield(int ShieldAmount)
{
	ShieldStrength = Max(ShieldStrength,0);
	if ( ShieldStrength < ShieldStrengthMax )
	{
		if ( ShieldAmount == 50 )
			ShieldAmount = 50 - SmallShieldStrength;
		return (Min(ShieldStrengthMax, ShieldStrength + ShieldAmount) - ShieldStrength);
	}
    return 0;
}

function bool AddShieldStrength(int ShieldAmount)
{
	local int OldShieldStrength;

	OldShieldStrength = ShieldStrength;
	ShieldStrength += CanUseShield(ShieldAmount);
	if ( ShieldAmount == 50 )
		SmallShieldStrength = 50;
	return (ShieldStrength != OldShieldStrength);
}

simulated function Tick(float DeltaTime)
{
    local float EnginePitch;
	local float LinTurnSpeed;
    local KRigidBodyState BodyState;
    local rotator TreadDir;
    TreadDir.Pitch=16768;
    EnginePitch = 64.0 + VSize(Velocity)/MaxPitchSpeed * 64.0;
    SoundPitch = FClamp(EnginePitch, 64, 128);

    KGetRigidBodyState(BodyState);
	LinTurnSpeed = 0.5 * BodyState.AngVel.Z;

    if ( TreadPanner != None )
    {
		TreadPanner.PanRate = VSize(Velocity) / TreadVelocityScale;
		if (Velocity Dot Vector(Rotation) > 0)
			TreadPanner.PanRate = -1 * TreadPanner.PanRate;
			TreadPanner.PanDirection=TreadDir;
		TreadPanner.PanRate += LinTurnSpeed;
    }

    if ( TreadPanner != None )
    {
		TreadPanner.PanRate = VSize(Velocity) / TreadVelocityScale;
		if (Velocity Dot Vector(Rotation) > 0)
			TreadPanner.PanRate = -1 * TreadPanner.PanRate;
			TreadPanner.PanDirection=TreadDir;

		TreadPanner.PanRate -= LinTurnSpeed;
    }


    Super.Tick( DeltaTime );
}


function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoomWithMax(0.5);
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

defaultproperties
{
     MaxPitchSpeed=700.000000
     TreadVelocityScale=100.000000
     LeftRunningLightOffset=(X=0.150000,Y=0.500000,Z=-0.130000)
     RightRunningLightOffset=(X=0.150000,Y=-0.300000,Z=-0.150000)
     LeftHLightOffset=(X=0.150000,Y=-0.500000,Z=-0.130000)
     RightHLightOffset=(X=0.150000,Y=0.300000,Z=-0.150000)
     GenericShieldEffect(0)=Class'UT2k4AssaultFull.FX_SpaceFighter_Shield_Red'
     GenericShieldEffect(1)=Class'UT2k4AssaultFull.FX_SpaceFighter_Shield'
     ShieldStrengthMax=10000.000000
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
     HoverCheckDist=110.000000
     UprightStiffness=500.000000
     UprightDamping=300.000000
     MaxThrust=100.000000
     MaxSteerTorque=100.000000
     ForwardDampFactor=0.100000
     LateralDampFactor=0.500000
     ParkingDampFactor=0.800000
     SteerDampFactor=100.000000
     InvertSteeringThrottleThreshold=-0.100000
     DriverWeapons(0)=(WeaponClass=Class'CSAdvancedArmor.ONSArmadilloTurret',WeaponBone="WeapAttach")
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSAdvancedArmor.ONSArmadilloRearGunPawn',WeaponBone="PassA")
     PassengerWeapons(1)=(WeaponPawnClass=Class'CSAdvancedArmor.ONSArmadilloPassengerPawn',WeaponBone="PassB")
     PassengerWeapons(2)=(WeaponPawnClass=Class'CSAdvancedArmor.ONSArmadilloPassengerPawn',WeaponBone="PassC")
     PassengerWeapons(3)=(WeaponPawnClass=Class'CSAdvancedArmor.ONSArmadilloPassengerPawn',WeaponBone="PassD")
     PassengerWeapons(4)=(WeaponPawnClass=Class'CSAdvancedArmor.ONSArmadilloPassengerPawn',WeaponBone="PassE")
     IdleSound=Sound'ONSVehicleSounds-S.Tank.TankEng01'
     StartUpSound=Sound'ONSVehicleSounds-S.Tank.TankStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.Tank.TankStop01'
     StartUpForce="TankStartUp"
     ShutDownForce="TankShutDown"
     ViewShakeRadius=600.000000
     ViewShakeOffsetMag=(X=0.500000,Z=2.000000)
     ViewShakeOffsetFreq=7.000000
     DestroyedVehicleMesh=StaticMesh'AdvancedArmor_ST.MissileLauncherDead'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'OnslaughtFull.ONSVehDeathMAS'
     DisintegrationHealth=0.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     DamagedEffectScale=2.500000
     DamagedEffectOffset=(Z=100.000000)
     bEnableProximityViewShake=True
     VehicleMass=12.000000
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
     FPCamPos=(X=128.000000,Z=100.000000)
     TPCamDistance=780.000000
     TPCamLookat=(X=-200.000000,Z=180.000000)
     TPCamWorldOffset=(Z=200.000000)
     TPCamDistRange=(Min=0.000000,Max=2500.000000)
     MaxViewPitch=30000
     MomentumMult=0.300000
     DriverDamageMult=0.000000
     VehiclePositionString="in a Armadillo Troop Carrier"
     VehicleNameString="Armadillo Troop Carrier 2.01"
     RanOverDamageType=Class'CSAdvancedArmor.DamType_ARMTankRoadkill'
     CrushedDamageType=Class'CSAdvancedArmor.DamType_ARMTankPancake'
     MaxDesireability=0.800000
     FlagBone="LRearLight"
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn09'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Horn02'
     bCanStrafe=True
     GroundSpeed=620.000000
     HealthMax=1450.000000
     Health=1450
     Mesh=SkeletalMesh'AdvancedArmor_anim.TroopCarrier'
     Skins(0)=Texture'PC_ConvoyTextures.Trailer.PC_TrackTread'
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
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
     End Object
     KParams=KarmaParamsRBFull'CSAdvancedArmor.ONSArmadillo.KParams0'

}
