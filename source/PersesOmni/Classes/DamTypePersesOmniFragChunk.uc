
class DamTypePersesOmniFragChunk extends VehicleDamageType;


static function IncrementKills(Controller Killer)
{
	local xPlayerReplicationInfo xPRI;

	xPRI = xPlayerReplicationInfo(Killer.PlayerReplicationInfo);
	if (xPRI != None)
	{
		xPRI.flakcount++;
		if (xPRI.flakcount == 15 && UnrealPlayer(Killer) != None)
			UnrealPlayer(Killer).ClientDelayedAnnouncementNamed('FlackMonkey', 15);
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     VehicleClass=Class'PersesOmni.PersesOmniMAS'
     DeathString="%o was ripped to shreds by %k's Perses frag shrapnel."
     FemaleSuicide="%o should have been more careful with that frag missile."
     MaleSuicide="%o should have been more careful with that frag missile."
     bDelayedDamage=True
     bBulletHit=True
     VehicleDamageScaling=1.000000
     VehicleMomentumScaling=0.500000
}
