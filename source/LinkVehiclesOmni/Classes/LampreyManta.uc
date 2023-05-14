//-----------------------------------------------------------
// Hornet - air-to-air combat vehicle, designed for air combat maps. Coded by Owoc.
//-----------------------------------------------------------
class LampreyManta extends ONSAttackCraft


    placeable;

#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

var bool bLinking;
var int Links;



replication
{
    unreliable if (Role == ROLE_Authority)
        bLinking;
}



simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    ViewActor = self;

    CameraLocation = Location + (FPCamPos >> Rotation);
}



defaultproperties
{
	   bDrawMeshInFP=False
		 bCanFly = True
		 bFollowLookDir=True
     bCanHover=True
     bPCRelativeFPRotation=False
     MaxPitchSpeed=1800.000000
     TrailEffectPositions(0)=(X=-82.000000,Y=-24.000000,Z=40.000000)
     TrailEffectPositions(1)=(X=-82.000000,Y=24.000000,Z=40.000000)
     StreamerEffectOffset(0)=(X=-20.000000,Y=-28.000000,Z=-28.000000)
     StreamerEffectOffset(1)=(X=-20.000000,Y=28.000000,Z=-28.000000)
     StreamerEffectOffset(2)=(Y=-56.000000,Z=-16.000000)
     StreamerEffectOffset(3)=(Y=56.000000,Z=-16.000000)
     DriverWeapons(0)=(WeaponClass=Class'LampreyGun',WeaponBone="PlasmaGunAttachment")
     
     RedSkin=Shader'LinkTank3Tex.Lamprey.LampreyChassisRED'
     BlueSkin=Shader'LinkTank3Tex.Lamprey.LampreyChassisBLUE'
     IdleSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeEng02'
     StartUpSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeStop01'
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.HoverBikeDead'
     DestructionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathHoverBike'
     DestructionLinearMomentum=(Min=62000.000000,Max=100000.000000)
     DestructionAngularMomentum=(Min=25.000000,Max=75.000000)
     bDrawDriverInTP=True
     bTurnInPlace=True
     DrivePos=(X=-18.438000,Z=60.000000)
     FPCamPos=(Z=50.000000)
     TPCamDistance=500.000000
     TPCamLookat=(X=0.000000,Z=80.000000)
     TPCamWorldOffset=(Z=160.000000)
     
     
     
     DriverDamageMult=0.000000
     VehiclePositionString="in a Lamprey 3.0"
     VehicleNameString="Lamprey Manta"
     GroundSpeed=1800.000000
     HealthMax=375.000000
     Health=300
     Mesh=SkeletalMesh'ONSVehicles-A.HoverBike'
     
     
     CollisionRadius=150.000000
     CollisionHeight=100.000000
     
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
     KParams=KarmaParamsRBFull'LinkVehiclesOmni.LampreyManta.KParams0'

}
