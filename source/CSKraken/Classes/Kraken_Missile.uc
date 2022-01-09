class Kraken_Missile extends VehicleDamageType
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
     VehicleClass=Class'CSKraken.KrakenMissileGunPawn'
     DeathString="%o was stung by %k's Tiamat Missiles."
     FemaleSuicide="%o stung herself. Oh dear."
     MaleSuicide="%o stung himself. Oh dear."
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
