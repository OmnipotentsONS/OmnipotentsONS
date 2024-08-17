class DamTypeFlakRatOmniChunk extends VehicleDamageType
	abstract;

defaultproperties
{
     VehicleClass=Class'FlakRatOmni.FlakRatOmni'
     DeathString="%o was shredded by %k's Omni Flak Rat Turret."
     FemaleSuicide="%o was perforated by her own Omni Flak Rat Turret."
     MaleSuicide="%o was perforated by his own Omni Flak Rat Flak."
     bDelayedDamage=True
     bBulletHit=True
     VehicleMomentumScaling=0.75000  // flak gun is 0.5 this is better.
     VehicleDamageScaling=1.0000
}
