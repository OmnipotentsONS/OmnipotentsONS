class WaspFlak extends VehicleDamageType
	abstract;

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		//Maybe add to game stats?
		if (PlayerController(Killer) != None)
			PlayerController(Killer).ReceiveLocalizedMessage(class'ONSVehicleKillMessage', 6);
	}
}

defaultproperties
{
     VehicleClass=Class'Wasp_SeriesII.Wasp_SeriesII'
     DeathString="%o was shredded by %k's Wasp Flak."
     FemaleSuicide="%o was perforated by her own Wasp Flak."
     MaleSuicide="%o was perforated by his own Wasp Flak."
     bDelayedDamage=True
     bBulletHit=True
     VehicleMomentumScaling=0.500000
}
