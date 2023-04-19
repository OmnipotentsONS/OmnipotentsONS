//=============================================================================
// FlyingSaucer.
//=============================================================================
class CSFlyingSaucer extends ONSAttackCraft
	placeable;


#exec AUDIO IMPORT File=Sounds\drwho2.wav 
#exec AUDIO IMPORT File=Sounds\closeencounters.wav 

simulated function PostBeginPlay()
{
    TrailEffectPositions.Length=0;
    StreamerEffectOffset.Length=0;
    super.PostBeginPlay();
}

defaultproperties
{
	HornSounds(0)=sound'CSMarvin.closeencounters'
	HornSounds(1)=sound'CSMarvin.drwho2'

     MaxThrustForce=300.000000
     MaxStrafeForce=300.000000
     MaxRiseForce=200.000000
     UpDamping=0.200000
     TurnTorqueMax=300.000000
     PitchDamping=200.000000
     DriverWeapons(0)=(WeaponClass=Class'CSMarvin.SaucerGun')
     RedSkin=Shader'CSMarvin.ShipShaderRed'
     BlueSkin=Shader'CSMarvin.ShipShaderBlue'
     IdleSound=Sound'GeneralAmbience.texture23'
     StartUpSound=Sound'CSMarvin.EngineStart'
     ShutDownSound=Sound'CSMarvin.EngineStop'
     DestroyedVehicleMesh=StaticMesh'CSMarvin.EdWoodSmashed'
     DisintegrationEffectClass=Class'XEffects.NewExplosionC'
     DamagedEffectOffset=(Z=16.000000)
     HeadlightCoronaMaterial=None
     bDrawDriverInTP=True
     DrivePos=(X=-10.000000,Z=60.000000)
     ExitPositions(0)=(Y=0.000000,Z=250.000000)
     ExitPositions(1)=(Y=0.000000,Z=250.000000)
     EntryRadius=300.000000
     FPCamPos=(Z=50.000000)
     TPCamWorldOffset=(Z=130.000000)
     VehiclePositionString="in a Flying Saucer"
     VehicleNameString="Flying Saucer 2.5"
     AirSpeed=800.000000
     AccelRate=2800.000000
     AirControl=0.300000
     Mesh=SkeletalMesh'CSMarvin.EdWood'
     bShadowCast=True
     Mass=0.000000
     Buoyancy=1.000000
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull1
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.250000)
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KActorGravScale=0.000000
         //KMaxSpeed=5000.000000
         //KMaxSpeed=4000.000000
         KMaxSpeed=2600.000000
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
     KParams=KarmaParamsRBFull'CSMarvin.KarmaParamsRBFull1'

     bSelected=True
}
