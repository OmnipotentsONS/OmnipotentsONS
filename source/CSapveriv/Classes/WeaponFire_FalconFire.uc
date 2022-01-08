//=============================================================================
// FM_Sentinel_Fire
//=============================================================================

class WeaponFire_FalconFire extends InstantFire;

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

    StartTrace	= AirPower_Fighter(Instigator).GetFireStart();
	AirPower_Fighter(Instigator).CalcWeaponFire( HL, HN );

    R = Rotator( Normal(HL-StartTrace) );

	DoTrace(StartTrace, R);
}

function PlayFiring()
{

	UpdateFireSound();

	super.PlayFiring();
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
     FireSounds(0)=Sound'ONSVehicleSounds-S.LaserSounds.Laser02'
     FireSounds(1)=Sound'AssaultSounds.HumanShip.HnShipFire01'
     DamageType=Class'CSAPVerIV.DamType_FighterPlasma'
     DamageMin=45
     DamageMax=50
     TraceRange=65536.000000
     FireLoopAnim=
     FireEndAnim=
     FireAnimRate=0.450000
     TweenTime=0.000000
     FireSound=SoundGroup'WeaponSounds.PulseRifle.PulseRifleFire'
     FireForce="TranslocatorFire"
     FireRate=0.160000
     AmmoClass=Class'UT2k4Assault.Ammo_Dummy'
     BotRefireRate=0.160000
     WarnTargetPct=0.200000
     aimerror=800.000000
}
