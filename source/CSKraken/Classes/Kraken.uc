//=============================================================================
// Kraken
//=============================================================================
class Kraken extends ONSMobileAssaultStation
	placeable;

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{

        if (DamageType == class'DamTypeBioGlob')
                Damage *= 3.00;

	if (DamageType == class'DamTypeTankShell')
		Damage *= 0.70;

	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.50;

	if (DamageType == class'DamTypeONSCicadaRocket')
		Damage *= 0.50;

	if (DamageType == class'DamTypeAttackCraftPlasma')
		Damage *= 0.50;

	if (DamageType == class'DamTypeFlakChunk')
		Damage *= 0.70;

	if (DamageType == class'DamTypeShockBeam')
		Damage *= 0.50;

        Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    // no stupid roll
    if(Abs(PC.ShakeRot.Pitch) >= 16384)
    {
        PC.bEnableAmbientShake = false;
        PC.StopViewShaking();
        PC.ShakeOffset = vect(0,0,0);
        PC.ShakeRot = rot(0,0,0);
    }

    super.SpecialCalcBehindView(PC, ViewActor, CameraLocation, CameraRotation);
}


defaultproperties
{
     WheelAdhesion=20.000000
     DriverWeapons(0)=(WeaponClass=Class'CSKraken.KrakenRocketPack')
     DriverWeapons(1)=(WeaponClass=Class'CSKraken.KrakenMainCannon')
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSKraken.KrakenMissileGunPawn')
     PassengerWeapons(1)=(WeaponPawnClass=Class'CSKraken.KrakenLaserGunPawn')
     PassengerWeapons(2)=(WeaponPawnClass=Class'CSKraken.KrakenBeamGunPawn')
     PassengerWeapons(3)=(WeaponPawnClass=Class'CSKraken.KrakenFlakGunPawn')
     RedSkin=Texture'DevilsArsenal_Tex.Kraken.KrakenRed'
     BlueSkin=Texture'DevilsArsenal_Tex.Kraken.KrakenBlue'
     Begin Object Class=SVehicleWheel Name=RightRearTIRe
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Inverted
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(0)=SVehicleWheel'CSKraken.Kraken.RightRearTIRe'

     Begin Object Class=SVehicleWheel Name=LeftRearTIRE
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Inverted
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(1)=SVehicleWheel'CSKraken.Kraken.LeftRearTIRE'

     Begin Object Class=SVehicleWheel Name=RightFrontTIRE
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(2)=SVehicleWheel'CSKraken.Kraken.RightFrontTIRE'

     Begin Object Class=SVehicleWheel Name=LeftFrontTIRE
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(3)=SVehicleWheel'CSKraken.Kraken.LeftFrontTIRE'

     bPCRelativeFPRotation=False
     TPCamDistance=245.400574
     VehiclePositionString="in a Kraken"
     VehicleNameString="Kraken"
     HealthMax=10000.000000
     Health=10000
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull1
         KInertiaTensor(0)=1.260000
         KInertiaTensor(3)=3.099998
         KInertiaTensor(5)=4.499996
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KMaxSpeed=650.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=500.000000
     End Object
     KParams=KarmaParamsRBFull'CSKraken.Kraken.KarmaParamsRBFull1'

     bSelected=True
}
