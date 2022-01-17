//=============================================================================
// Minotaur.
//=============================================================================
class MinotaurClassic extends ONSHoverTank
	placeable;

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

    if (DamageType == class'DamTypeBioGlob')
            Damage *= 3.0;

	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.70;

	if (DamageType == class'DamTypeONSCicadaRocket')
		Damage *= 0.70;

	if (DamageType == class'DamTypeAttackCraftPlasma')
		Damage *= 0.70;

	if (DamageType.name == 'AuroraLaser' || DamageType.name == 'WaspFlak')
		Damage *= 0.70;

	if (DamageType.name == 'FireKill')
		Damage *= 0.30;

	
	if (DamageType.name == 'AlligatorFlak')
		Damage *= 0.75;

	if (DamageType == class'DamTypeShockBeam')
		Damage *= 0.75;

  if (DamageType.name == 'TurtleDamTypeProximityExplosion')
      Damage *= 1.55;

	if (DamageType == class'DamTypeMinotaurClassicTurret')
		Damage *= 0.30;

	if (DamageType == class'DamTypeMinotaurClassicSecondaryTurret')
		Damage *= 0.30;

if (DamageType.name == 'OmnitaurTurretkill')
		Damage *= 0.30;

	if (DamageType.name == 'OmnitaurSecondaryTurretKill')
		Damage *= 0.30;

if (DamageType.name == 'MinotaurTurretkill')
		Damage *= 0.30;

	if (DamageType.name == 'MinotaurSecondaryTurretKill')
		Damage *= 0.30;


	if (DamageType.name == 'HeatRay')
		Damage *= 0.40;

	Momentum *= 0.00;

    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	ReduceShake();
}



defaultproperties
{
     MaxGroundSpeed=1000.000000
     MaxAirSpeed=60000.000000
     MaxThrust=20.000000
     MaxSteerTorque=30.000000
     ForwardDampFactor=0.010000
     ParkingDampFactor=0.010000
     SteerDampFactor=50.000000
     DriverWeapons(0)=(WeaponClass=Class'MinotaurClassic.MinotaurClassicCannon')
     PassengerWeapons(0)=(WeaponPawnClass=Class'MinotaurClassic.MinotaurClassicTurretPawn')
     PassengerWeapons(1)=(WeaponPawnClass=Class'MinotaurClassic.MinotaurClassicSecondaryTurretPawn',WeaponBone="MachineGunTurret")
     RedSkin=Texture'Minotaur_Tex.MinotaurRed'
     BlueSkin=Texture'Minotaur_Tex.MinotaurBlue'
     IdleSound=Sound'Minotaur_Sound.Minotaurengine'
     VehiclePositionString="in a Classic Minotaur"
     VehicleNameString="Classic Minotaur 1.1"
     HornSounds(0)=Sound'Minotaur_Sound.Minotaurhorn'
     HealthMax=2000.000000
     Health=2000
     Skins(1)=Texture'Minotaur_Tex.MinotaurTreads'
     Skins(2)=Texture'Minotaur_Tex.MinotaurTreads'
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
     KParams=KarmaParamsRBFull'MinotaurClassic.MinotaurClassic.KarmaParamsRBFull8'

     bSelected=True
}
