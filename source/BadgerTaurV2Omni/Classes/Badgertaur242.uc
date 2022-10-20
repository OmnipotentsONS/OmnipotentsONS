//=============================================================================
// Badgertaur.
//=============================================================================
class Badgertaur242 extends MyBadger;

#exec obj load file="Animations\Badgertaur_Anim.ukx" package=BadgerTaurV2Omni
//#exec OBJ LOAD FILE=..\Animations\MoreBadgers_Anim.ukx

// Added ReduceShake to avoid spinning bug from massive damage..
// 02-23-2022 pooty
replication
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
event PostBeginPlay()
{
	Super.PostBeginPlay();
	spawn(class'MegabadgerUseTrigger', Self, , Location);
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


function bool ImportantVehicle()
{
	return true;
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
// compensate for higher mass allow momentum to push it.

if (DamageType == class'DamTypeShockBeam') {
		Damage *= 1.25;
		Momentum *= 2;  
  }

if (DamageType == class'DamTypeShockBall') {
		Damage *= 1.5;
		Momentum *= 2;  // compensate for higher mass allow shock to push it.
  }

if (DamageType == class'DamTypeShockCombo') {
		Damage *= 1.5;
		Momentum *= 4;  // compensate for higher mass allow shock to push it.
  }


  Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	ReduceShake();
}

defaultproperties
{
	// Updated per McLovin for the better driving badger
	  // TorqueCurve=(Points=((InVal=0.0,OutVal=3.000000),(InVal=200.0,OutVal=5.000000),(InVal=1200.000000,OutVal=12.000000),(InVal=1500.000000,OutVal=0.0000)))
    // the below is from the MinusBadgerMeUp-Beta23 -- using it as is crashes when summoning vehicle
    //TorqueCurve=(Points=((OutVal=3.000000),(OutVal=5.000000),(InVal=1200.000000,OutVal=12.000000),(InVal=1500.000000)))
     TorqueCurve=(Points=((InVal=0.0,OutVal=12.000000),(InVal=200.0,OutVal=16.000000),(InVal=1200.000000,OutVal=24.000000),(InVal=1500.000000,OutVal=0.0000)))
     GearRatios(0)=-0.900000
     GearRatios(3)=1.000000
     GearRatios(4)=1.300000
     SteerSpeed=40.000000
     StopThreshold=500.000000
     IdleRPM=1000.000000
     EngineRPMSoundRange=4000.000000
     BrakeLightOffset(0)=(X=-116.000000,Y=-100.000000,Z=152.000000)
     BrakeLightOffset(1)=(X=-116.000000,Y=100.000000,Z=152.000000)
     bDoStuntInfo=False
     bAllowAirControl=True // Added by pooty
     DriverWeapons(0)=(WeaponClass=Class'BadgerTaurV2Omni.BadgertaurTurret',WeaponBone="TurretSpawn")
     PassengerWeapons(0)=(WeaponPawnClass=Class'BadgerTaurV2Omni.BadgertaurLaserTurretPawn',WeaponBone="MinigunSpawn")
     bHasAltFire=False
     RedSkin=Texture'MoreBadgers.Badgertaur.BadgertaurRed'
     BlueSkin=Texture'MoreBadgers.Badgertaur.BadgertaurBlue'
     IdleSound=Sound'Minotaur_Sound.Minotaurengine'
     StartUpSound=Sound'ONSVehicleSounds-S.Tank.TankStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.Tank.TankStop01'
     HeadlightCoronaOffset(0)=(X=162.000000,Y=-30.000000,Z=116.000000)
     HeadlightCoronaOffset(1)=(X=162.000000,Y=30.000000,Z=116.000000)
     HeadlightProjectorOffset=(X=260.000000,Z=30.000000)
     HeadlightProjectorScale=1.300000
     Begin Object Class=SVehicleWheel Name=SVehicleWheel16
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=52.000000
         SupportBoneName="RightRearSTRUT"
     End Object
     Wheels(0)=SVehicleWheel'BadgerTaurV2Omni.SVehicleWheel16'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel17
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=52.000000
         SupportBoneName="LeftRearSTRUT"
     End Object
     Wheels(1)=SVehicleWheel'BadgerTaurV2Omni.SVehicleWheel17'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel18
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=52.000000
         SupportBoneName="RightFrontSTRUT"
     End Object
     Wheels(2)=SVehicleWheel'BadgerTaurV2Omni.SVehicleWheel18'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel19
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=52.000000
         SupportBoneName="LeftFrontSTRUT"
     End Object
     Wheels(3)=SVehicleWheel'BadgerTaurV2Omni.SVehicleWheel19'

     VehicleMass=12.00000
     // Doubled this only way to keep it not wobbly
     ExitPositions(0)=(X=-360.000000)
     ExitPositions(1)=(X=-360.000000,Y=-200.000000)
     ExitPositions(2)=(X=-360.000000,Y=200.000000)
     EntryPosition=(Z=-30.000000)
     EntryRadius=500.000000
     FPCamPos=(X=-40.000000,Z=320.000000)
     TPCamLookat=(Z=200.000000)
     TPCamWorldOffset=(Z=200.000000)
     VehiclePositionString="in a Megabadger"
     VehicleNameString="Megabadger 2.42"
     HornSounds(0)=Sound'Minotaur_Sound.Minotaurhorn'
     HealthMax=2000.000000
     Health=2000
//     Mesh=SkeletalMesh'MoreBadgers_Anim.BadgertaurCollision'
     Mesh=SkeletalMesh'BadgerTaurV2Omni.BadgertaurCollision'

   Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull2
         KInertiaTensor(0)=20.000
         KInertiaTensor(3)=200.000
         KInertiaTensor(5)=35.000
                
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
         // Added by Pooty to the orig mega
         bKStayUpright=True
         bKAllowRotate=False
         
         // Additional Params to play with
         KCOMOffset=(X=0.0,Y=0.0,Z=-1.0)
           // Updated Regular badger Z=-1  
         StayUprightStiffness=100.000000
         StayUprightDamping=100.000000
         
         
       
         KRestitution = 0 // appears to be undocumented, found it in UE5:
         // KRestitution 	This determines the `bouncyness' of the Karma Actor, where 0 = no bounce and 1 = incoming velocity is equal to outgoing velocity 
         // not sure if does anything??
                
         
         
         
     End Object

}
