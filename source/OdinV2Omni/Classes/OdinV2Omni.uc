/******************************************************************************
OdinHoverTank

Creation date: 2012-08-14 10:18
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class OdinV2Omni extends OVHoverTank;


//=============================================================================
// Imports
//=============================================================================

//#exec obj load file=OdinTankMesh.ukx package=WVHoverTankV2

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
            Damage *= 2.0;

  if (DamageType == class'DamTypeFlakChunk')
            Damage *= 1.5;

	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.70;

	if (DamageType.name == 'WaspFlak')
		Damage *= 1.30;

	if (DamageType == class'DamTypeSniperShot')
			Damage *= 0.0;

	if (DamageType == class'DamTypeShockBeam')
		Damage *= 0.5;

	if (DamageType.name == 'DamTypeMinotaurClassicTurret')
		Damage *= 0.50;

	if (DamageType.name == 'DamTypeMinotaurClassicSecondaryTurret')
		Damage *= 0.50;

if (DamageType.name == 'OmnitaurTurretkill')
		Damage *= 0.50;

if (DamageType.name == 'Omnitaurkill')
		Damage *= 0.66;

	if (DamageType.name == 'OmnitaurSecondaryTurretKill')
		Damage *= 0.50;

if (DamageType.name == 'MinotaurTurretkill')
		Damage *= 0.50;

if (DamageType.name == 'Minotaurkill')
		Damage *= 0.66;


	if (DamageType.name == 'MinotaurSecondaryTurretKill')
		Damage *= 0.50;


	//Momentum *= 0.00;

    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	ReduceShake();
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

function bool RecommendLongRangedAttack()
{
	return true;
}

function ShouldTargetMissile(Projectile P)
{
	// leave it to the gunners
}

function bool TooCloseToAttack(Actor Other)
{
	local vector Dir, X, Y, Z;

	if (Vehicle(Other) != None || Abs(Other.Location.Z - Location.Z) > 2 * CollisionHeight)
	{
		Dir = Normal(Other.Location - Location);
		GetAxes(Instigator.Rotation, X, Y, Z);

		if (Abs(Z dot Dir) > 0.6)
		{
			// too high/low, i.e. can't reach with turret
			return true;
		}
	}
	return super.TooCloseToAttack(Other);
}

function bool IsArtillery()
{
	return true;
}

function bool IsDeployed()
{
	return true;
}



//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     HoverDustOffset(0)=(X=192.000000,Y=-135.000000)
     HoverDustOffset(1)=(X=96.000000,Y=-135.000000)
     HoverDustOffset(2)=(X=-6.000000,Y=-135.000000)
     HoverDustOffset(3)=(X=-96.000000,Y=-135.000000)
     HoverDustOffset(4)=(X=-180.000000,Y=-135.000000)
     HoverDustOffset(5)=(X=192.000000,Y=135.000000)
     HoverDustOffset(6)=(X=96.000000,Y=135.000000)
     HoverDustOffset(7)=(X=-6.000000,Y=135.000000)
     HoverDustOffset(8)=(X=-96.000000,Y=135.000000)
     HoverDustOffset(9)=(X=-180.000000,Y=135.000000)
     EnginePitchRange=25
     CrouchedHoverPenScale=1.500000
     DustEmitterClass=Class'WVHoverTankV2.LargeHoverTankDustEmitter'
     MaxGroundSpeed=1400.000000
     TurretSocketClass=Class'OdinV2Omni.IonTurretSocket'
     TurnTorqueFactor=1700.000000
     TurnTorqueMax=450.000000
     TurnDamping=350.000000
     MaxYawRate=1.000000
     DriverWeapons(0)=(WeaponClass=Class'OdinV2Omni.OdinIonTurret',WeaponBone="MainCannonAttach")
     PassengerWeapons(0)=(WeaponPawnClass=Class'OdinV2Omni.OdinLinkTurretPawn',WeaponBone="RearLeftAttach")
     PassengerWeapons(1)=(WeaponPawnClass=Class'OdinV2Omni.OdinLinkTurretPawn',WeaponBone="RearRightAttach")
     bHasAltFire=False
     RedSkin=Shader'WVHoverTankV2.Skins.TankShaderRed'
     BlueSkin=Shader'WVHoverTankV2.Skins.TankShaderBlue'
     DisintegrationEffectClass=Class'UT2k4Assault.FX_SpaceFighter_Explosion'
     DamagedEffectScale=1.700000
     DamagedEffectOffset=(X=120.000000,Y=24.000000,Z=30.000000)
     VehicleMass=14.000000
     bShowChargingBar=True
     ExitPositions(0)=(Y=-240.000000)
     ExitPositions(1)=(Y=240.000000)
     ExitPositions(2)=(X=150.000000,Y=-240.000000,Z=100.000000)
     ExitPositions(3)=(X=150.000000,Y=240.000000,Z=100.000000)
     ExitPositions(4)=(X=-150.000000,Y=-240.000000,Z=100.000000)
     ExitPositions(5)=(X=-150.000000,Y=240.000000,Z=100.000000)
     EntryRadius=400.000000
     FPCamPos=(X=-150.000000,Y=0.000000,Z=320.000000)
     TPCamWorldOffset=(Z=350.000000)
     VehiclePositionString="in an Odin"
     VehicleNameString="Odin 2.51"
     VehicleDescription="Odin, the chief god of Norse mythology. His spear, Gungnir, is said to never miss its target. The Odin hover tank is equipped with a focused ion turret and two plasma turrets."
     RanOverDamageType=Class'OdinV2Omni.DamTypeOdinRoadkill'
     CrushedDamageType=Class'OdinV2Omni.DamTypeOdinPancake'
     bSuperSize=True
     NavigationPointRange=190.000000
     HealthMax=2250
     Health=1550
     Mesh=SkeletalMesh'WVHoverTankV2.Odin.OdinTankChassis'
     SoundPitch=60
     
}
