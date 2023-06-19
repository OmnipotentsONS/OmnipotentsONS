//-----------------------------------------------------------
//	Human Viper Speedboat
//	Colt Wohlers (aka CMan)
//	Beta 4.0 (July 2/2004)
//       Aditional Help: Mr-Slate (much coding help, and additions)
//                     : Offspringy (Model and textures, human viper)
//-----------------------------------------------------------

class HumanViper extends SkaarjViper
    placeable;

defaultproperties
{
     TrailEffectPositions(0)=(X=-195.000000,Y=-80.000000,Z=67.000000)
     TrailEffectPositions(1)=(X=-195.000000,Y=80.000000,Z=67.000000)
     TrailEffectPositions(2)=(X=-192.000000,Y=77.000000,Z=45.000000)
     TrailEffectPositions(3)=(X=-192.000000,Y=-77.000000,Z=45.000000)
     TrailEffectPositions(4)=(X=-185.000000,Y=67.000000,Z=20.000000)
     TrailEffectPositions(5)=(X=-185.000000,Y=-67.000000,Z=20.000000)
     TrailEffectClass=Class'KopholusV2Omni.HumanViperExhaust'
     StreamerEffectOffset(0)=(X=-185.000000,Y=-144.000000,Z=55.000000)
     StreamerEffectOffset(1)=(X=-185.000000,Y=144.000000,Z=55.000000)
     StreamerEffectOffset(2)=(X=-198.000000,Y=-58.000000,Z=148.100006)
     StreamerEffectOffset(3)=(X=-198.000000,Y=58.000000,Z=148.100006)
     PassengerWeapons(0)=(WeaponPawnClass=Class'KopholusV2Omni.HumanViperFrontGunPawn')
     PassengerWeapons(1)=(WeaponPawnClass=Class'KopholusV2Omni.HumanViperRearGunPawn')
     DestroyedVehicleMesh=StaticMesh'KASPvehicleSM.HumanViperSM.HViper'
     DamagedEffectOffset=(X=125.000000,Z=88.000000)
     HeadlightCoronaOffset(0)=(X=404.000000,Y=30.000000,Z=49.000000)
     HeadlightCoronaOffset(1)=(X=404.000000,Y=-30.000000,Z=49.000000)
     DrivePos=(X=-71.000000,Y=0.000000,Z=97.000000)
     ExitPositions(0)=(X=225.000000,Z=125.000000)
     ExitPositions(1)=(X=100.000000,Y=75.000000,Z=125.000000)
     ExitPositions(2)=(X=100.000000,Y=-75.000000,Z=125.000000)
     EntryPosition=(X=15.000000,Z=70.000000)
     EntryRadius=300.000000
     FPCamPos=(X=150.000000,Z=120.000000)
     TPCamDistance=850.000000
     VehiclePositionString="in a Human Viper"
     VehicleNameString="Human Viper 2.31"
     RanOverDamageType=Class'KopholusV2Omni.DamTypeHumanViperRoadkill'
     CrushedDamageType=Class'KopholusV2Omni.DamTypeHumanViperPancake'
     Mesh=SkeletalMesh'KASPvehicles.HumanViper'
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KBuoyancy=1.500000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KActorGravScale=1.500000
         KMaxSpeed=3000.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=4.000000
         KImpactThreshold=300.000000
     End Object
     KParams=KarmaParamsRBFull'KopholusV2Omni.HumanViper.KParams0'

		HealthMax=825
		Health=825
		
		CollisionRadius=225.000000
    CollisionHeight=80.000000
}

