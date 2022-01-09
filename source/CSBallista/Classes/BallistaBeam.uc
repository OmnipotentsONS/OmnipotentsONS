class BallistaBeam extends VehicleDamageType
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
     VehicleClass=Class'CSBallista.BallistaChargeGunPawn'
     DeathString="%o was fried by %k's Beam."
     FemaleSuicide="%o...Doh!"
     MaleSuicide="%o...Doh!"
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
