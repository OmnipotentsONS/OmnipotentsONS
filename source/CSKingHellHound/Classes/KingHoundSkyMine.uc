class KingHoundSkyMine extends VehicleDamageType
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
     VehicleClass=Class'CSKingHellHound.KingHellHoundSideGunPawn'
     DeathString="%o ran into %k's skymine."
     FemaleSuicide="%o ran into her own skymine."
     MaleSuicide="%o ran into his own skymine."
     bDelayedDamage=True
}
