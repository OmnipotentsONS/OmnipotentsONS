class BioHoundRoadkill extends DamTypeRoadkill
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
	    DeathString="%k BioHound ran over %o squishing all their guts out."
     FemaleSuicide="%o ran over herself."
     MaleSuicide="%o ran over himself."
     VehicleClass=Class'BioHoundOmni.BioHound'
}
