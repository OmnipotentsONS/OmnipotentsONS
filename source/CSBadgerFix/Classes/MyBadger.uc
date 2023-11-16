//=============================================================================
// MyBadger.
//=============================================================================
class MyBadger extends Badger;

// Let bots drive these solo, no matter what
function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	return Super(ONSWheeledCraft).BotDesireability(S, TeamIndex, Objective);
}

defaultproperties
{
     Begin Object Class=SVehicleWheel Name=SVehicleWheel36
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightRearSTRUT"
     End Object
     Wheels(0)=SVehicleWheel'CSBadgerFix.SVehicleWheel36'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel37
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftRearSTRUT"
     End Object
     Wheels(1)=SVehicleWheel'CSBadgerFix.SVehicleWheel37'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel38
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightFrontSTRUT"
     End Object
     Wheels(2)=SVehicleWheel'CSBadgerFix.SVehicleWheel38'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel39
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftFrontSTRUT"
     End Object
     Wheels(3)=SVehicleWheel'CSBadgerFix.SVehicleWheel39'

     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull3
         KInertiaTensor(0)=1.300000
         KInertiaTensor(3)=4.000000
         KInertiaTensor(5)=4.500000
         KLinearDamping=0.150000
         KAngularDamping=0.000000
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
         KCOMOffset=(X=0.0,Y=0.0,Z=-1.35)        
     End Object
     KParams=KarmaParamsRBFull'CSBadgerFix.KarmaParamsRBFull3'

}
