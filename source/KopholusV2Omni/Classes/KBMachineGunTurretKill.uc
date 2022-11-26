class KBMachineGunTurretKill extends VehicleDamageType
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
     VehicleClass=Class'KopholusV2Omni.SkaarjViper'
     DeathString="%o was shredded by %k's Viper minigun."
     FemaleSuicide="%o...Doh!"
     MaleSuicide="%o...Doh!"
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
