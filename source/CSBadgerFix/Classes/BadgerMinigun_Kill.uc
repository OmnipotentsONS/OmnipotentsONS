class BadgerMinigun_Kill extends VehicleDamageType
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
     DeathString="%o was turned into Swiss Cheese by %k's Badger."
     FemaleSuicide="%o...Doh!"
     MaleSuicide="%o...Doh!"
     bDelayedDamage=True
}
