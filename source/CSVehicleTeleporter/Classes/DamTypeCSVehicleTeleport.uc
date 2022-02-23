//=============================================================================
// DamTypeVehicleTeleport v1.0 (10/2/05)
// Email - killbait_uk@hotmail.com
//
// Description
// -----------
//
// A custom DamageType to display a more meaningfull message that the player
// was telefraged by a vehicle.
//
//=============================================================================

class DamTypeCSVehicleTeleport extends VehicleDamageType
	abstract;

var int MessageSwitchBase, NumMessages;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
		return Default.DeathString;
}

defaultproperties
{
     DeathString="%o had their atoms skattered by %k's teleporting vehicle."
     FemaleSuicide="%o ran over herself."
     MaleSuicide="%o ran over himself."
     bArmorStops=False
     bAlwaysGibs=True
     bLocationalHit=False
     GibPerterbation=1.000000
}
