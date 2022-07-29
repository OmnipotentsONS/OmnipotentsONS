/******************************************************************************
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
	 Damage *= 0.5;
	 
if (DamageType == class'DamTypeFlakChunk')
	 Damage *= 0.5;

if (DamageType == class'DamTypeLinkPlasma')
	 Damage *= 0.5;

if (DamageType == class'DamTypeLinkShaft')
	 Damage *= 0.5;

if (DamageType == class'DamTypeMinigunBullet')
	 Damage *= 0.75;
	 
if (DamageType == class'DamTypeShockCombo')
	Damage *= 0.2;
	
if (DamageType.name == 'FalconPlasma')
	Damage *= 0.2;
	  
	  

    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}




//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Build="2021-10-17 11:28"
     VehicleNameString="Draco 2.7"
     
     // Increase explosion damage if they killing you hitting node should take the node out..
     ExplosionDamage=600.000000
     ExplosionRadius=2000.000000
     ExplosionMomentum=150000.000000
     
     // Increase the speed/maneuverabilty
     MaxPitchSpeed=2500.000000
     MaxThrustForce=250.000000
     MaxStrafeForce=150.000000
     MaxRiseForce=200.000000
     GroundSpeed=2600.000000
     MaxYawRate=3.000000
     //Additional Health
     HealthMax=600.000000
     Health=600
     
}