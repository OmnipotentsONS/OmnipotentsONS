class DamTypeHelixPancake extends VehicleDamageType
	abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
        return Default.DeathString ;
}

defaultproperties
{
     VehicleClass=Class'helixesvOmni.helixesvOmni'
     DeathString="%o was squashed by %k's Helix!"
     FemaleSuicide="%o died from a falling Helix."
     MaleSuicide="%o died from a falling Helix."
}
