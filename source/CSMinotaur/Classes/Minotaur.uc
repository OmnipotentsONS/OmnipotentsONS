class Minotaur extends ONSHoverTank
	placeable;

#exec OBJ LOAD FILE=..\textures\Omnitaur_Tex.utx
#exec OBJ LOAD FILE=..\Sounds\CuddlyArmor_Sound.uax

replication
{
	reliable if (Role == ROLE_Authority)
		ReduceShake;
}


simulated function ReduceShake()
{
	local float ShakeScaling;
	local PlayerController Player;

	if (Controller == None || PlayerController(Controller) == None)
		return;

	Player = PlayerController(Controller);
	ShakeScaling = VSize(Player.ShakeRotMax) / 7500;

	if (ShakeScaling > 1)
	{
		Player.ShakeRotMax /= ShakeScaling;
		Player.ShakeRotTime /= ShakeScaling;
		Player.ShakeOffsetMax /= ShakeScaling;
	}
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
   if (class'BioHandler'.static.IsBioDamage(DamageType)) Damage *= 5.0;
   if (DamageType.name == 'TurtleDamTypeProximityExplosion')  Damage *= 1.55;
   //if (DamageType == class'DamTypeBioGlob' || DamageType,name="DamTypeBioGlobVehicle") Damage *= 5.0;
   
 /* Remove Silly non sensical resistances
	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.70;

	if (DamageType == class'DamTypeONSCicadaRocket')
		Damage *= 0.70;

	if (DamageType == class'DamTypeAttackCraftPlasma')
		Damage *= 0.70;

	//if (ClassIsChildOf(DamageType,class'DamTypeAirPower'))
	if (DamageType.name == 'AuroraLaser' || DamageType.name == 'WaspFlak')
		Damage *= 0.70;

	//if (DamageType == class'FireKill')
	//if (DamageType.name == 'FireKill')
	//	Damage *= 0.30;
	// Fire Res Nerf

		if (DamageType.name == 'AlligatorFlak')
		Damage *= 0.75;

	if (DamageType == class'DamTypeShockBeam')
		Damage *= 0.75;


	if (DamageType == class'MinotaurTurretkill')
		Damage *= 0.30;

	if (DamageType == class'MinotaurSecondaryTurretKill')
		Damage *= 0.30;

	//if (DamageType == class'HeatRay')
	//if (DamageType.name == 'HeatRay')
	//	Damage *= 0.30;
*/
	Momentum *= 0.00;

  Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	ReduceShake();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'Omnitaur_Tex.OmnitaurRed');
    Level.AddPrecacheMaterial(Material'Omnitaur_Tex.OmnitaurBlue');
    Level.AddPrecacheMaterial(Material'Omnitaur_Tex.OmnitaurTread');
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
     MaxGroundSpeed=1050.000000
     MaxAirSpeed=60000.000000
     MaxThrust=20.000000
     MaxSteerTorque=30.000000
     ForwardDampFactor=0.010000
     ParkingDampFactor=0.010000
     SteerDampFactor=50.000000
     DriverWeapons(0)=(WeaponClass=Class'CSMinotaur.Minotaurcannon')
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSMinotaur.MinotaurTurretPawn')
     PassengerWeapons(1)=(WeaponPawnClass=Class'CSMinotaur.MinotaurSecondaryTurretPawn',WeaponBone="MachineGunTurret")
     RedSkin=Texture'Omnitaur_Tex.OmnitaurRed'
     BlueSkin=Texture'Omnitaur_Tex.OmnitaurBlue'
     IdleSound=Sound'CuddlyArmor_Sound.Minotaur.Minotaurengine'
     bKeyVehicle=True
     VehiclePositionString="in a Min)o(taur"
     VehicleNameString="Min)o(taur"
     RanOverDamageType=Class'CSMinotaur.MinotaurDamTypeRoadkill'
     CrushedDamageType=Class'CSMinotaur.MinotaurDamTypePancake'
     HornSounds(0)=Sound'CuddlyArmor_Sound.Horns.Bighorn'
     HornSounds(1)=Sound'CuddlyArmor_Sound.Horns.Horn2'
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
     KParams=KarmaParamsRBFull'CSMinotaur.Minotaur.KarmaParamsRBFull8'

     bSelected=True
}
