//=============================================================================
// Min)o(taur.
//=============================================================================
class Omnitaur extends ONSHoverTank
	placeable;

defaultproperties
{
     MaxGroundSpeed=1000.000000
     MaxAirSpeed=60000.000000
     MaxThrust=20.000000
     MaxSteerTorque=30.000000
     ForwardDampFactor=0.010000
     ParkingDampFactor=0.010000
     SteerDampFactor=50.000000
     DriverWeapons(0)=(WeaponClass=Class'Omnitaur.OmnitaurCannon')
     PassengerWeapons(0)=(WeaponPawnClass=Class'Omnitaur.OmnitaurSecondaryTurretPawn')
     PassengerWeapons(1)=(WeaponPawnClass=Class'Omnitaur.OmnitaurTurretPawn',WeaponBone="MachineGunTurret")
     RedSkin=Texture'Omnitaur_Tex.OmnitaurRed'
     BlueSkin=Texture'Omnitaur_Tex.OmnitaurBlue'
     IdleSound=Sound'Minotaur_Sound.Minotaurengine'
     VehiclePositionString="in a Min)o(taur"
     VehicleNameString="Min)o(taur"
     HornSounds(0)=Sound'Minotaur_Sound.Minotaurhorn'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Dixie_Horn'
     HealthMax=2000.000000
     Health=2000
     Skins(1)=Texture'Omnitaur_Tex.OmnitaurTread'
     Skins(2)=Texture'Omnitaur_Tex.OmnitaurTread'
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull8
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
     KParams=KarmaParamsRBFull'Omnitaur.Omnitaur.KarmaParamsRBFull8'

     bSelected=True
}
