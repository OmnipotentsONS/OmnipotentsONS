class BioHoundKill extends DamTypeBioGlobVehicle
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
     VehicleClass=Class'BioHoundOmni.BioHound'
     DeathString="%o couldn't swallow all that goo from %k's BioHound"
     FemaleSuicide="%o gooed herself"
     MaleSuicide="%o gooed himself"
}
