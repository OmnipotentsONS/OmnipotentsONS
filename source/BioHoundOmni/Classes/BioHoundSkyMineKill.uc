class BioHoundSkyMineKill extends DamTypeBioGlobVehicle
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
     VehicleClass=Class'BioHoundOmni.BioHoundSideGunPawn'
     DeathString="%o got gooped by %k's Bio skymine."
     FemaleSuicide="%o ran into her own skymine."
     MaleSuicide="%o ran into his own skymine."
}
