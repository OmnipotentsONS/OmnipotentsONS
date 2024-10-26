class DamType_PredatorLaserPlasma extends VehicleDamageType
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
     VehicleClass=Class'CSAPVerIV.Predator'
     DeathString="%k's Predator blasted %o with laser plasma."
     FemaleSuicide="%o fried herself with her own plasma blast."
     MaleSuicide="%o fried himself with his own plasma blast."
     bDetonatesGoop=True
     bDelayedDamage=True
     FlashFog=(X=700.000000)
     VehicleDamageScaling=1.33000

}
