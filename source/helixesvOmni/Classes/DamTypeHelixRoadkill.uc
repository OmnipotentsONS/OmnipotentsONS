class DamTypeHelixRoadkill extends VehicleDamageType
	abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
        return Default.DeathString ;
}

defaultproperties
{
     VehicleClass=Class'helixesvOmni.helixesvOmni'
     DeathString="%o couldn't stay ahead of %k's Helix!"
     FemaleSuicide="%o hit herself with her own Helix."
     MaleSuicide="%o hit himself with his own Helix."
}
