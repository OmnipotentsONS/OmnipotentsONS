/******************************************************************************
DamTypeDracoExplosion

Creation date: 2012-11-28 22:04
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DamTypeDracoExplosion extends DamTypeONSVehicleExplosion abstract;


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
	VehicleDamageScaling=4.0
	VehicleMomentumScaling=1.5
}
