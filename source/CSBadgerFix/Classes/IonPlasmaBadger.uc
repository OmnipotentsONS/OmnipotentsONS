//=============================================================================
// IonPlasmaBadger.
//=============================================================================
class IonPlasmaBadger extends MyBadger;

simulated function PostNetBeginPlay()
{
    PassengerWeapons.Length = 0;
    super.PostNetBeginPlay();
}

function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoomWithMax(0.5);
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

static function StaticPrecache(LevelInfo L)
{
        Default.PassengerWeapons.Length = 0;
        super.StaticPrecache(L);
}

defaultproperties
{
     GearRatios(0)=-0.500000
     GearRatios(2)=0.800000
     GearRatios(3)=1.000000
     GearRatios(4)=1.100000
     DaredevilThreshInAirTime=1.200000
     DriverWeapons(0)=(WeaponClass=Class'CSBadgerFix.IonPlasmaBadgerWeapon',WeaponBone="TurretSpawn")
    //PassengerWeapons(0)=(WeaponPawnClass=None,WeaponBone=None)
    PassengerWeapons(0)=(WeaponPawnClass=Class'CSBadgerFix.BadgerMinigun',WeaponBone="MinigunSpawn")

     bHasAltFire=False
     RedSkin=Shader'MoreBadgers.IonBadger.IonBadgerRedShader'
     BlueSkin=Shader'MoreBadgers.IonBadger.IonBadgerBlueShader'
     Begin Object Class=SVehicleWheel Name=SVehicleWheel4
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightRearSTRUT"
     End Object
     Wheels(0)=SVehicleWheel'CSBadgerFix.SVehicleWheel4'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel5
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftRearSTRUT"
     End Object
     Wheels(1)=SVehicleWheel'CSBadgerFix.SVehicleWheel5'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel6
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightFrontSTRUT"
     End Object
     Wheels(2)=SVehicleWheel'CSBadgerFix.SVehicleWheel6'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel7
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftFrontSTRUT"
     End Object
     Wheels(3)=SVehicleWheel'CSBadgerFix.SVehicleWheel7'

     VehiclePositionString="in an Ion Plasma Badger"
     VehicleNameString="Ion Plasma Badger"
     HealthMax=700.000000
     Health=700
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull16
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
         KCOMOffset=(X=0.0,Y=0.0,Z=-1.0)        
     End Object
     KParams=KarmaParamsRBFull'CSBadgerFix.KarmaParamsRBFull16'

}
