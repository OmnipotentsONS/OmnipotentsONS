class KrakenFlak extends VehicleDamageType
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
     VehicleClass=Class'CSKraken.KrakenFlakGunPawn'
     DeathString="%o was ripped up by %k's Tiamat Flak."
     FemaleSuicide="%o flakked herself. Oh dear."
     MaleSuicide="%o flakked himself. Oh dear."
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
