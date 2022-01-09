class BadgerGrenade_Kill extends VehicleDamageType
	abstract;

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		//Maybe add to game stats?
		if (PlayerController(Killer) != None)
			PlayerController(Killer).ReceiveLocalizedMessage(class'ONSVehicleKillMessage', 5);
	}
}

defaultproperties
{
     VehicleClass=Class'CSBadgerFix.Badger'
     DeathString="%o got punted by %k's Badger Grenade."
     FemaleSuicide="%o was too close to her own Badger Grenade."
     MaleSuicide="%o was too close to his own Badger Grenade."
     bDelayedDamage=True
}
