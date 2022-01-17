class OmnitaurKill extends VehicleDamageType
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
     VehicleClass=Class'Omnitaur.Omnitaur'
     DeathString="%o was blasted into a million pieces by %k"
     FemaleSuicide="%o blew herself up with her own min)o(tuar - silly girl"
     MaleSuicide="%o blew himself up with him own min)o(taur - idiot"
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
