//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ArbalestRocketNovaSecondary extends VehicleDamageType;


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
     VehicleClass=Class'ONS-ArbalestNM.Arbalest'
     DeathString="%o was blown up."
     FemaleSuicide="%o blew herself up."
     MaleSuicide="%o blew himself up."
     bArmorStops=False
     bSuperWeapon=True
     bKUseOwnDeathVel=True
     bDelayedDamage=True
     KDeathVel=600.000000
     KDeathUpKick=600.000000
}
