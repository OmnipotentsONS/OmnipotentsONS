class FireHoundSkyMineKill extends VehicleDamageType
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
     VehicleClass=Class'FireVehiclesV2Omni.FireHoundSideGunPawn'
     DeathString="%o incinerated by %k's Fire Mine."
     FemaleSuicide="%o ran into her own fire mine."
     MaleSuicide="%o ran into his own fire mine."
     bDelayedDamage=True
}
