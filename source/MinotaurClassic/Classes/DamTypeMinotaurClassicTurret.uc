class DamTypeMinotaurClassicTurret extends VehicleDamageType
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
     VehicleClass=Class'MinotaurClassic.MinotaurClassicTurretPawn'
     DeathString="%o was shredded by %k's Minotaur minigun."
     FemaleSuicide="%o...Doh!"
     MaleSuicide="%o...Doh!"
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
