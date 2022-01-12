class CSSpankBadgerDamTypeProjSmall extends VehicleDamageType
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
     VehicleClass=Class'CSSpankBadger.CSSpankBadger'
     DeathString="%o was SPANKED by %k"
     FemaleSuicide="%o spanked herself"
     MaleSuicide="%o spanked himself"
     bDelayedDamage=False
     bThrowRagdoll=true
     bKUseTearOffMomentum=true
     bNeverSevers=true
}