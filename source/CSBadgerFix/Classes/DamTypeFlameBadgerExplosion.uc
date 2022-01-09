/**
Badgers_V2.DamTypeFlameBadgerExplosion

Creation date: 2014-01-26 14:18
Last change: $Id$
Copyright (c) 2014, Wormbo
*/

class DamTypeFlameBadgerExplosion extends DamTypeONSVehicleExplosion;


var float LastBurnOutTime;


static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None)
	{
		// simple hack to prevent sending multiple announcements at the same time
		if (default.LastBurnOutTime != Killed.Level.TimeSeconds)
			default.LastBurnOutTime = Killed.Level.TimeSeconds;
		else
			return;

		if (UnrealPlayer(Killer) != None)
			UnrealPlayer(Killer).ClientDelayedAnnouncementNamed('Burn_out', 15);
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
}
