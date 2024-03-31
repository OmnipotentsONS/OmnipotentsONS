class KingHellHoundFlakBall extends VehicleDamageType
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
     VehicleClass=Class'CSKingHellHound.KingHellHound'
     DeathString="%o was ripped up by %k's flak."
     FemaleSuicide="%o flakked herself."
     MaleSuicide="%o flakked himself."
     //bDelayedDamage=True
     VehicleDamageScaling=1.500000
     bDetonatesGoop=True
     bThrowRagdoll=True
     GibPerterbation=0.250000
}
