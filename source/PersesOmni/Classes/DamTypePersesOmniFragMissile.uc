
class DamTypePersesOmniFragMissile extends DamTypePersesOmniRocket abstract;


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
     DeathString="%o was ripped to shreds by %k's Perses frag missile."
     FemaleSuicide="%o fired his frag missile prematurely."
     MaleSuicide="%o fired his frag missile prematurely."
}
