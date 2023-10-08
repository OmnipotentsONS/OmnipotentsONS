/**
Badgers_V2.FlameBadger

Creation date: 2014-01-26 11:57
Last change: $Id$
Copyright (c) 2014, Wormbo
*/

class FlameBadger extends MyBadger;



//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     //FirstDestructionEffectClass=Class'CSBadgerFix.FlameBadgerExplosion'
     //InstantDisintegrationEffectClass=Class'CSBadgerFix.FlameBadgerExplosion'
     DriverWeapons(0)=(WeaponClass=Class'CSBadgerFix.FlameBadgerFlamethrower')
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSBadgerFix.FlameBadgerTurretPawn')
     RedSkin=Shader'Badgers_V2beta3.Skins.FlameBadgerRed'
     BlueSkin=Shader'Badgers_V2beta3.Skins.FlameBadgerBlue'
     DisintegrationHealth=0.000000
     ExplosionDamage=300.000000
     ExplosionRadius=800.000000
     ExplosionMomentum=100000.000000
     ExplosionDamageType=Class'CSBadgerFix.DamTypeFlameBadgerExplosion'
     VehiclePositionString="in a Flame Badger"
     VehicleNameString="Flame Badger"
     RanOverDamageType=Class'CSBadgerFix.DamTypeFlameBadgerRoadkill'
     CrushedDamageType=Class'CSBadgerFix.DamTypeFlameBadgerPancake'
     HealthMax=700.000000
     Health=700
}
