class KrakenLasers extends VehicleDamageType
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
     VehicleClass=Class'CSKraken.KrakenLaserGunPawn'
     DeathString="%o was zapped to death by %k's Tiamat Lasers."
     FemaleSuicide="%o lasered herself. Oh dear."
     MaleSuicide="%o lasered himself. Oh dear."
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
