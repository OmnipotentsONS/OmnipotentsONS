class Kraken_Rockets extends VehicleDamageType
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
     VehicleClass=Class'CSKraken.Kraken'
     DeathString="%o was smashed up by %k's Tiamat Rockets."
     FemaleSuicide="%o rocketed herself. Oh dear."
     MaleSuicide="%o rocketed himself. Oh dear."
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
