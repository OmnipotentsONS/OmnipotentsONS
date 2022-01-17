/******************************************************************************
MessageProxyDamageType

Creation date: 2012-11-28 21:47
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class PVMessageProxyDamageType extends VehicleDamageType abstract;


var() class<DamageType> MessageSourceDamageType;


static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if (default.MessageSourceDamageType != None)
		return default.MessageSourceDamageType.static.DeathMessage(Killer, Victim);

	return Super.DeathMessage(Killer, Victim);
}

static function string SuicideMessage(PlayerReplicationInfo Victim)
{
	if (default.MessageSourceDamageType != None)
		return default.MessageSourceDamageType.static.SuicideMessage(Victim);

	return Super.SuicideMessage(Victim);
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
}
