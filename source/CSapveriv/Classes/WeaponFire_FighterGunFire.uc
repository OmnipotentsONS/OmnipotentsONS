//=============================================================================
// Fighter_GunFire
//=============================================================================
// Adapted From Laurent Delayen
// � 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class WeaponFire_FighterGunFire extends InstantFire;

var	bool				bSwitch;
var	sound				FireSounds[2];


event ModeDoFire()
{
	bSwitch = ( (WeaponAttachment(Weapon.ThirdPersonActor).FlashCount % 2) == 1 );
	super.ModeDoFire();
}

function DoFireEffect()
{
    local Vector	StartTrace, HL, HN;
    local Rotator	R;

	if ( Instigator == None || !Instigator.IsA('AirPower_Vehicle') )
	{
		super.DoFireEffect();
		return;
	}
    Instigator.MakeNoise(1.0);
    StartTrace	= AirPower_Vehicle(Instigator).GetFireStart();
	AirPower_Vehicle(Instigator).CalcWeaponFire( HL, HN );
    R = Rotator( Normal(HL-StartTrace) );
	DoTrace(StartTrace, R);
}



simulated function UpdateFireSound()
{

		FireSound = FireSounds[1];
}

simulated function bool AllowFire()
{
    return true;
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     DamageType=Class'CSAPVerIV.DamType_FighterPlasma'
     DamageMin=45
     DamageMax=50
     TraceRange=65536.000000
     bSplashDamage=True
     bSplashJump=True
     bRecommendSplashDamage=True
     bModeExclusive=False
     TweenTime=0.000000
     FireSound=Sound'ONSVehicleSounds-S.LaserSounds.Laser04'
     FireForce="TranslocatorFire"
     FireRate=0.160000
     AmmoClass=Class'UT2k4Assault.Ammo_Dummy'
     BotRefireRate=0.160000
     WarnTargetPct=0.900000
}
