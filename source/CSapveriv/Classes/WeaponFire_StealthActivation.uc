class WeaponFire_StealthActivation extends ProjectileFire;

var Phantom P;

function StartFiring()
{
  P=Phantom(Instigator);
  Phantom(instigator).StealthMode();
  Phantom(instigator).NextWeapon();
}
function DoFireEffect()
{
  P=Phantom(Instigator);
  Phantom(instigator).StealthMode();
  Phantom(instigator).NextWeapon();
}

defaultproperties
{
     FireSound=Sound'WeaponSounds.TAGRifle.TAGFireB'
     FireRate=1.500000
     AmmoClass=Class'CSAPVerIV.Ammo_Stealth'
     BotRefireRate=1.500000
     WarnTargetPct=0.900000
}
