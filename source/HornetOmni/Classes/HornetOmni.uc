//-----------------------------------------------------------
// Hornet - air-to-air combat vehicle, designed for air combat maps. Coded by Owoc.
//-----------------------------------------------------------
class HornetOmni extends ONSAttackCraft
    placeable;

#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

defaultproperties
{
     MaxPitchSpeed=1800.000000
     TrailEffectPositions(0)=(X=-82.000000,Y=-24.000000,Z=40.000000)
     TrailEffectPositions(1)=(X=-82.000000,Y=24.000000,Z=40.000000)
     StreamerEffectOffset(0)=(X=-20.000000,Y=-28.000000,Z=-28.000000)
     StreamerEffectOffset(1)=(X=-20.000000,Y=28.000000,Z=-28.000000)
     StreamerEffectOffset(2)=(Y=-56.000000,Z=-16.000000)
     StreamerEffectOffset(3)=(Y=56.000000,Z=-16.000000)
     DriverWeapons(0)=(WeaponClass=Class'HornetOmni.HornetOmniGun')
     RedSkin=Texture'HornetOmni_Tex.HornetRed'
     BlueSkin=Texture'HornetOmni_Tex.HornetBlue'
     IdleSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeEng02'
     StartUpSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeStop01'
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.HoverBikeDead'
     DestructionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathHoverBike'
     DestructionLinearMomentum=(Min=62000.000000,Max=100000.000000)
     DestructionAngularMomentum=(Min=25.000000,Max=75.000000)
     bDrawDriverInTP=True
     DrivePos=(X=-18.438000,Z=60.000000)
     DriverDamageMult=0.350000
     VehiclePositionString="in a Hornet"
     VehicleNameString="Omni Hornet 1.0"
     GroundSpeed=1800.000000
     HealthMax=325.000000
     Health=325
     Mesh=SkeletalMesh'ONSVehicles-A.HoverBike'
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
     KParams=KarmaParamsRBFull'HornetOmni.HornetOmni.KParams0'

}
