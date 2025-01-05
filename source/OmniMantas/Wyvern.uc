class Wyvern extends ONSHoverBike
	placeable;

defaultproperties
{
     MaxPitchSpeed=1300.000000
     JumpForceMag=250.000000
     MaxThrustForce=35.000000
     MaxYawRate=2.000000
     DriverWeapons(0)=(WeaponClass=Class'OmniMantas.WyvernBeamGun')
     RedSkin=Texture'GorzBirds_Tex.Wyvern.WyvernRed'
     BlueSkin=Texture'GorzBirds_Tex.Wyvern.WyvernBlue'
     IdleSound=Sound'ONSVehicleSounds-S.Flying.Flying03'
     StartUpSound=Sound'ONSVehicleSounds-S.MAS.MASStart01'
     ShutDownSound=Sound'CicadaSnds.Flight.CicadaShutdown'
     CrossHairColor=(B=192,G=192,R=192)
     VehiclePositionString="in a Wyvern"
     VehicleNameString="Wyvern 1.01"
     RanOverDamageType=Class'OmniMantas.WyvernDamTypeRoadkill'
     CrushedDamageType=Class'OmniMantas.WyvernDamTypePancake'
     HealthMax=150.000000
     Health=150
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull1
         KInertiaTensor(0)=1.300000
         KInertiaTensor(3)=4.000000
         KInertiaTensor(5)=4.500000
         KLinearDamping=0.150000
         KAngularDamping=0.000000
         KStartEnabled=True
//         KMaxSpeed=5000.000000
         KMaxSpeed=3750.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'OmniMantas.Wyvern.KarmaParamsRBFull1'

     bSelected=True
}
