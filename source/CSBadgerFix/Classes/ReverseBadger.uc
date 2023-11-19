//=============================================================================
// ReverseBadger.
//=============================================================================
class ReverseBadger extends MyBadger;

function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoom();
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if (!bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	PC.StopZoom();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}

defaultproperties
{
     GearRatios(4)=1.300000
     DaredevilThreshInAirTime=1.200000
     DriverWeapons(0)=(WeaponClass=Class'CSBadgerFix.ReverseBadgerTurret',WeaponBone="TurretSpawn")
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSBadgerFix.BadgerMinigunPawn',WeaponBone="MinigunSpawn")
     bHasAltFire=False
     RedSkin=Texture'MoreBadgers.ReverseBadger.regdaBRed'
     BlueSkin=Texture'MoreBadgers.ReverseBadger.regdaBBlue'
     Begin Object Class=SVehicleWheel Name=SVehicleWheel20
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightRearSTRUT"
     End Object
     Wheels(0)=SVehicleWheel'CSBadgerFix.SVehicleWheel20'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel21
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftRearSTRUT"
     End Object
     Wheels(1)=SVehicleWheel'CSBadgerFix.SVehicleWheel21'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel22
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightFrontSTRUT"
     End Object
     Wheels(2)=SVehicleWheel'CSBadgerFix.SVehicleWheel22'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel23
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftFrontSTRUT"
     End Object
     Wheels(3)=SVehicleWheel'CSBadgerFix.SVehicleWheel23'

     VehiclePositionString="regdaB a ni"
     VehicleNameString="regdaB"
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull1
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
     KParams=KarmaParamsRBFull'CSBadgerFix.KarmaParamsRBFull1'

}
