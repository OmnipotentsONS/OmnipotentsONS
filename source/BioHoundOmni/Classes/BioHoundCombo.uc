class BioHoundCombo extends DamTypeBioGlobVehicle
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
     DeathString="%o couldn't swallow all that goo of %k's Bio skymine combo."
     FemaleSuicide="%o was a little hasty detonation her skymines."
     MaleSuicide="%o was a little hasty detonating his skymines."
     VehicleDamageScaling=0.750000
     VehicleMomentumScaling=0.500000
}
