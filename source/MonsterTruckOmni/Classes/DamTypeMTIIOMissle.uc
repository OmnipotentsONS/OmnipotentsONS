class DamTypeMTIIOMissle extends VehicleDamageType
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
     DeathString="%o couldn't avoid %k's ground-to-air missile."
     FemaleSuicide="%o blasted herself out of the sky."
     MaleSuicide="%o blasted himself out of the sky."
     bDelayedDamage=True
     VehicleDamageScaling=1.500000
     VehicleMomentumScaling=1.0000
}
