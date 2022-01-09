class FireBall extends VehicleDamageType
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
     VehicleClass=Class'CSBadgerFix.FlameTank'
     DeathString="%o was roasted alive by %k's fireball."
     FemaleSuicide="%o should not play with fire."
     MaleSuicide="%o should not play with fire."
     bDelayedDamage=True
}
