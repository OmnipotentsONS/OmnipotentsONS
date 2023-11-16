//=============================================================================
// FireBadger.
//=============================================================================
class FireBadger extends MyBadger;		

defaultproperties
{
     GearRatios(0)=-0.600000
     GearRatios(2)=0.800000
     GearRatios(3)=1.000000
     GearRatios(4)=1.200000
     DriverWeapons(0)=(WeaponClass=Class'CSBadgerFix.FireBadgerLaserTurret')
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSBadgerFix.FireBadgerTurretPawn')
     RedSkin=Texture'MoreBadgers.FireBadger.FireBadgerRed'
     BlueSkin=Texture'MoreBadgers.FireBadger.FireBadgerBlue'
     Begin Object Class=SVehicleWheel Name=SVehicleWheel52
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightRearSTRUT"
     End Object
     Wheels(0)=SVehicleWheel'CSBadgerFix.SVehicleWheel52'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel53
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftRearSTRUT"
     End Object
     Wheels(1)=SVehicleWheel'CSBadgerFix.SVehicleWheel53'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel54
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightFrontSTRUT"
     End Object
     Wheels(2)=SVehicleWheel'CSBadgerFix.SVehicleWheel54'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel55
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftFrontSTRUT"
     End Object
     Wheels(3)=SVehicleWheel'CSBadgerFix.SVehicleWheel55'

     VehiclePositionString="in a Fire Badger"
     VehicleNameString="Fire Badger"
     HornSounds(0)=Sound'BioAegis_Sound.BioTank.BioTankHorn1'
     HealthMax=700.000000
     Health=700
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull6
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
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
         KCOMOffset=(X=0.0,Y=0.0,Z=-1.35)        
     End Object
     KParams=KarmaParamsRBFull'CSBadgerFix.KarmaParamsRBFull6'

}
