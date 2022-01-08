class RoboBeamFire extends InstantFire;

var vector fireoffset;
#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax
var	sound				FireSounds[2];


simulated function UpdateFireSound()
{

		FireSound = FireSounds[1];
}

simulated function bool AllowFire()
{
    return true;
}

defaultproperties
{
     fireoffset=(X=264.000000,Y=100.000000,Z=-26.000000)
     DamageType=Class'OnslaughtBP.DamTypeONSCicadaLaser'
     DamageMin=50
     DamageMax=65
     TraceRange=17000.000000
     Momentum=4000.000000
     FireSound=Sound'ONSVehicleSounds-S.LaserSounds.Laser04'
     FireForce="ShockRifleFire"
     FireRate=0.200000
     AmmoClass=Class'XWeapons.ShieldAmmo'
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-8.000000)
     ShakeOffsetRate=(X=-600.000000)
     ShakeOffsetTime=3.200000
     BotRefireRate=0.700000
     aimerror=700.000000
}
