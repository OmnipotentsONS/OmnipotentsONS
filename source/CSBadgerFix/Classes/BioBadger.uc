//=============================================================================
// BioBadger.
//=============================================================================
class BioBadger extends MyBadger;

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

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
    /*
	if (ClassIsChildOf(DamageType,class'BiotankKill'))
		return;

	if (ClassIsChildOf(DamageType,class'BioBeam'))
		return;

	if (ClassIsChildOf(DamageType,class'DamTypeBioGlob'))
		return;
        */

    if(class'BioHandler'.static.IsBioDamage(DamageType))
        return;

	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

defaultproperties
{
     GearRatios(0)=-0.600000
     GearRatios(2)=0.800000
     GearRatios(3)=1.000000
     GearRatios(4)=1.200000
     DriverWeapons(0)=(WeaponClass=Class'CSBadgerFix.BioBadgerBeamTurret')
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSBadgerFix.BioBadgerTurretPawn')
     RedSkin=Texture'MoreBadgers.BioBadger.BioBadgerRed'
     BlueSkin=Texture'MoreBadgers.BioBadger.BioBadgerBlue'
     DestroyedVehicleMesh=StaticMesh'Badger_SM.Wreck.BadgerWreck_Hull'
     Begin Object Class=SVehicleWheel Name=SVehicleWheel8
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightRearSTRUT"
     End Object
     Wheels(0)=SVehicleWheel'CSBadgerFix.SVehicleWheel8'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel9
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftRearSTRUT"
     End Object
     Wheels(1)=SVehicleWheel'CSBadgerFix.SVehicleWheel9'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel10
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightFrontSTRUT"
     End Object
     Wheels(2)=SVehicleWheel'CSBadgerFix.SVehicleWheel10'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel11
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftFrontSTRUT"
     End Object
     Wheels(3)=SVehicleWheel'CSBadgerFix.SVehicleWheel11'

     VehiclePositionString="in a BioBadger"
     VehicleNameString="BioBadger"
     HornSounds(0)=Sound'BioAegis_Sound.BioTank.BioTankHorn0'
     HealthMax=700.000000
     Health=700
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull5
         KInertiaTensor(0)=1.300000
         KInertiaTensor(3)=4.000000
         KInertiaTensor(5)=4.500000
         KLinearDamping=0.150000
         KAngularDamping=0.000000
         KStartEnabled=True
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
         bKNonSphericalInertia=True
     End Object
     KParams=KarmaParamsRBFull'CSBadgerFix.KarmaParamsRBFull5'

}
