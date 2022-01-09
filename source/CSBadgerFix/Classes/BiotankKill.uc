class BioTankKill extends DamTypeBioGlobVehicle
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
     VehicleClass=Class'CSBadgerFix.BioTank'
     DeathString="%o was covered in goo by %k's BioTank"
     FemaleSuicide="%o pooped on herself ...oh dear"
     MaleSuicide="%o pooped on himself ...oh dear"
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
}
