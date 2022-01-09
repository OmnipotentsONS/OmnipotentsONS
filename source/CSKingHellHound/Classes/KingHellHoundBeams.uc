class KingHellHoundBeams extends VehicleDamageType
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
     VehicleClass=Class'CSKingHellHound.KingHellHoundRearTurretPawn'
     DeathString="%o was fried by %k's beams of doom."
     FemaleSuicide="%o...What on earth?"
     MaleSuicide="%o...What on earth?"
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
