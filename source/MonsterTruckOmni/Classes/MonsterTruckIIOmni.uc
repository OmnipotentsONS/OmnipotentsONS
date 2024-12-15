//-----------------------------------------------------------
//   Monster Truck II
//-----------------------------------------------------------
class MonsterTruckIIOmni extends MTII;
// this depends on MTII.u original MonsterTruck
// 
// these are embedded in the original package
//exec LOAD OBJ FILE=forcompile\MTB.ukx PACKAGE=MTII
//#exec OBJ LOAD FILE=forcompile\MTBtex.utx PACKAGE=MTII
//#exec OBJ LOAD FILE=forcompile\MTBSounds.uax PACKAGE=MTII
////////////////////////////////////////////////////////

defaultproperties
{
	// Mostly these are defaults except the weapons which needed tweaked.
	// Might tweak some of the driveability later.
     RedSkin1=Texture'MTII.MTRed'
     BlueSkin1=Texture'MTII.MTBlue'
     GutBlowALocation=(X=101.970001,Z=-6.910000)
     GutBlowAEffect=Class'MTII.SBXMPGutBlowFX'
     GutBlowBEffect=Class'MTII.SBXMP_Rapt_GutblowFX'
     WheelSoftness=0.025000
     WheelPenScale=1.200000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=1.100000
     WheelLatFrictionScale=1.350000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=42.000000
     WheelSuspensionMaxRenderTravel=42.000000
     FTScale=0.030000
     ChassisTorqueScale=0.400000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=25.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=1000000000.000000,OutVal=11.000000)))
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=2800.000000)))
     GearRatios(0)=-0.500000
     GearRatios(1)=0.400000
     GearRatios(2)=0.650000
     GearRatios(3)=0.850000
     GearRatios(4)=1.100000
     TransRatio=0.160000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=20.000000
     SteerSpeed=160.000000
     TurnDamping=35.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.050000
     IdleRPM=500.000000
     EngineRPMSoundRange=9000.000000
     SteerBoneName="SteeringWheel"
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=90.000000
     RevMeterScale=4000.000000
     bMakeBrakeLights=True
     BrakeLightOffset(0)=(X=-140.419998,Y=43.680000,Z=64.290001)
     BrakeLightOffset(1)=(X=-140.419998,Y=-43.680000,Z=64.290001)
     BrakeLightMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     DaredevilThreshInAirSpin=180.000000
     DaredevilThreshInAirTime=1.700000
     DaredevilThreshInAirDistance=21.000000
     bDoStuntInfo=True
     bAllowAirControl=True
     bAllowChargingJump=True
     bAllowBigWheels=True
     MaxJumpForce=400000.000000
     AirTurnTorque=45.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     DriverWeapons(0)=(WeaponClass=Class'MonsterTruckOmni.MTIIOMachineGun',WeaponBone="RFrontStrut")
     PassengerWeapons(0)=(WeaponPawnClass=Class'MonsterTruckOmni.MTIIORearGunPawn',WeaponBone="Attachment")
     RedSkin=Texture'MTII.MTUnderside'
     BlueSkin=Texture'MTII.MTUnderside'
     IdleSound=Sound'MTII.MTEng01'
     StartUpSound=Sound'MTII.MTStart'
     ShutDownSound=Sound'MTII.MTStop'
     StartUpForce="RVStartUp"
     DestroyedVehicleMesh=StaticMesh'ONSBP_DestroyedVehicles.SPMA.DestroyedSPMA'
     DestructionEffectClass=Class'UT2k4Assault.FX_SpaceFighter_Explosion'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathPRV'
     DisintegrationHealth=-25.000000
     DestructionLinearMomentum=(Min=200000.000000,Max=300000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectOffset=(X=60.000000,Y=10.000000,Z=10.000000)
     ImpactDamageMult=0.001000
     HeadlightCoronaOffset(0)=(X=124.430000,Y=37.139999,Z=66.459999)
     HeadlightCoronaOffset(1)=(X=124.430000,Y=-37.139999,Z=66.459999)
     HeadlightCoronaOffset(2)=(X=-18.090000,Y=21.070000,Z=106.809998)
     HeadlightCoronaOffset(3)=(X=-18.090000,Y=-21.070000,Z=106.809998)
     HeadlightCoronaOffset(4)=(X=-18.090000,Y=7.510000,Z=106.809998)
     HeadlightCoronaOffset(5)=(X=-18.090000,Y=-7.510000,Z=106.809998)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=20.000000
     HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVprojector'
     HeadlightProjectorOffset=(X=90.000000,Z=7.000000)
     HeadlightProjectorRotation=(Pitch=-1000)
     HeadlightProjectorScale=0.300000
     Begin Object Class=SVehicleWheel Name=RRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="tire02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=40.000000
         SupportBoneName="RrearStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(0)=SVehicleWheel'MonsterTruckOmni.MonsterTruckIIOmni.RRWheel'

     Begin Object Class=SVehicleWheel Name=LRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="tire04"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=-7.000000)
         WheelRadius=40.000000
         SupportBoneName="LrearStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(1)=SVehicleWheel'MonsterTruckOmni.MonsterTruckIIOmni.LRWheel'

     Begin Object Class=SVehicleWheel Name=RFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="tire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=40.000000
         SupportBoneName="RFrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(2)=SVehicleWheel'MonsterTruckOmni.MonsterTruckIIOmni.RFWheel'

     Begin Object Class=SVehicleWheel Name=LFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="tire03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=-7.000000)
         WheelRadius=40.000000
         SupportBoneName="LfrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(3)=SVehicleWheel'MonsterTruckOmni.MonsterTruckIIOmni.LFWheel'

     VehicleMass=5.000000
     bDrawDriverInTP=True
     bCanDoTrickJumps=True
     bDrawMeshInFP=True
     bHasHandbrake=True
     bSeparateTurretFocus=True
     bDriverHoldsFlag=False
     DrivePos=(X=15.000000,Y=-20.000000,Z=102.599998)
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryRadius=200.000000
     FPCamPos=(Y=-20.000000,Z=82.599998)
     TPCamDistance=400.000000
     CenterSpringForce="SpringONSSRV"
     TPCamLookat=(X=10.000000)
     TPCamWorldOffset=(Z=100.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in the SuperBeast"
     VehicleNameString="SuperBeast )o( 2.00"
     RanOverDamageType=Class'MonsterTruckOmni.DamTypeMTIIORoadkill'
     CrushedDamageType=Class'MonsterTruckOmni.DamTypeMTIIOPancake'
     MaxDesireability=0.400000
     ObjectiveGetOutDist=1500.000000
     FlagBone="RVchassis"
     FlagOffset=(Z=130.000000)
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'MTII.SuperbeastHorn'
     HornSounds(1)=Sound'MTII.SuperbeastHorn'
     GroundSpeed=940.000000
     HealthMax=600.000000
     Health=600
     bReplicateAnimations=True
     Mesh=SkeletalMesh'MTII.MTB'
     Skins(0)=Texture'MTII.MTUnderside'
     Skins(2)=Shader'MTII.MTIIGlass'
     Skins(3)=Texture'MTII.MTSusp'
     Skins(4)=Texture'MTII.MTWheel'
     AmbientGlow=2
     bShadowCast=True
     SoundVolume=180
     CollisionRadius=100.000000
     CollisionHeight=40.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.500000
         KInertiaTensor(3)=3.500000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.250000,Z=-0.400000)
         KLinearDamping=0.050000
         KAngularDamping=0.10000
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
         StayUprightStiffness=75
     End Object
     KParams=KarmaParamsRBFull'MonsterTruckOmni.MonsterTruckIIOmni.KParams0'

}
