class FireBall extends VehicleDamageType
	abstract;

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		if (PlayerController(Killer) != None)
			PlayerController(Killer).ReceiveLocalizedMessage(class'ONSVehicleKillMessage', 5);
	}
}

defaultproperties
{
     VehicleClass=Class'FireVehiclesV2Omni.FireTank'
     DeathString="%o was roasted alive by %k's fireball."
     FemaleSuicide="%o should not play with fire."
     MaleSuicide="%o should not play with fire."
     bDelayedDamage=True
}
