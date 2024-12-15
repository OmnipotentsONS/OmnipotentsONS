class DamTypeMTIIOShockwave extends VehicleDamageType
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
     VehicleClass=Class'MonsterTruckOmni.MonsterTruckIIOmni'
     DeathString="%o had their ass smacked by the shockwave of %k's SuperBeast."
     FemaleSuicide="%o somehow managed to shockwave herself."
     MaleSuicide="%o somehow managed to shockwave himself."
     VehicleDamageScaling=2.250000
     VehicleMomentumScaling=1.5000
}
