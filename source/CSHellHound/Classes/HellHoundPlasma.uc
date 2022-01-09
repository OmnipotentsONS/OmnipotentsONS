class HellHoundPlasma extends VehicleDamageType
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
     VehicleClass=Class'CSHellHound.HellHound'
     DeathString="%o was filled up by %k's HellHound plasma."
     FemaleSuicide="%o zapped herself."
     MaleSuicide="%o zapped himself."
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
