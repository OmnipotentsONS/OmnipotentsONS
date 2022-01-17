//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DamTypeStarboltLaser extends VehicleDamageType
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
     VehicleClass=Class'StarboltV2Omni.StarboltV2Omni'
     DeathString="%k's Starbolt's blasters sizzled %o to death."
     FemaleSuicide="%o used her blaster on herself."
     MaleSuicide="%o used his blaster on himself."
}
