class KingHellHoundLaser extends VehicleDamageType
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
     VehicleClass=Class'CSKingHellHound.KingHellHoundSideGunPawn'
     DeathString="%k's laser shocked %o."
     FemaleSuicide="%o used her laser on herself."
     MaleSuicide="%o used his laser on himself."
}
