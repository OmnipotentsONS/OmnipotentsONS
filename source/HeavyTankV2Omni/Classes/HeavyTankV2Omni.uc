//-----------------------------------------------------------
//
//-----------------------------------------------------------
//class HeavyTankV2Omni extends ONSTreadCraft;
class HeavyTankV2Omni extends ONSHoverTank;

#exec OBJ LOAD FILE=..\Animations\ONSVehicles-A.ukx
#exec OBJ LOAD FILE=..\Sounds\ONSVehicleSounds-S.uax
#exec OBJ LOAD FILE=InterfaceContent.utx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

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

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{

if (DamageType == class'DamTypeBioGlob')
     Damage *= 2.5;

	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.70;

	if (DamageType == class'DamTypeONSCicadaRocket')
		Damage *= 0.70;

	if (DamageType == class'DamTypeAttackCraftPlasma')
		Damage *= 0.70;

	//if (ClassIsChildOf(DamageType,class'DamTypeAirPower'))
	if (DamageType.name == 'AuroraLaser' || DamageType.name == 'WaspFlak')
		Damage *= 0.70;

	//if (DamageType == class'FireKill')
	if (DamageType.name == 'FireKill')
		Damage *= 0.65;

	//if (DamageType == class'AlligatorFlak')
	if (DamageType.name == 'AlligatorFlak' || DamageType.name == 'DamTypeFlakChunk')
		Damage *= 0.65;

	if (DamageType == class'DamTypeShockBeam')
		Damage *= 0.75;

if (DamageType.name == 'Minotaurkill')
		Damage *= 0.50;

if (DamageType.name == 'Omnitaurkill')
		Damage *= 0.50;

if (DamageType == class'Onslaught.ONSRocketProjectile')
		Damage *= 0.50;

if (DamageType.name == 'IonCore' || DamageType.name == 'RedeemerExplosion')
		Damage *= 0.50;


    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	ReduceShake();
}


function bool ImportantVehicle()
{
	return true;
}
function bool RecommendLongRangedAttack()
{
	return true;
}
function ShouldTargetMissile(Projectile P)
{
	if ( (WeaponPawns.Length > 0) && (WeaponPawns[0].Controller == None) )
		Super.ShouldTargetMissile(P);
}

defaultproperties
{
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
     DriverWeapons(0)=(WeaponClass=Class'HeavyTankV2Omni.HeavyTankCannon',WeaponBone="TankCannonWeapon")
     
     PassengerWeapons(0)=(WeaponPawnClass=Class'HeavyTankV2Omni.HeavyTankTurretPawn')  // zoomable single shock 
     PassengerWeapons(1)=(WeaponPawnClass=Class'HeavyTankV2Omni.HeavyTankSecondaryPawn',WeaponBone="MachineGunTurret")
     // Flak Drone/missle
     bHasAltFire=False
     //RedSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalRED'
     //BlueSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalBLUE'
     RedSkin=Texture'HeavyTankTex.HeavyTankRed'
     BlueSkin=Texture'HeavyTankTex.HeavyTankBlue'
     IdleSound=Sound'ONSVehicleSounds-S.Tank.TankEng01'
     StartUpSound=Sound'ONSVehicleSounds-S.Tank.TankStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.Tank.TankStop01'
     StartUpForce="TankStartUp"
     ShutDownForce="TankShutDown"
     ViewShakeRadius=600.000000
     ViewShakeOffsetMag=(X=0.500000,Z=2.000000)
     ViewShakeOffsetFreq=7.000000
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.TankDead'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'HeavyTankV2Omni.VehDeathHeavyTank'
     DisintegrationHealth=-125.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     DamagedEffectScale=1.500000
     DamagedEffectOffset=(X=100.000000,Y=20.000000,Z=26.000000)
     bEnableProximityViewShake=True
     VehicleMass=15.000000
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
     VehiclePositionString="in a Heavy Goliath"
     VehicleNameString="Heavy Goliath 2.41"
     RanOverDamageType=Class'HeavyTankV2Omni.DamTypeTankRoadkill'
     CrushedDamageType=Class'HeavyTankV2Omni.DamTypeTankPancake'
     MaxDesireability=0.800000
     FlagBone="MachineGunTurret"
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.La_Cucharacha_Horn'
     HornSounds(1)=Sound'ONSVehicleSounds-S.CarAlarm.ahooga'
     bCanStrafe=True
     GroundSpeed=620.000000
     HealthMax=1650.000000
     Health=1650
     Mesh=SkeletalMesh'ONSNewTank-A.HoverTank'
     DrawScale=1.100000
     Skins(1)=Texture'VMVehicles-TX.HoverTankGroup.tankTreads'
     Skins(2)=Texture'VMVehicles-TX.HoverTankGroup.tankTreads'
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
     KParams=KarmaParamsRBFull'HeavyTankV2Omni.HeavyTankV2Omni.KParams0'

}
