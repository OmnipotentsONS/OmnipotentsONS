class CSRhinoSecondaryTurretKill extends VehicleDamageType
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
     VehicleClass=Class'CSGPolice.CSRhino'
     DeathString="%o was zapped by %k's beams."
     FemaleSuicide="%o ....oh dear."
     MaleSuicide="%o ....oh dear."
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
