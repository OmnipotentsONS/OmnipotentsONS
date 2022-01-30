//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ArbalestRocketBomb extends VehicleDamageType;


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
     VehicleClass=Class'ArbalestsV2Omni.ArbalestBomb'
     DeathString="%o was shot down by %k's Arbalest Rockets."
     FemaleSuicide="%o blew herself up."
     MaleSuicide="%o blew himself up."
     bArmorStops=False
}
