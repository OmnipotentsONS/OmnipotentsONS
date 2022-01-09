class BadgerCannon_Kill extends VehicleDamageType
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
     VehicleClass=Class'CSBadgerFix.BadgerTurretPawn'
     DeathString="%o was mushroomed by the Badger Cannon of %k"
     FemaleSuicide="%o blew herself up with her own Badger - Idiot"
     MaleSuicide="%o blew himself up with his own Badger - Idiot"
     bDelayedDamage=True
}
