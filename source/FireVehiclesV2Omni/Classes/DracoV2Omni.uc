/******************************************************************************
FireVehiclesV2Omni, this depends on several resources in WVDraco, wormbo's original version
The sounds/textures/SM etc. all come from that package.

Original: 
Draco

Creation date: 2013-04-27 14:52
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DracoV2Omni extends Draco
placeable;

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{


	if (DamageType.name == 'FlameKill')
		Damage *= 0.10;

if (DamageType.name == 'FireKill')
		Damage *= 0.15;
				
if (DamageType.name == 'Burned')
		Damage *= 0.15;
		
if (DamageType.name == 'FireBall')
		Damage *= 0.20;
		
if (DamageType.name == 'DamTypeFirebugFlame')
		Damage *= 0.20;

if (DamageType.name == 'FlameKillRaptor')
		Damage *= 0.50;

	if (DamageType.name == 'HeatRay')
		Damage *= 0.10;

if (DamageType.name == 'DamTypeDracoFlamethrower')
		Damage *= 0.20;

if (DamageType.name == 'DamTypeDracoNapalmRocket')
		Damage *= 0.20;

if (DamageType.name == 'DamTypeDracoNapalmGlob')
		Damage *= 0.20;
		
if (DamageType == class'DamTypeShockBeam')
		Damage *= 0.5;

if (DamageType == class'DamTypeONSAVRiLRocket')
	 Damage *= 0.75;
	 
if (DamageType == class'DamTypeFlakChunk')
	 Damage *= 0.75;

if (DamageType == class'DamTypeLinkPlasma')
	 Damage *= 0.5;

if (DamageType == class'DamTypeLinkShaft')
	 Damage *= 0.5;

if (DamageType == class'DamTypeMinigunBullet')
	 Damage *= 0.5;
	 
if (DamageType == class'DamTypeShockCombo')
	Damage *= 0.5;
	
if (DamageType.name == 'FalconPlasma')
	Damage *= 0.5;
	  
	  

    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

function KDriverEnter(Pawn p)
{
	p.ReceiveLocalizedMessage(class'FireVehiclesV2Omni.DracoEnterMessage', 0);
	Super.KDriverEnter(p);
}



//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
		 Build="2022-07-30 11:28"
	   SpinSquare=TexRotator'WVDraco.Draco.IncSquare'
     LockedMsg=" INCOMING "
     SpinCircles(0)=TexRotator'WVDraco.Draco.IncCircle0'
     SpinCircles(1)=TexRotator'WVDraco.Draco.IncCircle1'
     
      // Increase the speed/maneuverabilty
     MaxPitchSpeed=2500.000000
     MaxThrustForce=250.000000
     MaxStrafeForce=150.000000
     MaxRiseForce=200.000000
     GroundSpeed=2600.000000
     MaxYawRate=3.000000
     
     RollTorqueTurnFactor=250.000000
     DriverWeapons(0)=(WeaponClass=Class'FireVehiclesV2Omni.DracoFlamethrowerGun',WeaponBone="GatlingGunAttach")
     bHasAltFire=True
     PassengerWeapons(0)=(WeaponPawnClass=Class'FireVehiclesV2Omni.DracoFireballPawn',WeaponBone="LeftRLAttach")
     PassengerWeapons(1)=(WeaponPawnClass=Class'FireVehiclesV2Omni.DracoRocketPackPawn',WeaponBone="RightRLAttach")
     RedSkin=Shader'WVDraco.Skins.DracoShaderRed'
     BlueSkin=Shader'WVDraco.Skins.DracoShaderBlue'
     DisintegrationEffectClass=Class'WVDraco.DracoExplosionEffect'
     DisintegrationHealth=0.000000
     
     
     ImpactDamageMult=0.000300
     HeadlightCoronaOffset(0)=(X=263.000000,Y=32.000000,Z=35.000000)
     HeadlightCoronaOffset(1)=(X=263.000000,Y=-32.000000,Z=35.000000)
     FPCamPos=(X=26.000000)
     FPCamViewOffset=(X=50.000000,Z=50.000000)
     TPCamWorldOffset=(Z=200.000000)
     VehiclePositionString="in a Draco"
     VehicleNameString="Draco 2.9"
     VehicleDescription="Draco is the latin word for 'dragon' - and this one breathes fire!"
     RanOverDamageType=Class'FireVehiclesV2Omni.DamTypeDracoRoadkill'
     CrushedDamageType=Class'FireVehiclesV2Omni.DamTypeDracoPancake'
     NavigationPointRange=100.000000
     
     // Increase explosion damage if they killing you hitting node should take the node out..
     ExplosionDamage=750.000000
     ExplosionRadius=2500.000000
     ExplosionMomentum=150000.000000
     ExplosionDamageType=Class'FireVehiclesV2Omni.DamTypeDracoExplosion'
    
     //Additional Health
     HealthMax=600.000000
     Health=600
     
     HornSounds(0)=Sound'CuddlyArmor_Sound.Horns.FireTankHorn'
     HornSounds(1)=Sound'CuddlyArmor_Sound.Horns.Horn3'
}