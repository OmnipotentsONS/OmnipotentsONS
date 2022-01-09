class HellHoundTwinbeam extends VehicleDamageType
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
     VehicleClass=Class'CSHellHound.HellHoundRearGunPawn'
     DeathString="%o was incinerated by %k's twin beams."
     FemaleSuicide="%o somehow managed to shoot herself with a turret."
     MaleSuicide="%o somehow managed to shoot himself with a turret."
}
