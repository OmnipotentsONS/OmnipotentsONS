class AlligatorFlak extends VehicleDamageType
	abstract;

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		if (PlayerController(Killer) != None)
			PlayerController(Killer).ReceiveLocalizedMessage(class'ONSVehicleKillMessage', 6);
	}
}

defaultproperties
{
     VehicleClass=Class'CSAlligator.Alligator'
     DeathString="%o was shredded by %k's Alligator Flak."
     FemaleSuicide="%o was perforated by her own Alligator Flak."
     MaleSuicide="%o was perforated by his own Alligator Flak."
     bDelayedDamage=True
     bBulletHit=True
     VehicleMomentumScaling=0.500000
}
