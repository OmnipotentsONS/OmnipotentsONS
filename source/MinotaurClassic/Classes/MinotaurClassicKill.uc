class MinotaurClassicKill extends VehicleDamageType
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
     VehicleClass=Class'MinotaurClassic.MinotaurClassic'
     DeathString="%o was blasted to tiny bits by %k's Minotaur"
     FemaleSuicide="%o ...oh dear."
     MaleSuicide="%o ...oh dear."
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
